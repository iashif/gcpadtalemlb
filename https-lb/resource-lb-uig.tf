# #Currently single ILB is applied across all instance groups
# # forwarding rule
# resource "google_compute_forwarding_rule" "ilb_fw_rule" {
#   name                  = "${var.env}-${var.insti}-${var.app}-fw-rule"
#   project               = var.service_project_id
#   region                = var.ilb_uig_region
#   ip_protocol           = "TCP"
#   load_balancing_scheme = "INTERNAL_MANAGED"
#   port_range            = "443"
#   target                = google_compute_region_target_https_proxy.ilb_target_https_proxy.id
#   network               = data.google_compute_network.compute_vm_vpc_data.self_link
#   subnetwork            = data.google_compute_subnetwork.compute_vm_subnet_data.self_link
#   network_tier          = "PREMIUM"
# }

# # HTTPS target proxy
# resource "google_compute_region_target_https_proxy" "ilb_target_https_proxy" {
#   name     = "${var.env}-${var.insti}-${var.app}-target-http-proxy"
#   project  = var.service_project_id
#   region   = var.ilb_uig_region
#   url_map  = google_compute_region_url_map.ilb_url_map.id
#   ssl_certificates = [google_compute_region_ssl_certificate.ilb_ssl_cert.id]
# }

# #SSL certificates for HTTPS target proxy
# resource "google_compute_region_ssl_certificate" "ilb_ssl_cert" {
#   region      = var.ilb_uig_region
#   name        = "${var.env}-${var.insti}-${var.app}-ilb-cert"
#   project     = var.service_project_id
#   private_key = file("${var.data_dir}/certificates/private.key")
#   certificate = file("${var.data_dir}/certificates/certificate.crt")
# }

# # URL map. Each URL map will have its own respective backend service. TODO: Ask Satish if single ILB will serve multiple backend services?
# resource "google_compute_region_url_map" "ilb_url_map" {
#   name            = "${var.env}-${var.insti}-${var.app}-grp-ilb"
#   project         = var.service_project_id
#   region          = var.ilb_uig_region
#   default_service = google_compute_region_backend_service.ilb_backend_service.id
# }

# # health check
# resource "google_compute_region_health_check" "ilb_health_check" {
#   name     = "${var.env}-${var.insti}-${var.app}-hc"
#   project  = var.service_project_id
#   region   = var.ilb_uig_region
#   http_health_check {
#     port_specification = "USE_SERVING_PORT"
#   }
# }

# # backend service
# resource "google_compute_region_backend_service" "ilb_backend_service" {
#   name                  = "${var.env}-${var.insti}-${var.app}-backend"
#   region                = var.ilb_uig_region
#   project               = var.service_project_id
#   protocol              = "HTTP"
#   load_balancing_scheme = "INTERNAL_MANAGED"
#   timeout_sec           = 10
#   health_checks         = [google_compute_region_health_check.ilb_health_check.id]
#   dynamic "backend" {
#     # for_each = var.uig_urls
#     for_each = google_compute_instance_group.compute_uig
#     content{
#         group           = backend.value.id
#         balancing_mode  = "UTILIZATION"
#         capacity_scaler = 1.0
#     }
#   }
# }
