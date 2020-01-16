variable "billing_account" {}
variable "org_id" {}

variable "project" {
    default = "verifa-gitops-demo-000000001"
    description = "The name of the Google Cloud project to deploy terraform resources into"
    type = string
}

variable "cluster_name" {
  description = "The name of the k8s cluster"
  default = "gitops-prod-cluster"
  type = string
}

variable "region" {
  default     = "europe-north1"
  description = "The region to launch all the nodes in"
  type = string
}

variable "zone" {
  default     = "europe-north1-a"
  description = "The zone to launch all the nodes in"
  type = string
}

variable "node_count" {
  default     = 2
  description = "Number of nodes to use."
  type = number
}

variable "node_pool_name" {
  default     = "gitops-prod-cluster-node-pool"
  description = "Name of node pool"
  type = string
}

variable "machine_type" {
  default     = "n1-standard-2"
  description = "GCP machine type to use"
  type = string
}
