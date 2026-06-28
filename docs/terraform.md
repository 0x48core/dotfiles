# Terraform — Local Setup & Guide

Terraform provisions infrastructure as code. `tenv` manages multiple Terraform versions.

## Version management (tenv)

```bash
tenv tf install latest       # install latest
tenv tf install 1.9.0        # install specific version
tenv tf use 1.9.0            # set global default
tenv tf list                 # list installed versions
```

Pin per-project by adding a `.terraform-version` file:

```bash
echo "1.9.0" > .terraform-version
```

## Bootstrap a new project

```bash
./scripts/setup-terraform.sh myinfra
cd myinfra
cp terraform.tfvars.example terraform.tfvars
$EDITOR terraform.tfvars
```

## Core workflow

```bash
terraform init              # download providers & modules
terraform validate          # check syntax
terraform fmt -recursive    # format all .tf files
terraform plan              # preview changes
terraform apply             # apply (prompts for confirmation)
terraform apply -auto-approve  # skip prompt (CI only)
terraform destroy           # tear down all resources
```

## State

```bash
terraform show                          # current state
terraform state list                    # list resources
terraform state show aws_s3_bucket.ex   # inspect one resource
terraform state rm   aws_s3_bucket.ex   # remove from state (without destroying)
terraform import aws_s3_bucket.ex mybucket  # import existing resource
```

## Workspaces (lightweight envs)

```bash
terraform workspace new staging
terraform workspace select staging
terraform workspace list
```

Use `terraform.workspace` in code:

```hcl
resource "aws_s3_bucket" "app" {
  bucket = "myapp-${terraform.workspace}"
}
```

## Remote backend (S3 + DynamoDB lock)

```hcl
terraform {
  backend "s3" {
    bucket         = "my-tfstate-bucket"
    key            = "myinfra/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

```bash
terraform init -reconfigure   # after changing backend
```

## Modules

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "my-vpc"
  cidr = "10.0.0.0/16"
  azs  = ["us-west-2a", "us-west-2b"]
}
```

```bash
terraform get          # download modules
terraform init         # also downloads modules
```

## Tips

```bash
# Target a single resource
terraform plan   -target=aws_s3_bucket.example
terraform apply  -target=aws_s3_bucket.example

# Pass vars inline
terraform plan -var="environment=staging" -var="region=us-east-1"

# Output values
terraform output
terraform output -json | jq '.bucket_name.value'
```

## Project layout (recommended)

```
infra/
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf          # terraform{} + required_providers block
├── terraform.tfvars.example
├── .gitignore
└── modules/
    └── networking/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## ArgoCD + Terraform (via Terraform Cloud or CI)

ArgoCD manages K8s manifests; use CI (GitHub Actions / Atlantis) to run Terraform. A typical split:

| Tool | Manages |
|------|---------|
| Terraform | Cloud infra (VPC, RDS, EKS cluster, IAM) |
| Helm | App deployments on the cluster |
| ArgoCD | Syncs Helm charts from Git → cluster |
