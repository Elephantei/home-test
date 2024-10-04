# Infrastructure goal

The aim was to create immutable, secure and automated infrastructure. 

## Table of Contents

- [Introduction](#introduction)
- [Features](#features)

## Features

- **Templated pipeline YAMLs**:  
  Using templated pipeline YAMLs ensures consistency across multiple pipelines and simplifies maintenance by reusing common stages, jobs, and steps. This helps to:
  - Reduce duplication of pipeline code.
  - Allow updates in a single place for all pipelines.
  - Customize pipelines based on different environments with minimal changes.

- **Separate folders for Terraform backends and environments (tfvars)**:  
  Organizing the Terraform code into distinct folders for backends and environment-specific variables (like `staging` or `production`) provides:
  - A clean and modular structure.
  - Easy management of state storage (backend).
  - Clear separation of environment-specific variables, reducing potential configuration mistakes.

- **Using CloudPosse Labellers**:  
  The CloudPosse label module helps enforce consistent naming conventions for AWS resources by:
  - Standardizing resource names and tags across environments.
  - Reducing the chances of naming conflicts.
  - Simplifying identification, governance, and cost tracking of resources.

- **Creating ECS resources using `for_each` loop**:  
  The `for_each` loop in Terraform dynamically creates ECS clusters, services, and task definitions for multiple environments by:
  - Scaling resources efficiently based on input lists (e.g., environments).
  - Reducing code duplication and simplifying management.
  - Ensuring consistent resource creation across different environments.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eg_ecs_label"></a> [eg\_ecs\_label](#module\_eg\_ecs\_label) | cloudposse/label/null | n/a |
| <a name="module_eg_staging_alb_label"></a> [eg\_staging\_alb\_label](#module\_eg\_staging\_alb\_label) | cloudposse/label/null | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_ecs_cluster.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_service.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_role.ecs_task_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ecs_task_execution_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_internet_gateway.gw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_lb.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.alb_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecs_cluster_name"></a> [ecs\_cluster\_name](#output\_ecs\_cluster\_name) | n/a |
<!-- END_TF_DOCS -->