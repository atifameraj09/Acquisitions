# Neon Database Configuration Guide

## 🎯 Current Status

✅ **Your Existing Neon Cloud Setup:**
- Database URL: `postgresql://neondb_owner:npg_Bynh18iqMxaZ@ep-rough-wind-a1k2rr7x-pooler.ap-southeast-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require`
- Arcjet Key: `ajkey_01k6vrf2c9eqjse6np9rmkhbxh`

## 🔧 Environment Configuration

### Development Environment (Neon Local)

For development, you have two options:

#### Option 1: Use Neon Local (Recommended for Development)
This creates a local PostgreSQL-like environment that mimics Neon's behavior:

1. **No additional Neon configuration needed** - Neon Local works independently
2. **Connection String**: `postgresql://user:password@neon-local:5432/neondb`
3. **Start with**: `npm run docker:dev:up`

#### Option 2: Use Your Neon Cloud Database for Development
If you prefer to use your actual Neon database for development:

1. **Update `.env.development`**:
   ```env
   DATABASE_URL=postgresql://neondb_owner:npg_Bynh18iqMxaZ@ep-rough-wind-a1k2rr7x-pooler.ap-southeast-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require
   ```

2. **Modify `docker-compose.dev.yml`** to remove the `neon-local` service and update the app service to not depend on it.

### Production Environment (Neon Cloud)

For production deployment, set these environment variables:

```bash
# PowerShell (Windows)
$env:DATABASE_URL = "postgresql://neondb_owner:npg_Bynh18iqMxaZ@ep-rough-wind-a1k2rr7x-pooler.ap-southeast-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require"
$env:ARCJET_KEY = "ajkey_01k6vrf2c9eqjse6np9rmkhbxh"

# Or Bash (Linux/Mac)
export DATABASE_URL="postgresql://neondb_owner:npg_Bynh18iqMxaZ@ep-rough-wind-a1k2rr7x-pooler.ap-southeast-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require"
export ARCJET_KEY="ajkey_01k6vrf2c9eqjse6np9rmkhbxh"
```

Then run: `npm run docker:prod:up`

## 🚀 Quick Start Commands

### Development with Neon Local (Recommended)
```bash
npm run docker:dev:up
```

### Development with Your Neon Cloud Database
1. First, update `.env.development` with your real DATABASE_URL
2. Then run:
```bash
npm run docker:dev:up
```

### Production with Your Neon Cloud Database
```powershell
# Set environment variables
$env:DATABASE_URL = "postgresql://neondb_owner:npg_Bynh18iqMxaZ@ep-rough-wind-a1k2rr7x-pooler.ap-southeast-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require"
$env:ARCJET_KEY = "ajkey_01k6vrf2c9eqjse6np9rmkhbxh"

# Start production
npm run docker:prod:up
```

## 🔐 Security Best Practices

### For Production:
1. **Get a separate Arcjet production key** from your Arcjet dashboard
2. **Use environment variables** instead of hardcoded values
3. **Consider using a secrets manager** for production deployments

### Neon Database Security:
- Your connection string already includes `sslmode=require` ✅
- Uses connection pooling with `-pooler` endpoint ✅
- Has `channel_binding=require` for additional security ✅

## 🧪 Testing Your Setup

### Test Development Environment:
```bash
npm run docker:dev:up
# Then visit: http://localhost:3000/health
```

### Test Production Environment:
```powershell
$env:DATABASE_URL = "your_connection_string"
$env:ARCJET_KEY = "your_key"
npm run docker:prod:up
# Then visit: http://localhost:3000/health
```

## 📋 Environment Files Summary

- **`.env`** - Your original file (kept as backup)
- **`.env.development`** - Development config with Neon Local
- **`.env.production`** - Production template (uses environment variables)

## 🆘 Troubleshooting

### Common Issues:

1. **Connection to Neon fails**:
   - Verify your connection string is correct
   - Check if your IP is whitelisted in Neon console
   - Ensure you're using the pooler endpoint

2. **Neon Local won't start**:
   - Make sure Docker is running
   - Check if port 5432 is available
   - Try: `npm run docker:dev:clean` then `npm run docker:dev:up`

3. **Environment variables not loading**:
   - Verify the `.env.*` files are in the project root
   - Make sure no extra spaces around `=` in env files
   - Check Docker logs: `npm run docker:dev:logs`