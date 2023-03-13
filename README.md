# Login with your GCP credentials 
git clone https://github.com/hashicorp/learn-terraform-provision-gke-cluster
cd learn-terraform-provision-gke-cluster
gcloud init
gcloud auth application-default login
terraform init
terraform plan
terraform apply
