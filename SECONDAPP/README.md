
# Premium Mobile Banking App

This is a code bundle for Premium Mobile Banking App. The original project is available at https://www.figma.com/design/drujZvaK0EJspH7OUCFuYi/Premium-Mobile-Banking-App.

## Running the code

Run `npm i` to install the dependencies.

Run `npm run docker:up` to start the Docker database API on `http://localhost:3001`.

Run `npm run dev` to start the frontend.

If Docker is not running, the app still loads but dashboard data is empty.

## Docker API

- Database file: `docker/db.json`
- Docker service: `docker-compose.yml`
- API endpoint used by the frontend: `GET /dashboard`

You can stop Docker with `npm run docker:down`.
  