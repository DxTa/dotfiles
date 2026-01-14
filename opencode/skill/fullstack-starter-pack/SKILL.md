# Fullstack Starter Pack

Fullstack development starter pack for React, Express/FastAPI, database design, and deployment.

## When to Use

Use this skill when:
- Starting a new fullstack project
- Setting up project structure and tooling
- Choosing tech stack and frameworks
- Implementing authentication
- Setting up database and ORM
- Configuring API endpoints
- Deploying fullstack applications
- Implementing CI/CD pipelines

## Tech Stack Options

### Frontend
- **React**: Component-based UI library
- **Next.js**: React framework with SSR/SSG
- **Vue.js**: Progressive framework
- **Svelte**: Reactive framework
- **UI Libraries**: Material-UI, Tailwind, shadcn/ui

### Backend
- **Express**: Minimal Node.js framework
- **FastAPI**: Modern Python framework
- **Django**: Full-featured Python framework
- **NestJS**: Enterprise Node.js framework

### Database
- **PostgreSQL**: Relational database
- **MongoDB**: NoSQL document store
- **MySQL/MariaDB**: Relational database
- **SQLite**: Lightweight relational
- **ORMs**: Prisma, TypeORM, Sequelize, SQLAlchemy

### Deployment
- **Vercel/Netlify**: Frontend hosting
- **AWS/GCP/Azure**: Cloud providers
- **Docker/Kubernetes**: Containerization
- **Railway/Render**: PaaS solutions

## Project Structure

### Monorepo Structure
```
my-app/
├── packages/
│   ├── frontend/          # React app
│   ├── backend/           # API server
│   └── shared/           # Shared types/utilities
├── docker-compose.yml
├── package.json
└── turbo.json            # Build orchestration
```

### Multi-repo Structure
```
frontend/
├── src/
│   ├── components/
│   ├── pages/
│   └── api/
├── public/
└── package.json

backend/
├── src/
│   ├── routes/
│   ├── models/
│   ├── controllers/
│   └── middleware/
├── tests/
└── package.json
```

## Starter Templates

### React + Express Starter
```bash
# Initialize project
npx create-react-app frontend
mkdir backend && cd backend
npm init -y
npm install express cors dotenv

# Basic Express server
const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

app.get('/api/health', (req, res) => {
  res.json({ status: 'ok' });
});

app.listen(3001, () => {
  console.log('Server running on port 3001');
});
```

### React + FastAPI Starter
```bash
# Frontend
npx create-react-app frontend

# Backend
mkdir backend
cd backend
python -m venv venv
source venv/bin/activate
pip install fastapi uvicorn

# FastAPI app
from fastapi import FastAPI, CORS
from pydantic import BaseModel

app = FastAPI()

app.add_middleware(
    CORS,
    allow_origins=["http://localhost:3000"],
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/api/health")
def health():
    return {"status": "ok"}

# Run with: uvicorn main:app --reload
```

## Database Setup

### PostgreSQL with Prisma
```bash
npm install prisma @prisma/client
npx prisma init

# schema.prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

generator client {
  provider = "prisma-client-js"
}

model User {
  id    Int    @id @default(autoincrement())
  email String @unique
  name  String
}

# Generate client
npx prisma generate
```

### MongoDB with Mongoose
```bash
npm install mongoose

// models/User.js
const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true }
});

module.exports = mongoose.model('User', userSchema);
```

## Authentication

### JWT Authentication
```javascript
// backend/middleware/auth.js
const jwt = require('jsonwebtoken');

function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) return res.sendStatus(401);

  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) return res.sendStatus(403);
    req.user = user;
    next();
  });
}

// Use in routes
app.get('/api/protected', authenticateToken, (req, res) => {
  res.json({ message: 'Protected data', user: req.user });
});
```

