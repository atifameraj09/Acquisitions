# Acquisitions API - Dockerized with Neon Database

A Node.js Express API application with Neon Database support, fully dockerized for both development and production environments.

## 🏗️ Architecture Overview

This application is designed to work seamlessly in both development and production environments:

- **Development**: Uses Neon Local via Docker for local development
- **Production**: Uses Neon Cloud Database for production deployments

## 📋 Prerequisites

- Docker Desktop installed and running
- Docker Compose V2
- Node.js 18+ (for local development without Docker)
- Git

## 🚀 Quick Start

### Option 1: Using Setup Scripts (Recommended)

#### Windows (PowerShell)
```powershell
# Start development environment
.\setup-docker.ps1 dev

# Start production environment
$env:DATABASE_URL = "your_neon_connection_string"
$env:ARCJET_KEY = "your_arcjet_key"
.\setup-docker.ps1 prod
```

#### Linux/Mac (Bash)
```bash
# Make script executable
chmod +x setup-docker.sh

# Start development environment
./setup-docker.sh dev

# Start production environment
export DATABASE_URL="your_neon_connection_string"
export ARCJET_KEY="your_arcjet_key"
./setup-docker.sh prod
```

### Option 2: Using NPM Scripts

#### Development Environment (with Neon Local)

1. **Clone the repository**
   ```bash
   git clone https://github.com/atifameraj09/Acquisitions.git
   cd Acquisitions
   ```

2. **Start the development environment**
   ```bash
   npm run docker:dev:up
   ```

   This will:
   - Build the application Docker image
   - Start Neon Local proxy
   - Start the application connected to Neon Local
   - Set up networking between services

3. **Access the application**
   - API: http://localhost:3000
   - Health check: http://localhost:3000/health
   - Database Admin (optional): http://localhost:8080

4. **View logs**
   ```bash
   npm run docker:dev:logs
   ```

5. **Stop the development environment**
   ```bash
   npm run docker:dev:down
   ```

### Production Environment (with Neon Cloud)

1. **Set environment variables**
   ```bash
   export DATABASE_URL="postgresql://neondb_owner:your_password@ep-xxx.aws.neon.tech/neondb?sslmode=require"
   export ARCJET_KEY="your_arcjet_production_key"
   ```

2. **Start production environment**
   ```bash
   npm run docker:prod:up
   ```

3. **View production logs**
   ```bash
   npm run docker:prod:logs
   ```

## 🔧 Configuration

### Environment Variables

#### Development (.env.development)
```env
PORT=3000
NODE_ENV=development
LOG_LEVEL=debug
DATABASE_URL=postgresql://user:password@neon-local:5432/neondb
ARCJET_KEY=your_development_key
DEBUG=true
ENABLE_CORS=true
```

#### Production (.env.production)
```env
PORT=3000
NODE_ENV=production
LOG_LEVEL=info
DATABASE_URL=${DATABASE_URL}  # Set via environment variable
ARCJET_KEY=${ARCJET_KEY}      # Set via environment variable
DEBUG=false
ENABLE_CORS=false
HELMET_ENABLED=true
RATE_LIMIT_ENABLED=true
```

## 🐳 Docker Commands

### Development Commands
| Command | Description |
|---------|-------------|
| `npm run docker:dev:up` | Start development environment |
| `npm run docker:dev:down` | Stop development environment |
| `npm run docker:dev:logs` | View development logs |
| `npm run docker:dev:clean` | Clean development environment (removes volumes) |
| `npm run docker:dev:db-admin` | Start database admin interface |

### Production Commands
| Command | Description |
|---------|-------------|
| `npm run docker:prod:up` | Start production environment |
| `npm run docker:prod:down` | Stop production environment |
| `npm run docker:prod:logs` | View production logs |
| `npm run docker:prod:clean` | Clean production environment |

### Build Commands
| Command | Description |
|---------|-------------|
| `npm run docker:build:dev` | Build development image |
| `npm run docker:build:prod` | Build production image |

## 🗄️ Database Setup

### Development with Neon Local

Neon Local automatically:
- Creates ephemeral branches for development and testing
- Provides PostgreSQL-compatible interface
- Handles database initialization
- Manages connection pooling

### Production with Neon Cloud

1. **Create a Neon project** at https://console.neon.tech
2. **Get your connection string** from the Neon console
3. **Set the DATABASE_URL** environment variable in your deployment

## 📁 Project Structure

```
├── src/
│   ├── app.js              # Express application setup
│   ├── server.js           # Server configuration
│   ├── index.js            # Application entry point
│   ├── config/
│   │   ├── database.js     # Database connection
│   │   └── logger.js       # Logging configuration
│   ├── controllers/        # Route controllers
│   ├── middleware/         # Custom middleware
│   ├── models/            # Database models (Drizzle)
│   ├── routes/            # API routes
│   ├── services/          # Business logic
│   └── utils/             # Utility functions
├── drizzle/               # Database migrations
├── logs/                  # Application logs
├── Dockerfile             # Multi-stage Docker build
├── docker-compose.dev.yml # Development environment
├── docker-compose.prod.yml# Production environment
├── .env.development       # Development configuration
├── .env.production        # Production configuration
└── package.json           # Dependencies and scripts
```

