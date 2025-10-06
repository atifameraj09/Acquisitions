# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Development Commands

### Server Development
- `npm run dev` - Start development server with hot reload using Node.js `--watch` flag
- Server runs on `http://localhost:3000` by default

### Code Quality
- `npm run lint` - Run ESLint for code linting
- `npm run lint:fix` - Automatically fix linting issues
- `npm run format` - Format code with Prettier
- `npm run format:check` - Check code formatting without making changes

### Database Operations
- `npm run db:generate` - Generate Drizzle migration files from schema changes
- `npm run db:migrate` - Apply pending database migrations
- `npm run db:studio` - Launch Drizzle Studio for database management

## Architecture Overview

### Tech Stack
- **Runtime**: Node.js with ES modules (`"type": "module"`)
- **Framework**: Express.js with modern middleware stack (helmet, cors, morgan)
- **Database**: PostgreSQL via Neon serverless with Drizzle ORM
- **Authentication**: JWT tokens with bcrypt password hashing
- **Validation**: Zod schemas for request validation
- **Logging**: Winston with structured JSON logging

### Project Structure
The codebase uses path mapping aliases defined in package.json imports field:
- `#src/*` → `./src/*`
- `#config/*` → `./src/config/*`
- `#controllers/*` → `./src/controllers/*`
- `#middleware/*` → `./src/middleware/*`
- `#models/*` → `./src/models/*`
- `#routes/*` → `./src/routes/*`
- `#services/*` → `./src/services/*`
- `#utils/*` → `./src/utils/*`
- `#validations/*` → `./src/validations/*`

### Application Flow
1. **Entry Point**: `src/index.js` loads environment and starts server
2. **Server Setup**: `src/server.js` starts Express app on configured port
3. **App Configuration**: `src/app.js` sets up middleware, routes, and health endpoints
4. **Request Flow**: Routes → Controllers → Services → Models/Database

### Database Architecture
- **ORM**: Drizzle ORM with PostgreSQL dialect
- **Connection**: Neon serverless database via HTTP
- **Migrations**: Stored in `./drizzle/` directory
- **Schema**: Defined in `src/models/` with type-safe table definitions
- **Current Tables**: Users table with authentication fields

### Authentication System
- **Strategy**: JWT-based authentication with HTTP-only cookies
- **Password Security**: bcrypt hashing with salt rounds of 10
- **User Roles**: 'user' (default) and 'admin' roles
- **Endpoints**: 
  - `POST /api/auth/sign-up` - User registration
  - `POST /api/auth/sign-in` - User login
  - `POST /api/auth/sign-out` - User logout

### Error Handling & Logging
- **Logging**: Winston with file and console transports
- **Log Levels**: Configurable via LOG_LEVEL environment variable
- **Error Logs**: Stored in `logs/error.log`
- **Combined Logs**: Stored in `logs/combined.log`
- **Request Logging**: Morgan middleware with Winston integration

### Code Standards
- **ES Modules**: Uses import/export syntax throughout
- **ESLint Rules**: 2-space indentation, single quotes, semicolons required
- **Prettier Config**: 80-character line width, trailing commas (ES5), LF line endings
- **File Structure**: Follows MVC pattern with clear separation of concerns

## Environment Configuration

Required environment variables in `.env`:
- `PORT` - Server port (default: 3000)
- `NODE_ENV` - Environment mode (development/production)
- `LOG_LEVEL` - Winston logging level
- `DATABASE_URL` - PostgreSQL connection string for Neon database
- `JWT_SECRET` - Secret key for JWT token signing (uses fallback in development)

## Key Development Notes

### Database Schema Changes
1. Modify schema files in `src/models/`
2. Run `npm run db:generate` to create migration
3. Run `npm run db:migrate` to apply changes

### Adding New Routes
1. Create controller in `src/controllers/`
2. Create route file in `src/routes/`
3. Add route import and middleware in `src/app.js`
4. Add validation schemas in `src/validations/`

### Path Aliases
Use the configured path aliases (e.g., `#config/database.js`) instead of relative paths for cleaner imports and better maintainability.

### Validation Pattern
All endpoints use Zod schemas with `safeParse()` for request validation, returning formatted error messages via `formatValidationError()` utility.