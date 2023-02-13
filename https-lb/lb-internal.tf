# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# DEPLOY AN INTERNAL LOAD BALANCER
# This module deploys an Internal TCP/UDP Load Balancer
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

terraform {
  # This module is now only being tested with Terraform 1.0.x. However, to make upgrading easier, we are setting
  # 0.12.26 as the minimum version, as that version added support for required_providers with source URLs, making it
  # forwards compatible with 1.0.x code.
  required_version = ">= 0.12.26"
}

# ------------------------------------------------------------------------------
# CREATE FORWARDING RULE
# ------------------------------------------------------------------------------

resource "google_compute_forwarding_rule" "default" {
  provider              = google-beta
  project               = var.project
  name                  = var.name
  region                = var.region
  network               = data.google_compute_network.compute_vm_vpc_data.self_link
  subnetwork            = data.google_compute_subnetwork.compute_vm_subnet_data.self_link
  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.default.self_link
#   ip_address            = var.ip_address
#    ip_address = "10.102.67.20"
#   ip_protocol           = var.protocol
ip_protocol="TCP"
#   ports                 = var.ports
ports=["88"]

  # If service label is specified, it will be the first label of the fully qualified service name.
  # Due to the provider failing with an empty string, we're setting the name as service label default
#   service_label = var.service_label == "" ? var.name : var.service_label

  # This is a beta feature
#   labels = var.custom_labels
}

# ------------------------------------------------------------------------------
# CREATE BACKEND SERVICE
# ------------------------------------------------------------------------------

data "google_compute_network" "compute_vm_vpc_data" {
  project = var.shared_vpc_host_project_id
  name    = var.compute_vm_host_vpc
}

data "google_compute_subnetwork" "compute_vm_subnet_data" {
  name    = var.compute_vm_host_vpc_ilb_subnet
  project = var.shared_vpc_host_project_id
  region  = var.compute_vm_host_vpc_subnet_region
}

resource "google_compute_region_backend_service" "default" {
  project          = var.project
  name             = var.name
  region           = var.region
  protocol              = "TCP"
#   load_balancing_scheme = "INTERNAL_MANAGED"
#   protocol         = var.protocol
  timeout_sec      = 10
#   session_affinity = var.session_affinity

#   dynamic "backend" {
#     for_each = var.backends
#     content {
#       description = lookup(backend.value, "description", null)
#       group       = lookup(backend.value, "group", null)
#     }
#   }

#   health_checks = [
#     compact(
#       concat(
#         google_compute_health_check.tcp.*.self_link
#         # ,
#         # google_compute_health_check.http.*.self_link
#       )
#   )[0]]

 dynamic "backend" {
    # for_each = var.uig_urls
    for_each = google_compute_instance_group.api
    content{
        group           = backend.value.id
        #  balancing_mode  = "CONNECTION"
        capacity_scaler = 1.0
    }
  }

  health_checks = [google_compute_region_health_check.default.self_link]

  depends_on = [google_compute_instance_group.api]

}

resource "google_compute_instance_group" "api" {
  for_each    = var.compute_uig_config
  name        = "${each.value.name}-instance-group"
  project     = var.project
  description = "Terraform managed Unmanaged Instance group"
  instances   = each.value.compute_uig_vm_list
  named_port {
    name = "http"
    port = "80"
  }
  zone = each.value.zone
}

# ------------------------------------------------------------------------------
# CREATE HEALTH CHECK - ONE OF ´http´ OR ´tcp´
# ------------------------------------------------------------------------------

# resource "google_compute_health_check" "tcp" {
# #   count = var.http_health_check ? 0 : 1

#   project = var.project
#   name    = "${var.name}-hc"

#   tcp_health_check {
#     # port = var.health_check_port
#     port=5000
#   }
# }

resource "google_compute_region_health_check" "default" {
 project = var.project
  name     = "${var.name}-hc"
  provider = google-beta
  region   = var.region
  http_health_check {
    port_specification =  "USE_SERVING_PORT"
  }
}

# resource "google_compute_health_check" "http" {
#   count = var.http_health_check ? 1 : 0

#   project = var.project
#   name    = "${var.name}-hc"

#   http_health_check {
#     # port = var.health_check_port
#     port = 5001
#   }
# }

# ------------------------------------------------------------------------------
# CREATE FIREWALLS FOR THE LOAD BALANCER AND HEALTH CHECKS
# ------------------------------------------------------------------------------

# Load balancer firewall allows ingress traffic from instances tagged with any of the ´var.source_tags´
# resource "google_compute_firewall" "load_balancer" {
#   project = var.network_project == "" ? var.project : var.network_project
#   name    = "${var.name}-ilb-fw"
#   network = var.network

#   allow {
#     protocol = lower(var.protocol)
#     ports    = var.ports
#   }

#   # Source tags defines a source of traffic as coming from the primary internal IP address
#   # of any instance having a matching network tag.
#   source_tags = var.source_tags

#   # Target tags define the instances to which the rule applies
#   target_tags = var.target_tags
# }

# Health check firewall allows ingress tcp traffic from the health check IP addresses
# resource "google_compute_firewall" "health_check" {
#   project = var.network_project == "" ? var.project : var.network_project
#   name    = "${var.name}-hc"
#   network = var.network

#   allow {
#     protocol = "tcp"
#     ports    = [var.health_check_port]
#   }

#   # These IP ranges are required for health checks
#   source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]

#   # Target tags define the instances to which the rule applies
#   target_tags = var.target_tags
# }
