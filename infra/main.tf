# ---------------------------------------------------------------------------------------------------------------------
# SET TERRAFORM REQUIREMENTS FOR RUNNING THIS MODULE
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = ">= 0.12"
}

provider "google" {
  credentials = file("./key.json")
  project = var.project
  region  = var.region
  zone    = var.zone
}


provider "kubernetes" {
    # config_context = "gke_${var.project}_${var.region}_${var.cluster_name}"
}

resource "google_container_cluster" "cluster" {
  name               = var.cluster_name
  location           = var.zone

  remove_default_node_pool = true
  initial_node_count = 1

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

resource "google_container_node_pool" "primary_nodes" {
  name       = var.node_pool_name
  location   = var.zone
  cluster    = google_container_cluster.cluster.name
  node_count = var.node_count

  node_config {
    preemptible  = false
    machine_type = var.machine_type

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

resource "null_resource" "kubectl" {
  triggers = {
    cluster = "${google_container_cluster.cluster.id}"
  }

  # On creation, we want to setup the kubectl credentials. The easiest way
  # to do this is to shell out to gcloud.
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials --zone=${var.zone} ${google_container_cluster.cluster.name}"
  }

  provisioner "local-exec" {
    command = "kubectl config set-context gke_${var.project}_${var.zone}_${var.cluster_name}"
  }
}


resource "kubernetes_namespace" "fluxcd" {
  depends_on = [google_container_node_pool.primary_nodes]
  metadata {
    name = "fluxcd"
  }
}

resource "kubernetes_namespace" "gitops-demo" {
  depends_on = [google_container_node_pool.primary_nodes]
  metadata {
    name = "gitops-demo"
  }
}

resource "kubernetes_namespace" "weave" {
  depends_on = [google_container_node_pool.primary_nodes]
  metadata {
    name = "weave"
  }
}
