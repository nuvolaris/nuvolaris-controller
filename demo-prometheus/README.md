<!---
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#
-->
# Monitoring Demo: Prometheus (Stand-alone)

> References: 
>* https://github.com/tanalam2411/kubernetes/tree/master/prometheus/monitoring_k8s_with_prometheus
>* https://github.com/prometheus-operator/kube-prometheus/tree/main/manifests

## Usage
```sh
cd deploy
```

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