output "ecs_cluster_name" {
  value = { for env in local.environments : env => aws_ecs_cluster.main[env].name }
}
