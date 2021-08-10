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
	@docker-compose up

secret:
	@echo "Generating a secret key..."
	@docker-compose run --user "$(id -u):$(id -g)" app rails secret

remove:
	@echo "Removing Barcode Workflow Manager containers..."
	@docker-compose rm -s -v -f

restart: remove start

stop:
	@echo "Stopping Barcode Workflow Manager..."
	@docker-compose down

start:
	@echo "Starting Barcode Workflow Manager..."
	@docker-compose up
