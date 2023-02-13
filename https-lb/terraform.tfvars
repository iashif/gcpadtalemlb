#================================================================! DO NOT EDIT !===============================================================#
# use `gcloud beta billing accounts list`
# if you have too many accounts, check the Cloud Console :)
#Details specific to Adtalem have already been filled. !!! DO NOT EDIT !!!
billing_account = {
    id              = "01CE59-DCE721-8E2F46"
    organization_id = 962197216585
}

# use `gcloud organizations list`
#Details specific to Adtalem have already been filled. !!! DO NOT EDIT !!!
organization = {
    domain      = "adtalem.com"
    id          = 962197216585
    customer_id = "C01gj0de0"
}
#================================================================! DO NOT EDIT !===============================================================#
#================================================================== EDITABLE ==================================================================#

#PREREQUISITE: assuming service project is added to host vpc via Landing zone code. GCP console link: https://console.cloud.google.com/networking/xpn. Select the relevant service project

project="qa-wu-srv-proj"
region="us-central1"
zone="us-central1-a"
name="test-alb"
enable_ssl=true
custom_domain_name="test.bep-qa.waldenu.edu"
http_health_check=false
//enable_http

custom_domain_names   = ["test.bep-qa.waldenu.edu"]


#The name of the Shared Host VPC in which VM servers need to be created
compute_vm_host_vpc = "infra-ss-spoke-qa-1-host-proj-vpc-shared"
#The name of the Shared Host VPC Subnet in which VM servers need to be created. 
compute_vm_host_vpc_ilb_subnet = "infra-ss-spoke-qa-1-host-proj-vpc-shared-sb-wu-app"
#Project ID where the Shared Host VPC lives
shared_vpc_host_project_id = "infra-ss-spoke-qa-host-proj"
#The region of the Shared Host VPC Subnet
compute_vm_host_vpc_subnet_region = "us-central1"

compute_uig_config = {
    #UIG name (UIG stands for Unmanaged Instance Group)
    test-a = {
        name = "test-a",               
        zone = "us-central1-a",
        compute_uig_vm_list = [
            "projects/qa-wu-srv-proj/zones/us-central1-a/instances/a09uedbpfqa01", #to get this use the command: gcloud compute instances describe INSTANCE_NAME [--zone=ZONE]
        ]
    },
    test-b = {
        name = "test-b",               
        zone = "us-central1-a",
        compute_uig_vm_list = [
            "projects/qa-wu-srv-proj/zones/us-central1-a/instances/a13ueqowdb01", #to get this use the command: gcloud compute instances describe INSTANCE_NAME [--zone=ZONE]
        ]
    }
}




#NOTE: Please edit firewall rules in the rules.yaml file located in the data/firewall-rules folder

#================================================================== EDITABLE ==================================================================#