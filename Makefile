KUBE_PROD_CLUSTER_NAME=gitops-prod-cluster
GCLOUD_PROJECT=verifa-gitops-demo-000000001
GCLOUD_ZONE=europe-north1-a
GCLOUD_SA_NAME=gitops

include admin.env

all: setup-gcloud setup-serviceaccount provision-prod-cluster install-services create-sealed-secret
clusters: provision-prod-cluster

setup-gcloud:
	gcloud projects create ${GCLOUD_PROJECT} \
	--organization ${TF_VAR_org_id} \
	--set-as-default
	gcloud beta billing projects link ${GCLOUD_PROJECT} \
  	--billing-account ${TF_VAR_billing_account}
	gcloud config set project ${GCLOUD_PROJECT}
	gcloud services enable cloudresourcemanager.googleapis.com cloudbilling.googleapis.com iam.googleapis.com compute.googleapis.com serviceusage.googleapis.com container.googleapis.com

setup-serviceaccount:
	gcloud iam service-accounts create ${GCLOUD_SA_NAME} --display-name "gitops admin account"
	gcloud projects add-iam-policy-binding ${GCLOUD_PROJECT} --member serviceAccount:${GCLOUD_SA_NAME}@${GCLOUD_PROJECT}.iam.gserviceaccount.com --role roles/editor
	gcloud projects add-iam-policy-binding ${GCLOUD_PROJECT} --member serviceAccount:${GCLOUD_SA_NAME}@${GCLOUD_PROJECT}.iam.gserviceaccount.com --role roles/container.admin
	gcloud projects add-iam-policy-binding ${GCLOUD_PROJECT} --member serviceAccount:${GCLOUD_SA_NAME}@${GCLOUD_PROJECT}.iam.gserviceaccount.com --role roles/compute.admin
	gcloud iam service-accounts keys create key.json \
	--iam-account ${GCLOUD_SA_NAME}@${GCLOUD_PROJECT}.iam.gserviceaccount.com
	mv key.json infra/

provision-prod-cluster:
	cd infra/ && terraform init && terraform apply -auto-approve
	gcloud container clusters get-credentials ${KUBE_PROD_CLUSTER_NAME} --project ${GCLOUD_PROJECT} --region ${GCLOUD_ZONE}

install-services:
	cd services/ && helmfile -f helmfile.yaml sync

create-sealed-secret:
	kubectl create secret generic flux-git-auth --namespace fluxcd --dry-run --from-literal=GIT_AUTHUSER="benmarsden" --from-literal=GIT_AUTHKEY=${GIT_AUTHKEY} -o yaml | \
	kubeseal \
	--controller-name=sealed-secrets \
	--controller-namespace=kube-system \
	--format json > services/flux-sealed-secret.yaml
	kubectl create -f services/flux-sealed-secret.yaml

destroy-infra:
	cd infra && terraform destroy -auto-approve
	kubectx -d gke_${GCLOUD_PROJECT}_${GCLOUD_ZONE}_${KUBE_PROD_CLUSTER_NAME}
	rm -rf .terraform terraform.tfstate

destroy-gcloud-project:
	gcloud projects delete ${GCLOUD_PROJECT} --quiet
