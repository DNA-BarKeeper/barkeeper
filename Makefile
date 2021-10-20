secret:
	@echo "Generating a secret key..."
	@docker-compose run --user "$(id -u):$(id -g)" app rails secret

install:
	@echo "Installing Barcode Workflow Manager..."
	@echo "Creating volumes..."
	@docker volume create --name bwm-redis
	@docker volume create --name bwm-postgres

	@echo "Setting up database..."
	@docker-compose run --user "$(id -u):$(id -g)" app rails db:reset
	@docker-compose run --user "$(id -u):$(id -g)" app rails db:seed

	@echo "Precompiling assets..."
	@docker-compose run --user "$(id -u):$(id -g)" app rails assets:precompile

	@echo "Starting Barcode Workflow Manager..."
	@docker-compose up -d

start:
	@echo "Starting Barcode Workflow Manager..."
	@docker-compose up -d

stop:
	@echo "Stopping Barcode Workflow Manager..."
	@docker-compose down

remove:
	@echo "Removing Barcode Workflow Manager containers..."
	@docker-compose rm -s -v -f

restart: remove start

start-dev:
	@echo "Starting Barcode Workflow Manager..."
	@docker-compose -f docker-compose.yml -f docker-compose.dev.yml up

restart-dev: remove start-dev
