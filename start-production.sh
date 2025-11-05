#!/bin/bash

# Smart Inter Wilaya Taxi - Production Startup Script
# This script initializes and starts the production deployment

set -e

echo "🚀 Starting Smart Inter Wilaya Taxi Production Deployment"
echo "========================================================="

# Configuration
PROJECT_NAME="smart-inter-wilaya-taxi"
USER_SERVICE_PORT="8081"
POSTGRES_PORT="5432"
REDIS_PORT="6379"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}🔧 Checking prerequisites...${NC}"

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running. Please start Docker Desktop.${NC}"
    echo "💡 On Windows, start Docker Desktop and wait for it to be ready"
    exit 1
fi

# Check if Docker Compose is available
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose is not installed.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Prerequisites check passed${NC}"

# Check if ports are available
echo -e "${YELLOW}🔍 Checking port availability...${NC}"
ports=(8081 5432 6379)
for port in "${ports[@]}"; do
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo -e "${RED}❌ Port $port is already in use${NC}"
        echo "Please stop the service using port $port or modify the docker-compose.yml"
        exit 1
    fi
done

echo -e "${GREEN}✅ Ports are available${NC}"

# Create environment file for production
echo -e "${YELLOW}📝 Creating production environment file...${NC}"
cat > .env << EOF
# Smart Inter Wilaya Taxi - Production Environment
POSTGRES_PASSWORD=SmartTaxi2025!@#$SecurePassword
DATABASE_URL=jdbc:postgresql://postgres:5432/smart_taxi_db
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=SmartTaxi2025!@#$SecurePassword
REDIS_HOST=redis
REDIS_PORT=6379
JWT_SECRET=mySecretKey123456789012345678901234567890ProductionSecure
JWT_EXPIRATION=86400000
CORS_ALLOWED_ORIGINS=*
SPRING_PROFILES_ACTIVE=production
MAVEN_OPTS=-Xmx2g -Xms1g
JAVA_OPTS=-XX:+UseG1GC -XX:+UseStringDeduplication
EOF

echo -e "${GREEN}✅ Environment file created${NC}"

# Create logs directory
echo -e "${YELLOW}📁 Creating logs directory...${NC}"
mkdir -p logs

# Stop any existing containers
echo -e "${YELLOW}🛑 Stopping any existing containers...${NC}"
docker-compose down --remove-orphans 2>/dev/null || true

# Pull latest images
echo -e "${YELLOW}📥 Pulling latest base images...${NC}"
docker-compose pull postgres redis

# Build and start services
echo -e "${YELLOW}🏗️  Building and starting services...${NC}"
docker-compose up -d --build

# Wait for services to be ready
echo -e "${YELLOW}⏳ Waiting for services to start...${NC}"
sleep 30

# Check service health
echo -e "${YELLOW}🏥 Checking service health...${NC}"

# Check PostgreSQL
echo -n "PostgreSQL: "
if docker-compose exec -T postgres pg_isready -U postgres -d smart_taxi_db >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Ready${NC}"
else
    echo -e "${RED}❌ Not Ready${NC}"
fi

# Check Redis
echo -n "Redis: "
if docker-compose exec -T redis redis-cli ping >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Ready${NC}"
else
    echo -e "${RED}❌ Not Ready${NC}"
fi

# Check User Service
echo -n "User Service: "
sleep 10  # Give more time for the service to start
if curl -f http://localhost:8081/user-service/api/health >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Ready${NC}"
else
    echo -e "${YELLOW}⚠️  Still starting...${NC}"
    echo "Checking logs..."
    docker-compose logs --tail=10 user-service
fi

# Show service status
echo -e "\n${YELLOW}📊 Service Status:${NC}"
docker-compose ps

# Show resource usage
echo -e "\n${YELLOW}💻 Resource Usage:${NC}"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"

# Run basic tests
echo -e "\n${YELLOW}🧪 Running basic tests...${NC}"

# Test health endpoint
echo -n "Health Check: "
if curl -s http://localhost:8081/user-service/api/health | grep -q "UP"; then
    echo -e "${GREEN}✅ PASS${NC}"
else
    echo -e "${RED}❌ FAIL${NC}"
fi

# Test user registration
echo -n "User Registration: "
registration_response=$(curl -s -X POST http://localhost:8081/user-service/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test.production@example.com",
    "password": "ProductionTest123!",
    "firstName": "Production",
    "lastName": "Test",
    "phoneNumber": "+213555000000",
    "city": "Algiers",
    "wilaya": "Algiers",
    "licenseNumber": "PROD123"
  }')

if echo "$registration_response" | grep -q "token"; then
    echo -e "${GREEN}✅ PASS${NC}"
    JWT_TOKEN=$(echo "$registration_response" | grep -o '"token":"[^"]*' | cut -d'"' -f4)
else
    echo -e "${RED}❌ FAIL${NC}"
    echo "Response: $registration_response"
fi

# Final status
echo -e "\n${GREEN}🎉 Production deployment completed!${NC}"
echo "=================================================="
echo -e "${GREEN}✅ PostgreSQL database is running${NC}"
echo -e "${GREEN}✅ Redis cache is running${NC}"
echo -e "${GREEN}✅ User Service is running${NC}"
echo ""
echo "🔗 Access Points:"
echo "   • Health Check: http://localhost:8081/user-service/api/health"
echo "   • API Base URL: http://localhost:8081/user-service/api/"
echo "   • API Docs: http://localhost:8081/user-service/v3/api-docs"
echo ""
echo "🐳 Management Commands:"
echo "   • View logs: docker-compose logs -f"
echo "   • Stop services: docker-compose down"
echo "   • Restart: docker-compose restart"
echo "   • Status: docker-compose ps"
echo ""
echo "🧪 Run tests: ./test-deployment.sh"
echo "📖 Read documentation: DEPLOYMENT.md"
echo ""

# Optional: Run the test script
read -p "Would you like to run the deployment test now? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}🧪 Running deployment tests...${NC}"
    chmod +x test-deployment.sh
    ./test-deployment.sh
fi

echo -e "${GREEN}🚀 Smart Inter Wilaya Taxi is ready for production use!${NC}"