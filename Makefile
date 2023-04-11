secret:
	@echo "Generating a secret key..."
	@docker compose run --user "$(id -u):$(id -g)" app rails secret

install:
	@echo "Installing BarKeeper..."

	@echo "Setting up database..."
	@docker compose run --user "$(id -u):$(id -g)" app rails db:reset

	@echo "Precompiling assets..."
	@docker compose run --user "$(id -u):$(id -g)" app rails assets:precompile

	@echo "Starting BarKeeper..."
	@docker compose up -d

start:
	@echo "Starting BarKeeper..."
	@docker compose up -d

stop:
	@echo "Stopping BarKeeper..."
	@docker compose down

remove:
	@echo "Removing BarKeeper containers..."
	@docker compose rm -s -v -f

restart: remove start

start-dev:
	@echo "Starting BarKeeper in Development environment..."
	@docker compose -f docker-compose.yml -f docker-compose.dev.yml up

restart-dev: remove start-dev
