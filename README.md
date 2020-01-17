# gitops-demo-infra
Infrastructure to support https://github.com/verifa/gitops-demo

## Visualising the infrastructure:

´
kubectl port-forward -n weave "$(kubectl get -n weave pod --selector=app=weave-scope,component=frontend -o jsonpath='{.items..metadata.name}')" 4040
