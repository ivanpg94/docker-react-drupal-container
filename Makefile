include .env
export

.PHONY: install up down add-hosts remove-hosts

install:
	docker-compose up -d --build
	make add-hosts

up:
	@echo "Iniciando contenedores..."
	docker-compose up -d
	make add-hosts
	sudo chown -R 1000:1000 ./react
    sudo chown -R 1000:1000 ./drupal

down:
	@echo "Apagando contenedores..."
	docker-compose down
	make remove-hosts

add-hosts:
	@echo "Adding hosts entries..."
	@grep -q "$(DRUPAL_HOST)" /etc/hosts || (echo "127.0.0.1 $(DRUPAL_HOST)" | sudo tee -a /etc/hosts && echo "Added $(DRUPAL_HOST) to /etc/hosts")
	@grep -q "$(REACT_HOST)" /etc/hosts || (echo "127.0.0.1 $(REACT_HOST)" | sudo tee -a /etc/hosts && echo "Added $(REACT_HOST) to /etc/hosts")
	@grep -q "$(PHPMYADMIN_HOST)" /etc/hosts || (echo "127.0.0.1 $(PHPMYADMIN_HOST)" | sudo tee -a /etc/hosts && echo "Added $(PHPMYADMIN_HOST) to /etc/hosts")
	@echo "Current URLs:"
	@echo "Drupal URL: $(DRUPAL_HOST)"
	@echo "React URL: $(REACT_HOST)"
	@echo "phpMyAdmin URL: $(PHPMYADMIN_HOST)"

# Helper function to remove host entries
remove-hosts:
	@echo "Removing hosts entries..."
	@sudo sed -i "\#$(DRUPAL_HOST)#d" /etc/hosts
	@sudo sed -i "\#$(REACT_HOST)#d" /etc/hosts
	@sudo sed -i "\#$(PHPMYADMIN_HOST)#d" /etc/hosts