# gitops-demo-infra
This repository provides the gitops infrastructure to support Verifa's gitops demo: https://github.com/verifa/gitops-demo.

## Workflow

The repository implements the following workflow: 
![Gitops conceptual workflow](https://github.com/verifa/gitops-demo-infra/raw/master/docs/_files/contact-forum-infra-workflow.png)

## Repository Components

* [Kubernetes](https://kubernetes.io/) 

* [A GitHub repository](https://github.com/) which Flux monitors for synchronising with the Kubernetes cluster.

* [Google Cloud Platform (GCP)](https://console.cloud.google.com/getting-started). We provision a GKE (Google Kubernetes Engine) kubernetes cluster. Therefore, a Google account linked to GCP, with billing set up, is required.

* [Terraform](https://www.terraform.io). Declarative infrastructure! Terraform is used to provision the GKE kubernetes cluster into which the services are deployed.

* [Flux](https://github.com/fluxcd), created by [Weaveworks](https://www.weave.works), does the following:
    * Applies Kubernetes manifest YAML files to your cluster from a Git repository
    * Auto-deploys images to a running cluster as they are produced by your CI system 
    * Updates Kubernetes manifest YAML files with the latest image tags and auto-commits these to the Git repository

* [Helm3](https://helm.sh). A package manager (and much more) for Kubernetes. Helm abstracts Kubernetes deployments away from underlying Kubernetes resources like `Deployment`, enabling you to write higher-level deployment definitions in the form of Helm Charts that are a bit more friendly.

* [Flux Helm Operator](https://github.com/fluxcd/helm-operator) - Declarative Helm! This introduces a custom Kubernetes resource, HelmRelease, which the Flux Helm Operator can use to deploy Helm Charts into the Kubernetes cluster. As an example of this, see services/weave-scope.yaml

* [Helmfile](https://github.com/roboll/helmfile). Declarative Helm... again! Helmfile is used for the initial deployment of Flux and the Flux Helm Operator into the Kubernetes cluster. The reason for this is that we have a chicken and egg situation: until we get Flux, we won't get continuous deployment... but until we get continuous deployment, we won't get Flux! Something needs to get the ball rolling, and that something is helmfile.

* [Weave Scope](https://www.weave.works/oss/scope/). Kubernetes cluster visualisation tool. 

## Requirements for personal use

While the primary focus of this repository is not that of a tutorial, it is possible to use it as such, and the Makefile outlines the general process. With that said, take note of the following before before trying to run `make`:

### Tooling

The following tools are required locally

1. make
2. gcloud sdk
3. terraform
4. helm3
5. helmfile
6. kubectl

### Environment Variables

1. At the top of the Makefile are 4 variables you will likely want to modify to your choosing:`KUBE_PROD_CLUSTER_NAME`, `GCLOUD_PROJECT`, `GCLOUD_ZONE`,`GCLOUD_SA_NAME`.
`

2. The makefile uses certain variables when setting up the GCP project, imported from a super secret `admin.env` file. `example-admin.env` shows these environment variables. 
    * `TF_VAR_org_id` and `TF_VAR_billing_account` can be found from GCP. If you are not part of an organisation, billing account alone should suffice, but you will need to modify the Makefile to not to make reference to the organisation id when creating the GCP project.
    * `GIT_AUTHKEY` is required by Flux to have certain rights to the Git repository it is monitoring. You can find information for generating this from Flux documentation, for example [here](https://github.com/fluxcd/flux/tree/master/chart/flux).
## Visualising the infrastructure with Weave Scope

By default, Weave Scope is kept internal to the cluster. To gain access, you can port-forward the Weave Scope frontend pod to localhost:4040 as follows: 

`
kubectl port-forward -n weave "$(kubectl get -n weave pod --selector=app=weave-scope,component=frontend -o jsonpath='{.items..metadata.name}')" 4040
`

## Future Work

* Ideally, the less this demo relies on imperative operations the better. Given a little time I will shift the GCP-related tasks out of the Makefile and into terraform.
