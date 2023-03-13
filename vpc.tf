# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "project_id" {
  description = "project id"
}

variable "region" {
  description = "region"
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# VPC
resource "google_compute_network" "vpc-vm" {
  name                    = "${var.project_id}-vpc"
  auto_create_subnetworks = "false"
}

# Subnet
resource "google_compute_subnetwork" "subnet-vm" {
  name          = "${var.project_id}-subnet"
  region        = var.region
  network       = google_compute_network.vpc-vm.name
  ip_cidr_range = "10.10.0.0/24"
}

resource "google_service_account" "service_account-vm" {
  account_id   = "service-account-id"
  display_name = "Service Account"
}

resource "google_compute_router" "router-vm" {
  name    = "my-router"
  region  = google_compute_subnetwork.subnet-vm.region
  network = google_compute_network.net.id

}

resource "google_compute_router_nat" "nat-vm" {
  name                               = "my-router-nat"
  router                             = google_compute_router.router-vm.name
  region                             = google_compute_router.router-vm.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

resource "google_bigquery_dataset" "dataset" {
  dataset_id                  = "vmo2_tech_test"
  friendly_name               = "vmo2_tech_test"
  description                 = "This is a test"
  location                    =  var.region
}

data "google_iam_policy" "owner" {
  binding {
    role = "roles/bigquery.dataEditor"

    members = [
      "user:jeevan1960@gmail.com",
    ]
  }
}

resource "google_bigquery_dataset_iam_policy" "dataset" {
  dataset_id  = google_bigquery_dataset.dataset.dataset_id
  policy_data = data.google_iam_policy.owner.policy_data
}

resource "google_bigquery_dataset_access" "access" {
  dataset_id    = google_bigquery_dataset.dataset.dataset_id
  role          = "OWNER"
  user_by_email = google_service_account.service_account-vm.email
}
