module "eg_ecs_label" {
  for_each = toset(local.environments)

  source = "cloudposse/label/null"

  namespace  = "eg"
  stage      = each.key # Set to current environment for both ECS and ALB
  name       = "ECS"
  attributes = ["service"]
  delimiter  = "-"

  tags = {
    "BusinessUnit" = "XYZ",
    "Snapshot"     = "false"
  }
}
