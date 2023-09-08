#!/usr/bin/env bash
terragrunt init || echo "Terraform init error but we tolerate it here."
terragrunt init -reconfigure