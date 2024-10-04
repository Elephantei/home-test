module "eg_ecs_label" {
  for_each = toset(local.environments)

  source = "cloudposse/label/null"

  namespace  = "eg"
  stage      = each.key
  name       = "ECS"
  attributes = ["service"]
  delimiter  = "-"

  tags = {
    "BusinessUnit" = "XYZ",
    "Snapshot"     = "false"
  }
}

module "eg_staging_alb_label" {
  source = "cloudposse/label/null"

  namespace  = "eg"
  stage      = "staging"
  name       = "ALB"
  attributes = ["web"]
  delimiter  = "-"

  tags = {
    "BusinessUnit" = "XYZ",
    "Snapshot"     = "false"
  }
}
