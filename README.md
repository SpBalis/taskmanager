# TaskManager – Spring Boot + Docker + Kubernetes + ArgoCD

This project is a minimal yet production-style REST API for task management, built using:

- ✅ Spring Boot 3.x (Java 21)
- 🐳 Docker
- ☸️ Kubernetes (via Minikube)
- 🔁 GitOps with ArgoCD
- 🛢 PostgreSQL (local & in-cluster)
- ⚙️ GitHub Actions for CI/CD

---

## 💡 What This Project Demonstrates

- How to build a Spring Boot app and expose a REST API
- Dockerizing a Java application using multi-stage builds
- Deploying it to Kubernetes with health checks and configuration management
- Setting up GitOps using ArgoCD to automatically sync Kubernetes resources from GitHub
- Automating Docker builds and GitHub pushes using GitHub Actions

---

## 🛠 Prerequisites

Make sure you have installed:

- Java 21 (Temurin or OpenJDK)
- Maven
- Git
- Docker
- Kubernetes CLI (`kubectl`)
- [Minikube](https://minikube.sigs.k8s.io/docs/start/) (or CRC/OpenShift)
- SSH access set up with GitHub (we use SSH URLs for pushing code)

---

## 📦 Local Setup

### 1. Clone and build the project

```bash
git clone git@github.com:SpBalis/taskmanager.git
cd taskmanager
mvn clean package -DskipTests
```

### 2. Run PostgreSQL locally (optional)

```bash
docker-compose up -d
```

### 3. Run locally

```bash
./mvnw spring-boot:run
```

Test endpoint:

```bash
curl http://localhost:8080/tasks
```

---

## 🐳 Docker Setup

### 1. Build Docker image

```bash
docker build -t spbalis/taskmanager:latest .
```

### 2. Push to Docker Hub

```bash
docker push spbalis/taskmanager:latest
```

### 3. Run locally with Docker

```bash
docker run --rm -p 8080:8080 spbalis/taskmanager:latest
```

---

## ☸️ Kubernetes Setup (Minikube)

### 1. Start Minikube with resources

```bash
minikube start --cpus=2 --memory=4096 --driver=docker
```

### 2. Apply Kubernetes manifests

```bash
kubectl apply -f k8s/
```

Includes:
- Deployment
- Service
- ConfigMap
- Secret
- (Optional) PostgreSQL deployment for in-cluster use

### 3. Access service

```bash
kubectl port-forward svc/taskmanager 8082:80
```

Visit: [http://localhost:8082/tasks](http://localhost:8082/tasks)

---

## 🔁 GitOps with ArgoCD

### 1. Install ArgoCD

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Wait until all pods are `Running`:

```bash
kubectl get pods -n argocd
```

### 2. Access the ArgoCD UI

```bash
kubectl port-forward svc/argocd-server -n argocd 8081:443
```

Open: https://localhost:8081

Retrieve admin password:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
```

### 3. Deploy ArgoCD Application

```bash
kubectl apply -f applications/taskmanager-app.yaml -n argocd
```

ArgoCD will automatically sync everything under `k8s/` into your cluster.

---

## ⚙️ GitHub Actions CI/CD

To automate Docker build and push on git push to `main`, create `.github/workflows/build.yml`:

```yaml
name: Build and Push Docker Image

on:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Login to DockerHub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: Build and push image
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: spbalis/taskmanager:latest
```

Then add the required secrets (`DOCKER_USERNAME`, `DOCKER_PASSWORD`) to your GitHub repo.

---

## 📁 Project Structure

```
taskmanager/
├── src/                         → Java source code
├── k8s/                         → Kubernetes manifests
├── applications/                → ArgoCD Application definition
├── .github/workflows/           → GitHub Actions CI/CD pipelines
├── Dockerfile                   → Multi-stage Docker build
├── docker-compose.yml           → Local PostgreSQL setup
├── application.yaml             → Spring Boot config
└── README.md                    → You're here
```

---

## ✅ Final Notes

- You can now deploy this app simply by `git push`
- ArgoCD will detect changes and update your cluster
- The app is fully containerized, configurable, and production-ready
