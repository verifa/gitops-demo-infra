output "cluster_id" {
  value = "${google_container_cluster.cluster.id}"
}

output "cluster_name" {
  value = "${google_container_cluster.cluster.name}"
}

output "project" {
  value = "${var.project}"
}

output "cluster_region" {
  value = "${google_container_cluster.cluster.location}"
}

output "cluster_context_set" {
  value = "${null_resource.kubectl.id}"
}

output "node_pool_name" {
  value = "${google_container_node_pool.primary_nodes.name}"
}

output "node_pool_cluster" {
  value = "${google_container_node_pool.primary_nodes.cluster}"
}

output "node_pool_id" {
  value = "${google_container_node_pool.primary_nodes.id}"
}
