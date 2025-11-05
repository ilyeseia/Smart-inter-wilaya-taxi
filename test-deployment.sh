#!/bin/bash

# Smart Inter Wilaya Taxi - Deployment Test Script
# This script tests all deployed services

echo "🧪 Testing Smart Inter Wilaya Taxi Deployment"
echo "================================================="

# Test variables
BASE_URL="http://localhost:8081/user-service/api"
HEALTH_URL="http://localhost:8081/user-service/api/health"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to test HTTP endpoint
test_endpoint() {
    local url=$1
    local description=$2
    local expected_status=${3:-200}
    
    echo -n "Testing $description... "
    
    response=$(curl -s -o /dev/null -w "%{http_code}" "$url")
    
    if [ "$response" = "$expected_status" ]; then
        echo -e "${GREEN}✅ PASS${NC} (HTTP $response)"
        return 0
    else
        echo -e "${RED}❌ FAIL${NC} (Expected $expected_status, got $response)"
        return 1
    fi
}

# Test 1: Health Check
echo -e "\n${YELLOW}🏥 Testing Health Checks${NC}"
test_endpoint "$HEALTH_URL" "User Service Health Check"

# Test 2: User Registration
echo -e "\n${YELLOW}👤 Testing User Registration${NC}"
registration_response=$(curl -s -X POST "$BASE_URL/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test.user@example.com",
    "password": "TestPassword123!",
    "firstName": "Test",
    "lastName": "User",
    "phoneNumber": "+1234567890",
    "city": "Test City",
    "wilaya": "Test Wilaya",
    "licenseNumber": "TEST123"
  }')

if echo "$registration_response" | grep -q "token"; then
    echo -e "${GREEN}✅ User Registration PASS${NC}"
    # Extract JWT token for next test
    JWT_TOKEN=$(echo "$registration_response" | grep -o '"token":"[^"]*' | cut -d'"' -f4)
else
    echo -e "${RED}❌ User Registration FAIL${NC}"
    echo "Response: $registration_response"
    JWT_TOKEN=""
fi

# Test 3: User Login
echo -e "\n${YELLOW}🔐 Testing User Login${NC}"
if [ -n "$JWT_TOKEN" ]; then
    login_response=$(curl -s -X POST "$BASE_URL/auth/login" \
      -H "Content-Type: application/json" \
      -d '{
        "email": "test.user@example.com",
        "password": "TestPassword123!"
      }')
    
    if echo "$login_response" | grep -q "token"; then
        echo -e "${GREEN}✅ User Login PASS${NC}"
        # Extract new token if different
        NEW_TOKEN=$(echo "$login_response" | grep -o '"token":"[^"]*' | cut -d'"' -f4)
        if [ -n "$NEW_TOKEN" ]; then
            JWT_TOKEN="$NEW_TOKEN"
        fi
    else
        echo -e "${RED}❌ User Login FAIL${NC}"
        echo "Response: $login_response"
    fi
else
    echo -e "${RED}⚠️  Skipping User Login (No JWT token available)${NC}"
fi

# Test 4: Protected Endpoint (User Profile)
echo -e "\n${YELLOW}🔒 Testing Protected Endpoint${NC}"
if [ -n "$JWT_TOKEN" ]; then
    profile_response=$(curl -s -H "Authorization: Bearer $JWT_TOKEN" \
      "$BASE_URL/users/1")
    
    if echo "$profile_response" | grep -q "firstName"; then
        echo -e "${GREEN}✅ User Profile Access PASS${NC}"
    else
        echo -e "${RED}❌ User Profile Access FAIL${NC}"
        echo "Response: $profile_response"
    fi
else
    echo -e "${RED}⚠️  Skipping User Profile Test (No JWT token available)${NC}"
fi

# Test 5: API Documentation
echo -e "\n${YELLOW}📚 Testing API Documentation${NC}"
test_endpoint "http://localhost:8081/user-service/v3/api-docs" "API Documentation"

# Test 6: Container Health Check
echo -e "\n${YELLOW}🐳 Testing Container Health${NC}"
echo -n "Checking Docker containers... "
container_status=$(docker-compose ps --format "table {{.Name}}\t{{.Status}}" | grep -E "(postgres|redis|user-service)")
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ PASS${NC}"
    echo "$container_status"
else
    echo -e "${RED}❌ FAIL${NC}"
fi

# Summary
echo -e "\n${YELLOW}📊 Test Summary${NC}"
echo "================================================="
echo "If all tests passed, your deployment is working correctly!"
echo ""
echo "🎉 Your Smart Inter Wilaya Taxi platform is now deployed!"
echo ""
echo "Next steps:"
echo "1. Configure production environment variables"
echo "2. Set up SSL/TLS certificates for HTTPS"
echo "3. Configure domain and DNS settings"
echo "4. Set up monitoring and alerting"
echo ""
echo "📖 For more information, see DEPLOYMENT.md"
echo "🌐 API Base URL: $BASE_URL"
echo "💊 Health Check: $HEALTH_URL"