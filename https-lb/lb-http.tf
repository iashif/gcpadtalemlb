# # ---------------------------------------------------------------------------------------------------------------------
# # LAUNCH A LOAD BALANCER WITH INSTANCE GROUP AND STORAGE BUCKET BACKEND
# #
# # This is an example of how to use the http-load-balancer module to deploy a HTTP load balancer
# # with multiple backends and optionally ssl and custom domain.
# # ---------------------------------------------------------------------------------------------------------------------

# terraform {
#   # This module is now only being tested with Terraform 1.0.x. However, to make upgrading easier, we are setting
#   # 0.12.26 as the minimum version, as that version added support for required_providers with source URLs, making it
#   # forwards compatible with 1.0.x code.
#   required_version = ">= 0.12.26"

#   required_providers {
#     google = {
#       source  = "hashicorp/google"
#       version = "~> 3.43.0"
#     }
#     google-beta = {
#       source  = "hashicorp/google-beta"
#       version = "~> 3.43.0"
#     }
#   }
# }

# # ------------------------------------------------------------------------------
# # CONFIGURE OUR GCP CONNECTION
# # ------------------------------------------------------------------------------

# provider "google" {
#   region  = var.region
#   project = var.project
# }

# provider "google-beta" {
#   region  = var.region
#   project = var.project
# }

# # ------------------------------------------------------------------------------
# # CREATE A PUBLIC IP ADDRESS
# # ------------------------------------------------------------------------------

# resource "google_compute_global_address" "default" {
#   project      = var.project
#   name         = "${var.name}-address"
#   ip_version   = "IPV4"
#   address_type = "EXTERNAL"
# }


# # ------------------------------------------------------------------------------
# # IF PLAIN HTTP ENABLED, CREATE FORWARDING RULE AND PROXY
# # ------------------------------------------------------------------------------

# resource "google_compute_target_http_proxy" "http" {
#   count   = var.enable_http ? 1 : 0
#   project = var.project
#   name    = "${var.name}-http-proxy"
#   url_map = google_compute_url_map.urlmap.self_link
# }

# resource "google_compute_global_forwarding_rule" "http" {
#   provider   = google-beta
#   count      = var.enable_http ? 1 : 0
#   project    = var.project
#   name       = "${var.name}-http-rule"
#   target     = google_compute_target_http_proxy.http[0].self_link
#   ip_address = google_compute_global_address.default.address
#   port_range = "80"

#   depends_on = [google_compute_global_address.default]

#   labels = var.custom_labels
# }

# # ------------------------------------------------------------------------------
# # IF SSL ENABLED, CREATE FORWARDING RULE AND PROXY
# # ------------------------------------------------------------------------------

# # resource "google_compute_global_forwarding_rule" "https" {
# #   provider   = google
# #   project    = var.project
# #   count      = var.enable_ssl ? 1 : 0
# #   name       = "${var.name}-https-rule"
# #   target     = google_compute_target_https_proxy.default[0].self_link
# #   ip_address = google_compute_global_address.default.address
# #   port_range = "443"
# #   depends_on = [google_compute_global_address.default]
# #   load_balancing_scheme="EXTERNAL"
# # #   labels = var.custom_labels
# # #   network_tier          = "PREMIUM"
# # }

# # resource "google_compute_target_https_proxy" "default" {
# #   project = var.project
# #   count   = var.enable_ssl ? 1 : 0
# #   name    = "${var.name}-https-proxy"
# #   url_map = google_compute_url_map.urlmap.self_link

# #   ssl_certificates = google_compute_ssl_certificate.certificate.*.self_link
# # }

# # ------------------------------------------------------------------------------
# # IF DNS ENTRY REQUESTED, CREATE A RECORD POINTING TO THE PUBLIC IP OF THE CLB
# # ------------------------------------------------------------------------------

# resource "google_dns_record_set" "dns" {
#   project = var.project
#   count   = var.create_dns_entries ? length(var.custom_domain_names) : 0

#   name = "${element(var.custom_domain_names, count.index)}."
#   type = "A"
#   ttl  = var.dns_record_ttl