### OAuth Integration
```javascript
// backend/routes/auth.js
const passport = require('passport');
const GoogleStrategy = require('passport-google-oauth20').Strategy;

passport.use(new GoogleStrategy({
  clientID: process.env.GOOGLE_CLIENT_ID,
  clientSecret: process.env.GOOGLE_CLIENT_SECRET,
  callbackURL: "/auth/google/callback"
}, (accessToken, refreshToken, profile, done) => {
  // Find or create user
  return done(null, profile);
}));

app.get('/auth/google', passport.authenticate('google'));

app.get('/auth/google/callback',
  passport.authenticate('google', { failureRedirect: '/login' }),
  (req, res) => {
    res.redirect('/');
  }
);
```

## API Design

### RESTful API
```javascript
// routes/users.js
const express = require('express');
const router = express.Router();
const User = require('../models/User');

// GET /api/users
router.get('/', async (req, res) => {
  const users = await User.find();
  res.json(users);
});

// POST /api/users
router.post('/', async (req, res) => {
  const user = new User(req.body);
  await user.save();
  res.status(201).json(user);
});

// GET /api/users/:id
router.get('/:id', async (req, res) => {
  const user = await User.findById(req.params.id);
  if (!user) return res.status(404).send('Not found');
  res.json(user);
});

// PUT /api/users/:id
router.put('/:id', async (req, res) => {
  const user = await User.findByIdAndUpdate(req.params.id, req.body, { new: true });
  res.json(user);
});

// DELETE /api/users/:id
router.delete('/:id', async (req, res) => {
  await User.findByIdAndDelete(req.params.id);
  res.status(204).send();
});

module.exports = router;
```

## Frontend Setup

### API Client (Axios)
```javascript
// src/api/client.js
import axios from 'axios';

const client = axios.create({
  baseURL: process.env.REACT_APP_API_URL || 'http://localhost:3001',
  headers: {
    'Content-Type': 'application/json'
  }
});

// Request interceptor for auth
client.interceptors.request.use(config => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Response interceptor for errors
client.interceptors.response.use(
  response => response,
  error => {
    if (error.response?.status === 401) {
      // Redirect to login
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export default client;
```

### React Hooks
```javascript
// src/hooks/useUsers.js
import { useState, useEffect } from 'react';
import client from '../api/client';

export function useUsers() {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    async function fetchUsers() {
      try {
        setLoading(true);
        const response = await client.get('/api/users');
        setUsers(response.data);
      } catch (err) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    }

    fetchUsers();
  }, []);

  return { users, loading, error };
}
```

## Deployment

### Docker Setup
```dockerfile
# Dockerfile for frontend
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build
EXPOSE 3000
CMD ["npm", "start"]
```

```dockerfile
# Dockerfile for backend
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --production
COPY . .
EXPOSE 3001
CMD ["node", "server.js"]
```

### docker-compose.yml
```yaml
version: '3.8'
services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  backend:
    build: ./backend
    depends_on:
      - postgres
    environment:
      DATABASE_URL: postgresql://user:password@postgres:5432/myapp
    ports:
      - "3001:3001"

  frontend:
    build: ./frontend
    depends_on:
      - backend
    ports:
      - "3000:3000"

volumes:
  postgres_data:
```

## CI/CD Pipeline

### GitHub Actions
```yaml
name: CI/CD

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
      - run: npm install
      - run: npm test

  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Deploy to Vercel
        uses: amondnet/vercel-action@v20
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.ORG_ID }}
          vercel-project-id: ${{ secrets.PROJECT_ID }}
```

## Best Practices

### Project Organization
- Separate frontend and backend
- Use TypeScript for type safety
- Implement proper error handling
- Add logging and monitoring
- Write tests (unit, integration, e2e)

### Security
- Never commit secrets
- Validate all inputs
- Use environment variables
- Implement rate limiting
- Add CORS and helmet

### Performance
- Lazy load components
- Optimize images
- Use CDN for static assets
- Implement caching
- Database indexing

## File Patterns

Look for:
- `**/package.json`
- `**/requirements.txt`
- `**/docker-compose.yml`
- `**/Dockerfile`
- `**/.env.example`
- `**/src/**/*.{js,ts,jsx,tsx,py}`

## Keywords

Fullstack, React, Express, FastAPI, PostgreSQL, MongoDB, Prisma, authentication, JWT, OAuth, REST API, TypeScript, Docker, CI/CD, Vercel, deployment, monorepo
