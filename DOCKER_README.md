# Student Management System - Docker Setup

This guide explains how to run the Student Management System using Docker for isolated development and testing.

## Prerequisites

- Docker Engine (20.10+)
- Docker Compose (2.0+)
- At least 4GB of available RAM
- At least 5GB of available disk space

## Quick Start

1. **Clone and navigate to the project directory**
   ```bash
   cd /path/to/student-management-system
   ```

2. **Configure environment variables**
   ```bash
   cp .env.docker .env
   # Edit .env with your actual configuration values
   ```

3. **Start the application**
   ```bash
   docker-compose up -d
   ```

4. **Wait for services to be healthy**
   ```bash
   docker-compose ps
   ```

5. **Access the application**
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:5007
   - Database: localhost:5432

## Services

### Database (PostgreSQL)
- **Image**: postgres:15-alpine
- **Port**: 5432
- **Database**: school_mgmt
- **Username**: postgres
- **Password**: postgres
- **Data Volume**: postgres_data

### Backend API (Node.js/Express)
- **Port**: 5007
- **Health Check**: http://localhost:5007/api/v1/health
- **Environment**: Configured via .env file

### Frontend (React/Caddy)
- **Port**: 3000
- **Build**: Multi-stage (Node.js build + Caddy serve)
- **Health Check**: HTTP status check

## Docker Commands

### Start Services
```bash
# Start in background
docker-compose up -d

# Start with logs
docker-compose up

# Start specific service
docker-compose up backend
```

### Stop Services
```bash
# Stop all services
docker-compose down

# Stop and remove volumes
docker-compose down -v

# Stop specific service
docker-compose stop frontend
```

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend

# Last 100 lines
docker-compose logs --tail=100 db
```

### Rebuild Services
```bash
# Rebuild all services
docker-compose build

# Rebuild and restart
docker-compose up --build

# Rebuild specific service
docker-compose build backend
```

### Database Management
```bash
# Connect to database
docker-compose exec db psql -U postgres -d school_mgmt

# Reset database
docker-compose down -v
docker-compose up -d db
```

## Environment Configuration

### Required Environment Variables

Copy `.env.docker` to `.env` and update the following values:

```env
# Generate secure random strings for these secrets
JWT_ACCESS_TOKEN_SECRET=your_secure_random_string_here
JWT_REFRESH_TOKEN_SECRET=your_secure_random_string_here
CSRF_TOKEN_SECRET=your_secure_random_string_here
EMAIL_VERIFICATION_TOKEN_SECRET=your_secure_random_string_here
PASSWORD_SETUP_TOKEN_SECRET=your_secure_random_string_here

# Email service (optional - comment out if not using)
RESEND_API_KEY=your_resend_api_key_here
MAIL_FROM_USER=noreply@yourdomain.com
```

### Generating Secure Secrets

```bash
# Generate random strings for secrets
openssl rand -hex 32
# or
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

## Development Workflow

### Making Code Changes

1. **Edit source code**
2. **Rebuild services**
   ```bash
   docker-compose up --build
   ```

### Database Schema Changes

1. **Update SQL files in `seed_db/`**
2. **Reset database**
   ```bash
   docker-compose down -v
   docker-compose up -d db
   ```

### Adding Dependencies

1. **Update `package.json` files**
2. **Rebuild affected services**
   ```bash
   docker-compose build backend
   docker-compose up -d backend
   ```

## Troubleshooting

### Common Issues

#### Services won't start
```bash
# Check logs
docker-compose logs

# Check service health
docker-compose ps

# Restart services
docker-compose restart
```

#### Database connection issues
```bash
# Check database logs
docker-compose logs db

# Test database connection
docker-compose exec backend node -e "require('pg').Pool({connectionString: process.env.DATABASE_URL}).connect().then(() => console.log('Connected')).catch(console.error)"
```

#### Port conflicts
```bash
# Check what's using ports
netstat -tulpn | grep :3000
netstat -tulpn | grep :5007
netstat -tulpn | grep :5432

# Change ports in docker-compose.yml
ports:
  - "3001:3000"  # Change host port
```

#### Out of disk space
```bash
# Clean up Docker
docker system prune -a

# Remove volumes
docker-compose down -v
```

### Health Checks

All services include health checks. Monitor them with:

```bash
# Check all services
docker-compose ps

# Check specific service
docker ps | grep school_mgmt
```

## Security Considerations

### For Production Use

1. **Change default database credentials**
2. **Use strong, unique secrets**
3. **Configure proper CORS settings**
4. **Enable HTTPS**
5. **Use environment-specific configurations**
6. **Regular security updates**

### Isolated Environment Benefits

- **No host system pollution**: Dependencies isolated in containers
- **Consistent environments**: Same setup across different machines
- **Easy cleanup**: Remove containers and volumes to reset
- **Security boundary**: Malicious code contained within containers

## File Structure

```
.
├── docker-compose.yml          # Service orchestration
├── Dockerfile.backend          # Backend container definition
├── Dockerfile.frontend         # Frontend container definition
├── .dockerignore              # Files to exclude from builds
├── .env.docker                # Environment template
├── backend/                   # Backend source code
├── frontend/                  # Frontend source code
└── seed_db/                   # Database initialization
```

## Support

If you encounter issues:

1. Check the logs: `docker-compose logs`
2. Verify environment variables
3. Ensure ports are available
4. Check Docker and Docker Compose versions
5. Review the main README.md for application-specific issues