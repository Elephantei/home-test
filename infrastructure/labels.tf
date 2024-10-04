module "eg_staging_ecs_label" {
  source = "cloudposse/label/null"

  namespace  = "eg"
  stage      = "staging" # Set to staging for both ECS and ALB
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
