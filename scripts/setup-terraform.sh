#!/usr/bin/env bash
# Bootstrap a new Terraform project
set -euo pipefail

NAME="${1:-infra}"
DEST="${2:-.}/$NAME"

command -v terraform >/dev/null || { echo "terraform not found — run brew bundle"; exit 1; }

mkdir -p "$DEST"

# main.tf
cat > "$DEST/main.tf" <<'EOF'
terraform {
  required_version = ">= 1.0"

  required_providers {
    # Add providers here, e.g.:
    # aws = {
    #   source  = "hashicorp/aws"
    #   version = "~> 5.0"
    # }
  }

  # Switch to remote backend for team use:
  # backend "s3" {
  #   bucket = "my-tfstate"
  #   key    = "infra/terraform.tfstate"
  #   region = "us-east-1"
  # }
}

# Example resource
# resource "aws_s3_bucket" "example" {
#   bucket = var.bucket_name
# }
EOF

# variables.tf
cat > "$DEST/variables.tf" <<'EOF'
variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "Cloud provider region"
  type        = string
  default     = "us-west-2"
}
EOF

# outputs.tf
cat > "$DEST/outputs.tf" <<'EOF'
# output "example" {
#   value = aws_s3_bucket.example.bucket
# }
EOF

# terraform.tfvars (not committed)
cat > "$DEST/terraform.tfvars.example" <<'EOF'
environment = "dev"
region      = "us-west-2"
EOF

# .gitignore
cat > "$DEST/.gitignore" <<'EOF'
.terraform/
.terraform.lock.hcl
terraform.tfstate
terraform.tfstate.backup
*.tfvars
!*.tfvars.example
crash.log
EOF

echo "Terraform project scaffolded at $DEST"
echo ""
echo "Next steps:"
echo "  cd $DEST"
echo "  cp terraform.tfvars.example terraform.tfvars && \$EDITOR terraform.tfvars"
echo "  terraform init"
echo "  terraform plan"
echo "  terraform apply"
