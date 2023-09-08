#!/usr/bin/env bash
terragrunt run-all init || echo "Terraform init error but we tolerate it here."
terragrunt run-all init -reconfigure