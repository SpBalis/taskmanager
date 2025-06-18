# TaskManager – Spring Boot + Docker + Kubernetes + ArgoCD

This project is a minimal yet production-style REST API for task management, built using:

- ✅ Spring Boot 3.x (Java 21)
- 🐳 Docker
- ☸️ Kubernetes (via Minikube)
- 🔁 GitOps with ArgoCD
- 🛢 PostgreSQL (local & in-cluster)

---

## 💡 What This Project Demonstrates

- How to build a Spring Boot app and expose a REST API
- Dockerizing a Java application using multi-stage builds
- Deploying it to Kubernetes with health checks and configuration management
- Setting up GitOps using ArgoCD to automatically sync Kubernetes resources from GitHub

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
docker build -t taskmanager:latest .
```

### 2. Run locally with Docker

```bash
docker run --rm -p 8080:8080 taskmanager:latest
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
kubectl -n argocd get secret argocd-initial-admin-secret   -o jsonpath="{.data.password}" | base64 -d && echo
```

### 3. Deploy ArgoCD Application

The file `applications/taskmanager-app.yaml` defines a GitOps-managed Application pointing to this GitHub repo.

```bash
kubectl apply -f applications/taskmanager-app.yaml -n argocd
```

ArgoCD will automatically sync everything under `k8s/` into your cluster.

---

## 📁 Project Structure

```
taskmanager/
├── src/                         → Java source code
├── k8s/                         → Kubernetes manifests
├── applications/                → ArgoCD Application definition
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
