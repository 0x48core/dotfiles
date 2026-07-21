# Google Cloud Setup Guide

## Install

```bash
./scripts/setup-gcloud.sh [PROJECT_ID]
```

Or manually:

```bash
brew install --cask google-cloud-sdk

# Additional components
gcloud components install gke-gcloud-auth-plugin kubectl beta
```

---

## Authentication

```bash
# Login with your Google account (browser-based)
gcloud auth login

# Application Default Credentials (used by SDKs / Terraform)
gcloud auth application-default login

# Service account key (CI / non-interactive)
gcloud auth activate-service-account --key-file=sa-key.json
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/sa-key.json"

# Check active accounts
gcloud auth list

# Revoke
gcloud auth revoke
```

---

## Project & config

```bash
# List projects
gcloud projects list

# Set active project
gcloud config set project YOUR_PROJECT_ID

# Set default region / zone
gcloud config set compute/region us-central1
gcloud config set compute/zone  us-central1-a

# View current config
gcloud config list

# Named configurations (switch between projects/envs)
gcloud config configurations create work
gcloud config configurations activate work
gcloud config configurations list
```

---

## GKE — Google Kubernetes Engine

```bash
# Create a cluster
gcloud container clusters create my-cluster \
  --region us-central1 \
  --num-nodes 3 \
  --machine-type e2-standard-4 \
  --enable-autoscaling --min-nodes 1 --max-nodes 5 \
  --workload-pool=$(gcloud config get-value project).svc.id.goog

# Get credentials (sets kubectl context)
gcloud container clusters get-credentials my-cluster --region us-central1

# List clusters
gcloud container clusters list

# Delete cluster
gcloud container clusters delete my-cluster --region us-central1
```

---

## Artifact Registry — container images

```bash
# Create a repo
gcloud artifacts repositories create my-repo \
  --repository-format docker \
  --location us-central1

# Authenticate Docker with Artifact Registry
gcloud auth configure-docker us-central1-docker.pkg.dev

# Build & push
PROJECT=$(gcloud config get-value project)
IMAGE="us-central1-docker.pkg.dev/$PROJECT/my-repo/myapp"

docker build -t "$IMAGE:latest" .
docker push "$IMAGE:latest"

# List images
gcloud artifacts docker images list us-central1-docker.pkg.dev/$PROJECT/my-repo
```

---

## Cloud Run — serverless containers

```bash
# Deploy
gcloud run deploy myapp \
  --image us-central1-docker.pkg.dev/$PROJECT/my-repo/myapp:latest \
  --region us-central1 \
  --platform managed \
  --allow-unauthenticated \
  --port 8080 \
  --memory 512Mi \
  --cpu 1 \
  --min-instances 0 \
  --max-instances 10

# List services
gcloud run services list --region us-central1

# Get URL
gcloud run services describe myapp --region us-central1 \
  --format "value(status.url)"

# View logs
gcloud run services logs read myapp --region us-central1 --limit 50

# Delete
gcloud run services delete myapp --region us-central1
```

---

## Cloud SQL — managed Postgres

```bash
# Create instance
gcloud sql instances create my-pg \
  --database-version POSTGRES_16 \
  --region us-central1 \
  --tier db-f1-micro \
  --storage-size 10GB

# Create database & user
gcloud sql databases create mydb --instance my-pg
gcloud sql users create myuser --instance my-pg --password secret

# Connect via Cloud SQL Proxy (recommended)
brew install cloud-sql-proxy
cloud-sql-proxy "$PROJECT:us-central1:my-pg" --port 5432 &

psql "host=127.0.0.1 port=5432 dbname=mydb user=myuser password=secret"

# Connection string for apps
DATABASE_URL="postgres://myuser:secret@127.0.0.1:5432/mydb?sslmode=disable"
```

---

## Cloud Storage — GCS

```bash
# Create bucket
gsutil mb -l us-central1 gs://my-bucket-name

# Upload / download
gsutil cp file.txt gs://my-bucket-name/
gsutil cp gs://my-bucket-name/file.txt .

# List
gsutil ls gs://my-bucket-name/

# Make public
gsutil iam ch allUsers:objectViewer gs://my-bucket-name

# Delete
gsutil rm gs://my-bucket-name/file.txt
gsutil rb gs://my-bucket-name     # remove bucket
```

---

## Secret Manager

```bash
# Create a secret
echo -n "my-secret-value" | gcloud secrets create my-secret --data-file=-

# Add a new version
echo -n "updated-value" | gcloud secrets versions add my-secret --data-file=-

# Access latest version
gcloud secrets versions access latest --secret my-secret

# List secrets
gcloud secrets list

# Delete
gcloud secrets delete my-secret
```

---

## IAM — Service Accounts

```bash
# Create service account
gcloud iam service-accounts create my-sa \
  --display-name "My Service Account"

# Grant a role
gcloud projects add-iam-policy-binding $PROJECT \
  --member "serviceAccount:my-sa@$PROJECT.iam.gserviceaccount.com" \
  --role "roles/container.developer"

# Create and download a key
gcloud iam service-accounts keys create sa-key.json \
  --iam-account my-sa@$PROJECT.iam.gserviceaccount.com

# List service accounts
gcloud iam service-accounts list
```

---

## Useful shortcuts

```bash
# Open GCP console in browser
gcloud console

# Stream logs
gcloud logging tail "resource.type=cloud_run_revision"

# SSH into a Compute Engine VM
gcloud compute ssh my-vm --zone us-central1-a

# Cost estimate
gcloud billing budgets list
```

---

## Terraform with GCP

```hcl
provider "google" {
  project = "your-project-id"
  region  = "us-central1"
}

resource "google_container_cluster" "primary" {
  name     = "my-cluster"
  location = "us-central1"

  initial_node_count = 1
  deletion_protection = false
}
```

```bash
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/sa-key.json"
terraform init
terraform plan
terraform apply
```