#   managed_zone = var.dns_managed_zone_name

#   rrdatas = [google_compute_global_address.default.address]
# }

# # ------------------------------------------------------------------------------
# # CREATE THE URL MAP TO MAP PATHS TO BACKENDS
# # ------------------------------------------------------------------------------

# resource "google_compute_url_map" "urlmap" {
#   project = var.project

#   name        = "${var.name}-url-map"
#   description = "URL map for ${var.name}"

#   # default_service = google_compute_backend_bucket.static.self_link
#   default_service=google_compute_backend_service.api.self_link

#   host_rule {
#     hosts        = ["*"]
#     path_matcher = "all"
#   }

#   path_matcher {
#     name            = "all"
#     default_service = google_compute_backend_service.api.self_link

#     path_rule {
#       paths   = ["/api", "/api/*"]
#       service = google_compute_backend_service.api.self_link
#     }
#   }
# }

# # ------------------------------------------------------------------------------
# # CREATE THE BACKEND SERVICE CONFIGURATION FOR THE INSTANCE GROUP
# # ------------------------------------------------------------------------------

# resource "google_compute_backend_service" "api" {
#   project = var.project

#   name        = "${var.name}-api"
#   description = "API Backend for ${var.name}"
#   port_name   = "http"
#   protocol    = "HTTP"
#   timeout_sec = 10
#   enable_cdn  = false

#   # backend {
#   #   group = google_compute_instance_group.api.self_link
#   # }
#  dynamic "backend" {
#     # for_each = var.uig_urls
#     for_each = google_compute_instance_group.api
#     content{
#         group           = backend.value.id
#         balancing_mode  = "UTILIZATION"
#         capacity_scaler = 1.0
#     }
#   }

#   health_checks = [google_compute_health_check.default.self_link]

#   depends_on = [google_compute_instance_group.api]
# }


# # ------------------------------------------------------------------------------
# # CONFIGURE HEALTH CHECK FOR THE API BACKEND
# # ------------------------------------------------------------------------------

# resource "google_compute_health_check" "default" {
#   project = var.project
#   name    = "${var.name}-hc"

#   http_health_check {
#     port         = 5000
#     request_path = "/api"
#   }

#   check_interval_sec = 5
#   timeout_sec        = 5
# }


# resource "tls_self_signed_cert" "cert" {
#   # Only create if SSL is enabled
#   count = var.enable_ssl ? 1 : 0

#   # key_algorithm   = "RSA"
#   private_key_pem = join("", tls_private_key.private_key.*.private_key_pem)

#   subject {
#     common_name  = var.custom_domain_name
#     organization = "Examples, Inc"
#   }

#   validity_period_hours = 12

#   allowed_uses = [
#     "key_encipherment",
#     "digital_signature",
#     "server_auth",
#   ]
# }

# resource "tls_private_key" "private_key" {
#   count       = var.enable_ssl ? 1 : 0
#   algorithm   = "RSA"
#   ecdsa_curve = "P256"
# }

# # ------------------------------------------------------------------------------
# # CREATE A CORRESPONDING GOOGLE CERTIFICATE THAT WE CAN ATTACH TO THE LOAD BALANCER
# # ------------------------------------------------------------------------------

# # resource "google_compute_ssl_certificate" "certificate" {
# #   project = var.project
  
# #   count = var.enable_ssl ? 1 : 0
# #   name = "${var.name}-gcp-cert"
# # #   name_prefix = var.name
# #   description = "SSL Certificate"
# #   private_key = join("", tls_private_key.private_key.*.private_key_pem)
# #   certificate = join("", tls_self_signed_cert.cert.*.cert_pem)

# #   lifecycle {
# #     create_before_destroy = true
# #   }
# # }


# resource "google_compute_instance_group" "api" {
#   for_each    = var.compute_uig_config
#   name        = "${each.value.name}-instance-group"
#   project     = var.project
#   description = "Terraform managed Unmanaged Instance group"
#   instances   = each.value.compute_uig_vm_list
#   named_port {
#     name = "http"
#     port = "80"
#   }
#   zone = each.value.zone
# }

