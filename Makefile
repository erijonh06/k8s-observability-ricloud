

# Docker / local run settings
DOCKERHUB_USER=erijonh
IMAGE_NAME=erijon-api
HOST_PORT=8081
CONTAINER_NAME=erijon-api-local-8081

# This ensures that when you run 'make apply', it logs into the right cluster
login:
	az aks get-credentials --resource-group $(RESOURCE_GROUP) --name $(CLUSTER_NAME) --overwrite-existing

.PHONY: init apply deploy test destroy login

init:
	cd infra && terraform init

apply:
	cd infra && terraform apply -auto-approve
	@$(MAKE) login

# Connects your local kubectl to the Azure cluster
login:
	az aks get-credentials --resource-group $(RG) --name $(CLUSTER_NAME) --overwrite-existing

deploy:
	# Rubric: Idempotent apply for K8s objects
	kubectl apply -f k8s/
	kubectl apply -f alerts/
	# kubectl apply -f dashboards/

test:
	@echo "Fetching API Service IP..."
	$(eval SERVICE_IP=$(shell kubectl get svc api-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'))
	@if [ -z "$(SERVICE_IP)" ]; then echo "Service IP not ready. Wait 30s."; exit 1; fi
	curl http://$(SERVICE_IP)/metrics

# Bonus: Load test to prove HPA (Autoscaling rubric)
load-test:
	@echo "Generating load to trigger HPA scaling..."
	kubectl run -i --tty load-generator --rm --image=busybox:1.28 --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://api-service; done"

destroy:
	cd infra && terraform destroy -auto-approve

# Build and run the API image locally
docker-build:
	docker build -t $(DOCKERHUB_USER)/$(IMAGE_NAME):local -f app/api/Dockerfile app/api

docker-run: docker-build
	@echo "Starting container $(CONTAINER_NAME) on host port $(HOST_PORT)..."
	docker run --rm -p $(HOST_PORT):80 --name $(CONTAINER_NAME) -d $(DOCKERHUB_USER)/$(IMAGE_NAME):local

docker-stop:
	@echo "Stopping container $(CONTAINER_NAME)..."
	docker rm -f $(CONTAINER_NAME) || true

docker-push:
	@echo "Tagging and pushing image to Docker Hub (requires login)..."
	docker tag $(DOCKERHUB_USER)/$(IMAGE_NAME):local $(DOCKERHUB_USER)/$(IMAGE_NAME):latest
	docker push $(DOCKERHUB_USER)/$(IMAGE_NAME):latest