# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

L3 Mobile Development course project (Martinique, 2026). A full-stack app featuring Caribbean company data, with a Flutter mobile frontend, Laravel REST API backend, and Next.js web frontend.

## Repository Structure

```
mobileapp-2026/
├── project/
│   ├── firstapp/        # Flutter app with Transfer feature (active development)
│   └── secondapp/       # Flutter counter template
├── infrastructure/
│   ├── back-laravel/    # Laravel 12 REST API
│   ├── front-next/      # Next.js 16 web frontend (template, not yet integrated)
│   └── infra/           # Docker Compose + Nginx configuration
└── cm1_Intro_Ecosysteme.md  # Course material
```

## Commands

### Flutter Apps (`project/firstapp/` or `project/secondapp/`)
```bash
flutter pub get        # Install dependencies
flutter run            # Run on connected device/emulator
flutter run -d chrome  # Run as web app
flutter analyze        # Lint
flutter test           # Run tests
flutter clean          # Clean build cache
```

### Laravel Backend (`infrastructure/back-laravel/`)
```bash
composer run setup     # Full setup: install, .env, migrate, npm build
composer run dev       # Start dev server with hot-reload (Artisan + Queue + Vite)
composer run test      # Run PHPUnit tests
php artisan serve      # Start server manually (port 8001)
php artisan migrate    # Run migrations
```

### Next.js Frontend (`infrastructure/front-next/`)
```bash
npm run dev    # Development server
npm run build  # Production build
npm run lint   # ESLint
```

### Docker (`infrastructure/infra/`)
```bash
docker-compose up -d   # Start all services (DB, backend, frontend, nginx)
docker-compose down    # Stop all services
```

**Service ports:** Laravel: `8001` (direct) / `8000` (via Nginx), Next.js: `3000`, PostgreSQL: `5432`

## Architecture

### Flutter App (firstapp)

MVC-like pattern with three layers:

- **`models/`** — Data classes with `fromJson()` factory constructors (e.g., `TransferResponse`)
- **`services/`** — `ApiService` handles all HTTP calls using the `http` package
- **`screens/`** — `StatefulWidget` screens that call services and update UI via `setState()`

The API base URL is hardcoded as `http://localhost:8001/api` in `api_service.dart`. Change this for device testing (use machine's LAN IP instead of `localhost`).

### Laravel Backend

Standard Laravel MVC REST API. Key files:
- `routes/api.php` — API route definitions
- `app/Http/Controllers/ProductController.php` — Main controller
- `app/Models/Product.php` — Product model (`product_name`, `product_price`)
- `database/migrations/` — Schema definitions

Currently exposes `GET /api/products` returning all products as JSON. No authentication implemented yet.

### Docker Environment

The `.env` for Laravel uses `db` as the DB host (Docker service name). When running locally without Docker, change `DB_HOST=db` to `DB_HOST=127.0.0.1`.

### Database

PostgreSQL 16. Products table: `id`, `product_name`, `product_price` (decimal), timestamps.
