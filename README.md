# K8s Observability Stack

This repository contains a simple .NET 8 web API with a corresponding worker,
containerized and deployable to Azure Kubernetes Service (AKS). It includes
Terraform for infrastructure (VNet + AKS) and a Prometheus/Grafana monitoring
stack via Helm.

## Quick start

cd infra && terraform init
[0m[1mInitializing the backend...[0m
az aks get-credentials --resource-group  --name erijon-aks --overwrite-existing
# Rubric: Idempotent apply for K8s objects
kubectl apply -f k8s/

## Local development

The API lives in pp/api; you can build and run it locally via Docker:

docker build -t erijonh/erijon-api:local -f app/api/Dockerfile app/api
docker build -t erijonh/erijon-api:local -f app/api/Dockerfile app/api
Starting container erijon-api-local-8081 on host port 8081...
docker run --rm -p 8081:80 --name erijon-api-local-8081 -d erijonh/erijon-api:local
Stopping container erijon-api-local-8081...
docker rm -f erijon-api-local-8081 || true
erijon-api-local-8081

## CI / CD

A GitHub Actions workflow at .github/workflows/docker-publish.yml builds and
pushes both the API and worker images to Docker Hub on each push to main.

To enable it you must add two repository secrets (Settings  Secrets & variables
 Actions):

- DOCKERHUB_USERNAME  your Docker Hub user name (erijonh)
- DOCKERHUB_TOKEN  a Docker Hub access token (create one under Account 
  Security on Docker Hub)

After pushing changes to main the workflow will run automatically; you can
also manually queue it via gh workflow run docker-publish.yml.

## Terraform infrastructure

infra/ contains Terraform modules:

* net_aks.tf  virtual network and delegated subnet for AKS
* main.tf  AKS cluster definition (uses variables defined in
  ariables.tf)
* monitoring.tf  Helm release for the kube-prometheus-stack

Sensitive values such as subscription ID and resource group name belong in a
	erraform.tfvars file (see 	erraform.tfvars.example).

### Commands

cd infra && terraform init
[0m[1mInitializing the backend...[0m
cd infra && terraform apply -auto-approve
cd infra && terraform destroy -auto-approve

## Kubernetes manifests

The k8s/ directory contains YAML for:

* deployment.yaml  API deployment (image reference updated by Makefile)
* service.yaml  LoadBalancer service exposing the API
* hpa.yaml  horizontal pod autoscaler (based on CPU)

These are applied by make deploy.

## Monitoring

A Prometheus/Grafana stack is installed by Terraform using Helm in the monitoring.tf file.  The API deployment includes Prometheus scrape annotations so /metrics is collected automatically.

## Notes

- Remember to revoke any exposed tokens and generate new ones.
- GitHub repo is https://github.com/erijonh06/k8s-observability-ricloud.

Feel free to extend with additional services or CI steps.
