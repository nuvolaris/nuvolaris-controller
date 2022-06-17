# Monitoring Demo: KubePrometheus

> References: 
>* https://github.com/prometheus-operator/kube-prometheus

For a quickstart a compiled version of the Kubernetes manifests generated with this library (specifically with example.jsonnet) is checked into this repository in order to try the content out quickly. To try out the stack un-customized run:

Create the monitoring stack using the config in the manifests directory:

```sh
# Create the namespace and CRDs, and then wait for them to be available before creating the remaining resources
kubectl apply --server-side -f manifests/setup
until kubectl get servicemonitors --all-namespaces ; do date; sleep 1; echo ""; done
kubectl apply -f manifests/
```
We create the namespace and CustomResourceDefinitions first to avoid race conditions when deploying the monitoring components. Alternatively, the resources in both folders can be applied with a single command `kubectl apply --server-side -f manifests/setup -f manifests`, but it may be necessary to run the command multiple times for all components to be created successfully.

And to teardown the stack:
```sh
kubectl delete --ignore-not-found=true -f manifests/ -f manifests/setup
```