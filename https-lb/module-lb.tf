# module "ilb" {
#   source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/net-ilb-l7?ref=v16.0.0"
#   name       = "${var.env}-${var.app}-ilb"
#   project_id = var.service_project_id
#   region     = var.ilb_mig_region
#   network    = data.google_compute_network.compute_vm_vpc_data.self_link
#   subnetwork = var.ilb_subnet_resource_id

#   backend_services_config = {
#     mig-backend-svc = {
#       backends = [
#         for k,v in var.compute_vm_config : {
#           group   = "projects/${var.service_project_id}/region/${var.compute_vm_mig_location}/instanceGroups/${k}-mig"
#           options = null
#         }
#       ],
#       health_checks = ["ilb-mig-hc"]
#       log_config = null
#       options = null
#     }
#   }

#   health_checks_config = {
#     ilb-mig-hc = {
#       type    = "http"
#       logging = true
#       options = {
#         timeout_sec = 5
#       }
#       check = {
#         port_specification = "USE_SERVING_PORT"
#       }
#     }
#   }

#   depends_on = [
#     google_compute_region_instance_group_manager.compute_mig
#   ]
# }