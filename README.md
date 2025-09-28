# Gotham Time Manager - Backend

Phoenix/Elixir backend with Vue.js frontend for time tracking and analytics.

## 🚀 Quick Start with Docker Compose

### Prerequisites
- Docker
- Docker Compose

### Deploy All Services
```bash
# Start database, backend, and frontend
docker-compose up --build -d

# View logs
docker-compose logs -f

# Stop all services
docker-compose down
```

### Access the Application
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:4000/api
- **Database**: localhost:5432

## 📊 Features

### Time Tracking
- Clock in/out functionality
- Working time calculation
- Manual time entry management
- Date range filtering

### Analytics & Charts
- Daily/Weekly/Monthly views
- Interactive charts (Bar, Pie, Scatter)
- Working hours visualization
- Clock activity analysis

### User Management
- User registration and authentication
- Role-based access control
- Profile management

## 🛠️ Development Setup

### Backend Only
```bash
# Install dependencies
mix deps.get

# Setup database
mix ecto.create
mix ecto.migrate

# Seed with sample data
mix run priv/repo/seeds.exs

# Start development server
mix phx.server
```

### Frontend Only
```bash
cd ../frontend-timemanager
npm install
npm run dev
```

## 📈 Sample Data

The application includes 90 days of realistic sample data:
- **12 Users** with different work patterns
- **Working Times** with realistic schedules
- **Clock Entries** for each work session

### Sample Users
- **admin@gotham.com** (Bruce Wayne) - General Manager
- **manager@gotham.com** (Alfred Pennyworth) - Manager
- **john.doe@example.com** (John Doe) - Employee

## 🔧 API Endpoints

### Users
- `GET /api/users` - List users
- `POST /api/users` - Create user
- `GET /api/users/:id` - Get user
- `PUT /api/users/:id` - Update user
- `DELETE /api/users/:id` - Delete user

### Working Times
- `GET /api/workingtime/:userID` - Get working times
- `POST /api/workingtime/:userID` - Create working time
- `PUT /api/workingtime/:id` - Update working time
- `DELETE /api/workingtime/:id` - Delete working time

### Clock In/Out
- `GET /api/clocks/:userID` - Get clock entries
- `POST /api/clocks/:userID` - Toggle clock in/out

## 🐳 Docker Services

- **db**: PostgreSQL 15 database
- **web**: Phoenix backend API
- **frontend**: Vue.js frontend application

All services include health checks and automatic dependency management.

## 📝 Troubleshooting

### View Logs
```bash
# All services
docker-compose logs

# Specific service
docker-compose logs web
docker-compose logs frontend
docker-compose logs db
```

### Reset Database
```bash
docker-compose down -v
docker-compose up --build -d
```

### Check Service Status
```bash
docker-compose ps
```