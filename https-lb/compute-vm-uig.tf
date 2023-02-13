# /**
#  * Copyright 2022 Google LLC
#  *
#  * Licensed under the Apache License, Version 2.0 (the "License");
#  * you may not use this file except in compliance with the License.
#  * You may obtain a copy of the License at
#  *
#  *      http://www.apache.org/licenses/LICENSE-2.0
#  *
#  * Unless required by applicable law or agreed to in writing, software
#  * distributed under the License is distributed on an "AS IS" BASIS,
#  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  * See the License for the specific language governing permissions and
#  * limitations under the License.
#  */

# # 
# data "google_compute_network" "compute_vm_vpc_data" {
#   project = var.shared_vpc_host_project_id
#   name    = var.compute_vm_host_vpc
# }

# data "google_compute_subnetwork" "compute_vm_subnet_data" {
#   name    = var.compute_vm_host_vpc_ilb_subnet
#   project = var.shared_vpc_host_project_id
#   region  = var.compute_vm_host_vpc_subnet_region
# }

# #Creating Unmanaged Instance group for existing required VMs
# resource "google_compute_instance_group" "compute_uig" {
#   for_each    = var.compute_uig_config
#   name        = each.value.name
#   project     = var.service_project_id
#   description = "Terraform managed Unmanaged Instance group"
#   instances   = each.value.compute_uig_vm_list
#   named_port {
#     name = "http"
#     port = "80"
#   }
#   zone = each.value.zone
# }

# #Snapshot Schedule for above VMs should already exist

# #OPTIONAL block for App specific firewall rules (if required)
# # module "app-firewall-rules" {
# #   source              = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/net-vpc-firewall?ref=v16.0.0"
# #   project_id          = var.shared_vpc_host_project_id
# #   network             = var.compute_vm_host_vpc
# #   admin_ranges        = []
# #   http_source_ranges  = []
# #   https_source_ranges = []
# #   ssh_source_ranges   = []
# #   data_folder         = "${var.data_dir}/firewall-rules"
# # }