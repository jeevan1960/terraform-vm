# GKE cluster
resource "google_container_cluster" "primary" {
  name     = "${var.project_id}-gke"
  location = var.region
  network    = google_compute_network.vpc-vm.name
  subnetwork = google_compute_subnetwork.subnet-vm.name
  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "nodepool-1" {
  name       = "node-pool-1"
  cluster    = google_container_cluster.vpc-vm.name
  node_count = 3

  node_config {
    preemptible  = false
    machine_type = "e2-medium"
    service_account = google_service_account.service_account-vm.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}


resource "google_container_node_pool" "nodepool-2" {
  name       = "node-pool-2"
  cluster    = google_container_cluster.vpc-vm.name
  
  
  autoscaling {
    min_node_count = 0
    max_node_count = 4
  }

  node_config {
    preemptible  = true
    machine_type = "e2-medium"
    service_account = google_service_account.service_account-vm.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}