## 🔄 Development Workflow

### Local Development with Docker

1. **Start the development environment**
   ```bash
   npm run docker:dev:up
   ```

2. **Make code changes** - The application will automatically reload thanks to volume mounts

3. **Run database migrations** (if needed)
   ```bash
   docker-compose -f docker-compose.dev.yml exec app npm run db:migrate
   ```

4. **Generate Drizzle schema** (if needed)
   ```bash
   docker-compose -f docker-compose.dev.yml exec app npm run db:generate
   ```

5. **Access database admin** (optional)
   ```bash
   npm run docker:dev:db-admin
   ```
   Then visit http://localhost:8080

### Without Docker (Traditional)

1. **Install dependencies**
   ```bash
   npm install
   ```

2. **Set up environment**
   ```bash
   cp .env.development .env
   ```

3. **Start development server**
   ```bash
   npm run dev
   ```

## 🚀 Production Deployment

### Using Docker Compose

1. **Set environment variables**
   ```bash
   export DATABASE_URL="your_neon_cloud_connection_string"
   export ARCJET_KEY="your_production_arcjet_key"
   ```

2. **Deploy**
   ```bash
   npm run docker:prod:up
   ```

### Using Docker Swarm/Kubernetes

The production Dockerfile is optimized for container orchestration:

```bash
# Build production image
docker build --target production -t acquisitions:latest .

# Push to registry
docker tag acquisitions:latest your-registry/acquisitions:latest
docker push your-registry/acquisitions:latest
```

### Environment Variables for Production

Required environment variables:
- `DATABASE_URL`: Neon Cloud connection string
- `ARCJET_KEY`: Production Arcjet API key
- `NODE_ENV`: Set to "production"
- `PORT`: Application port (default: 3000)

Optional environment variables:
- `LOG_LEVEL`: Logging level (default: "info")
- `CACHE_TTL`: Cache TTL in seconds (default: 3600)

## 🔍 Monitoring and Logging

### Health Checks

- **Application Health**: http://localhost:3000/health
- **Docker Health Check**: Built into production container

### Logging

- **Development**: Detailed logs with debug information
- **Production**: Structured logs with info level and above
- **Log Files**: Available in `./logs/` directory

### Monitoring

Production setup includes:
- Health check endpoints
- Resource limits and reservations
- Restart policies
- Optional Nginx reverse proxy
- Optional log aggregation with Fluentd

## 🧪 Testing

### Running Tests in Docker

```bash
# Run tests in development container
docker-compose -f docker-compose.dev.yml exec app npm test

# Run linting
docker-compose -f docker-compose.dev.yml exec app npm run lint

# Format code
docker-compose -f docker-compose.dev.yml exec app npm run format
```

## 🛠️ Troubleshooting

### Common Issues

1. **Port already in use**
   ```bash
   # Check what's using the port
   netstat -tulpn | grep :3000
   # Stop the conflicting service or change the port
   ```

2. **Docker build fails**
   ```bash
   # Clean Docker cache
   docker system prune -a
   # Rebuild without cache
   docker-compose -f docker-compose.dev.yml build --no-cache
   ```

3. **Database connection issues**
   ```bash
   # Check Neon Local container logs
   docker-compose -f docker-compose.dev.yml logs neon-local
   
   # Restart database service
   docker-compose -f docker-compose.dev.yml restart neon-local
   ```

4. **Application won't start**
   ```bash
   # Check application logs
   npm run docker:dev:logs
   
   # Verify environment variables
   docker-compose -f docker-compose.dev.yml exec app env
   ```

### Database Issues

1. **Reset development database**
   ```bash
   npm run docker:dev:clean
   npm run docker:dev:up
   ```

2. **Connection to Neon Cloud fails**
   - Verify your connection string is correct
   - Check if your IP is whitelisted (if applicable)
   - Ensure SSL mode is set correctly

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make changes and test them with `npm run docker:dev:up`
4. Commit your changes: `git commit -am 'Add feature'`
5. Push to the branch: `git push origin feature-name`
6. Submit a pull request

## 📝 License

This project is licensed under the ISC License - see the package.json file for details.

## 🔗 Links

- [Neon Database](https://neon.tech)
- [Neon Local Documentation](https://neon.tech/docs/guides/neon-local)
- [Docker Documentation](https://docs.docker.com)
- [Express.js Documentation](https://expressjs.com)
- [Drizzle ORM Documentation](https://orm.drizzle.team)