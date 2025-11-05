# 🚖 Smart Inter Wilaya Taxi - Deployment Guide

## 📋 Deployment Status

✅ **COMPLETED**: User Service deployment is now fully automated and ready for production!

### 🏗️ What We've Deployed

1. **User Service** - Production-ready microservices with JWT authentication
2. **PostgreSQL Database** - Multi-tenant database with comprehensive schema
3. **Redis Cache** - High-performance caching layer
4. **Docker Containerization** - Production-optimized containers
5. **GitHub Actions CI/CD** - Automated deployment pipeline
6. **Health Monitoring** - Built-in health checks and monitoring

## 🚀 Deployment Architecture

```
┌─────────────────┐
│   GitHub Actions │  ← Automated CI/CD Pipeline
└─────────────────┘
         │
         ▼
┌─────────────────┐
│   GitHub Container Registry │  ← Container Images
└─────────────────┘
         │
         ▼
┌─────────────────┐
│   Docker Compose │  ← Production Orchestration
└─────────────────┘
         │
         ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ User Service    │    │ PostgreSQL DB   │    │ Redis Cache     │
│ (Port 8081)     │    │ (Port 5432)     │    │ (Port 6379)     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🔧 Deployment Options

### Option 1: Automated GitHub Deployment (Recommended)

1. **Push to Main Branch**: The deployment is triggered automatically
2. **GitHub Actions**: Builds, tests, and deploys automatically
3. **Container Registry**: Images are stored in GitHub Container Registry

```bash
# Push your code to trigger deployment
git add .
git commit -m "Deploy Smart Inter Wilaya Taxi"
git push origin main
```

### Option 2: Local Docker Compose

1. **Clone Repository**: Get the latest code
2. **Start Services**: Use Docker Compose for local deployment
3. **Environment Variables**: Configure production settings

```bash
# Start all services
docker-compose up -d

# Check service status
docker-compose ps

# View logs
docker-compose logs -f user-service
```

### Option 3: Production Kubernetes

```bash
# Apply Kubernetes manifests
kubectl apply -f kubernetes/

# Check deployment status
kubectl get pods
kubectl get services
```

## 🔐 Security Configuration

### Environment Variables

Set these environment variables for production:

```bash
# Database Configuration
POSTGRES_PASSWORD=your-secure-password
DATABASE_URL=jdbc:postgresql://postgres:5432/smart_taxi_db
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=your-secure-password

# Redis Configuration
REDIS_HOST=redis
REDIS_PORT=6379

# JWT Configuration
JWT_SECRET=your-256-bit-secret-key
JWT_EXPIRATION=86400000

# CORS Configuration
CORS_ALLOWED_ORIGINS=https://yourdomain.com
```

### Database Security

The deployment includes:
- ✅ PostgreSQL with proper user permissions
- ✅ Database schema initialization
- ✅ Connection pooling configuration
- ✅ Health checks for database connectivity

## 📊 Monitoring & Health Checks

### Health Check Endpoints

- **Main Service**: `GET /user-service/api/health`
- **Database Health**: Automatic checks via Spring Boot Actuator
- **Redis Health**: Connection and ping tests
- **Container Health**: Docker health check integration

### Monitoring Dashboard

The deployment includes:
- ✅ Application metrics via Spring Boot Actuator
- ✅ Health check aggregation
- ✅ Container status monitoring
- ✅ Log aggregation and analysis

### Performance Metrics

- ✅ Connection pooling metrics
- ✅ Response time monitoring
- ✅ Database query performance
- ✅ Cache hit/miss ratios

## 🧪 Testing the Deployment

### 1. Service Health Check

```bash
# Check if all services are healthy
curl http://localhost:8081/user-service/api/health
```

Expected Response:
```json
{
  "status": "UP",
  "components": {
    "db": {"status": "UP"},
    "redis": {"status": "UP"},
    "diskSpace": {"status": "UP"}
  }
}
```

### 2. User Registration Test

```bash
curl -X POST http://localhost:8081/user-service/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "driver@example.com",
    "password": "SecurePassword123!",
    "firstName": "Ahmed",
    "lastName": "Benali",
    "phoneNumber": "+213555123456",
    "city": "Algiers",
    "wilaya": "Algiers",
    "licenseNumber": "D123456"
  }'
```

### 3. User Login Test

```bash
curl -X POST http://localhost:8081/user-service/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "driver@example.com",
    "password": "SecurePassword123!"
  }'
```

### 4. Get User Profile

```bash
# Use the JWT token from login response
curl -H "Authorization: Bearer YOUR_JWT_TOKEN" \
     http://localhost:8081/user-service/api/users/1
```

## 🔍 Troubleshooting

### Common Issues

1. **Database Connection Issues**
   ```bash
   # Check PostgreSQL logs
   docker-compose logs postgres
   
   # Test database connection
   docker-compose exec postgres pg_isready -U postgres
   ```

2. **Redis Connection Issues**
   ```bash
   # Check Redis logs
   docker-compose logs redis
   
   # Test Redis connection
   docker-compose exec redis redis-cli ping
   ```

3. **Application Startup Issues**
   ```bash
   # Check application logs
   docker-compose logs user-service
   
   # Check resource usage
   docker stats
   ```

### Service Dependencies

```
user-service → postgres (database)
user-service → redis (caching)
postgres → shared volume (data persistence)
redis → shared volume (data persistence)
```

## 📈 Scaling & Performance

### Horizontal Scaling

The deployment is designed for horizontal scaling:

```bash
# Scale user service
docker-compose up --scale user-service=3 -d

# Load balancing is handled by Docker Swarm or Kubernetes
```

### Resource Limits

- **User Service**: 2GB RAM, 2 CPU cores
- **PostgreSQL**: 1GB RAM, 1 CPU core  
- **Redis**: 512MB RAM, 1 CPU core

### Performance Tuning

- ✅ Connection pooling configured
- ✅ Redis caching enabled
- ✅ Database indexes optimized
- ✅ JVM tuning for production

## 🚦 Deployment Checklist

- [x] User Service built and containerized
- [x] PostgreSQL database configured
- [x] Redis cache configured
- [x] Docker Compose setup created
- [x] GitHub Actions workflow created
- [x] Health checks implemented
- [x] Security configurations applied
- [x] Monitoring endpoints configured
- [x] Documentation created
- [x] Testing procedures documented

## 🎯 Next Steps

### Immediate Actions

1. **Configure Production Environment Variables**
2. **Set up SSL/TLS certificates**
3. **Configure domain and DNS**
4. **Set up monitoring dashboards**

### Future Enhancements

- [ ] **Group Service**: Complete group management functionality
- [ ] **Location Service**: Real-time GPS tracking
- [ ] **Chat Service**: Real-time messaging
- [ ] **AI Assistant**: Smart recommendations
- [ ] **Frontend**: Angular web application
- [ ] **Mobile App**: Native mobile applications

## 📞 Support

### Deployment Logs

All deployment logs are captured and can be viewed with:
```bash
# Complete deployment logs
docker-compose logs > deployment-logs.txt

# Real-time logs
docker-compose logs -f
```

### API Documentation

- **Base URL**: `http://localhost:8081/user-service/api/`
- **Swagger UI**: `http://localhost:8081/user-service/swagger-ui/`
- **Actuator**: `http://localhost:8081/user-service/actuator/`

---

## 🎉 Deployment Complete!

Your Smart Inter Wilaya Taxi platform is now deployed and ready for use! 

**Access your application**: http://localhost:8081/user-service/api/health

**API Base URL**: http://localhost:8081/user-service/api/