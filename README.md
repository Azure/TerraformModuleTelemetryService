# Terraform Module Telemetry Collection Service

This repository contains the Terraform Module Telemetry Collection Service. This project is divided into four parts, all written in Terraform. 

## Overview

- `resource_group`: Creates an Azure resource group.
- `acr`: Creates an Azure Container Registry along with virtual network and subnets and corresponding private endpoints. This ACR registry is only accessible via the VNet.
- `docker_image`: Contains a sub-folder named `telemetry` which contains a `main.go` file. This Go application uses [Iris](https://github.com/kataras/iris) as a web server to collect tags sent from a Terraform provider named [`modtm`](https://github.com/lonegunmanb/terraform-provider-modtm), enabling us to collect usage telemetry data from our Terraform module users. This part will compile the HTTP server application into a Docker image and push it into the ACR created previously.
- `container_apps`: Uses the [Azure Container Apps Module](https://github.com/Azure/terraform-azure-container-apps) to create an Azure Container Apps instance to host the web application pushed into the ACR.

Due to an issue with the Docker provider ([#483](https://github.com/kreuzwerker/terraform-provider-docker/issues/483)), we can't use the ACR resource's `login_url` and `password` outputs directly in the Terraform Docker provider's config. Therefore, we have divided the solution into four parts and weave them together using [Terragrunt](https://terragrunt.gruntwork.io/).

## Prerequisites

- Azure credentials configured as per the [AzureRM Provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs).

## Provisioning

To provision the whole solution, execute the following command in the repository's root folder:

```bash
terragrunt run-all apply --terragrunt-non-interactive
```
This command will use your Azure credentials to provision the resources defined in the Terraform modules.

## Contribution

Contributions to this repository are welcome. Please ensure that you update the README when adding or modifying behaviour.