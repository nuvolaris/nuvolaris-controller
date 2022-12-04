<!--
  ~ Licensed to the Apache Software Foundation (ASF) under one
  ~ or more contributor license agreements.  See the NOTICE file
  ~ distributed with this work for additional information
  ~ regarding copyright ownership.  The ASF licenses this file
  ~ to you under the Apache License, Version 2.0 (the
  ~ "License"); you may not use this file except in compliance
  ~ with the License.  You may obtain a copy of the License at
  ~
  ~   http://www.apache.org/licenses/LICENSE-2.0
  ~
  ~ Unless required by applicable law or agreed to in writing,
  ~ software distributed under the License is distributed on an
  ~ "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
  ~ KIND, either express or implied.  See the License for the
  ~ specific language governing permissions and limitations
  ~ under the License.
  ~
-->
## LKS (Akamai Cloud Computing)

> Tested with a LKS cluster running a Kubernetes 1.23 cluster

```sh
# initialize the cluster
task lks-create

# wait that the cluster is correclty initialized and then execute this command to save the local kubectl config
task lks-config

# setup cert-manager and nginx-ingress
task lks-setup

# setup a let's encrypt protected https ingress 
task lks-deploy
```

if everything is correct these are the different components deployed inside the microk8s cluster

```sh
# cert-manager namespace content
Every 2.0s: kubectl -n cert-manager get deploy,pod,service,ingress,Issuers,ClusterIssuers,Certificates,CertificateRequests,Orders,Challenges                                docker-desktop: Thu Nov 17 17:52:34 2022

NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/cert-manager              1/1     1            1           13m
deployment.apps/cert-manager-cainjector   1/1     1            1           13m
deployment.apps/cert-manager-webhook      1/1     1            1           13m

NAME                                          READY   STATUS    RESTARTS   AGE
pod/cert-manager-64456d445d-5k7jr             1/1     Running   0          13m
pod/cert-manager-cainjector-b4d945685-2vvdp   1/1     Running   0          13m
pod/cert-manager-webhook-b474995bf-2wnd7      1/1     Running   0          13m

NAME                           TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
service/cert-manager           ClusterIP   10.128.82.208   <none>        9402/TCP   13m
service/cert-manager-webhook   ClusterIP   10.128.123.21   <none>        443/TCP    13m

NAME                                                READY   AGE
clusterissuer.cert-manager.io/letsencrypt-prod      True    12m
clusterissuer.cert-manager.io/letsencrypt-staging   True    12m

# ingress-nginx namespace content

Every 2.0s: kubectl -n ingress-nginx get deploy,pod,service,ingress                                                                                                         docker-desktop: Thu Nov 17 17:52:49 2022

NAME                                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/ingress-nginx-controller   1/1     1            1           12m

NAME                                            READY   STATUS      RESTARTS   AGE
pod/ingress-nginx-admission-create-jmkfh        0/1     Completed   0          12m
pod/ingress-nginx-admission-patch-96lgn         0/1     Completed   0          12m
pod/ingress-nginx-controller-7d5fb757db-n4pbn   1/1     Running     0          12m

NAME                                         TYPE           CLUSTER-IP       EXTERNAL-IP       PORT(S)                      AGE
service/ingress-nginx-controller             LoadBalancer   10.128.35.90     139.144.159.177   80:31614/TCP,443:32281/TCP   12m
service/ingress-nginx-controller-admission   ClusterIP      10.128.227.210   <none>            443/TCP                      12m

# demo-https namespace content
Every 2.0s: kubectl -n demo-https get deploy,pod,service,ingress,Issuers,ClusterIssuers,Certificates,CertificateRequests,Orders,Challenges                                  docker-desktop: Thu Nov 17 17:53:26 2022

NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/echo1   1/1     1            1           11m
deployment.apps/echo2   1/1     1            1           11m

NAME                         READY   STATUS    RESTARTS   AGE
pod/echo1-696c97776-d2qdc    1/1     Running   0          11m
pod/echo2-67c5f6bdc4-6gsbp   1/1     Running   0          11m

NAME            TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
service/echo1   ClusterIP   10.128.153.6    <none>        80/TCP    11m
service/echo2   ClusterIP   10.128.85.149   <none>        80/TCP    11m

NAME                                     CLASS    HOSTS                                      ADDRESS           PORTS     AGE
ingress.networking.k8s.io/echo-ingress   <none>   139-144-159-177.ip.linodeusercontent.com   139.144.159.177   80, 443   11m

NAME                                                READY   AGE
clusterissuer.cert-manager.io/letsencrypt-prod      True    13m
clusterissuer.cert-manager.io/letsencrypt-staging   True    13m

NAME                                           READY   SECRET             AGE
certificate.cert-manager.io/letsencrypt-prod   True    letsencrypt-prod   11m

NAME                                                        APPROVED   DENIED   READY   ISSUER             REQUESTOR                                         AGE
certificaterequest.cert-manager.io/letsencrypt-prod-t7rfg   True                True    letsencrypt-prod   system:serviceaccount:cert-manager:cert-manager   10m

NAME                                                          STATE   AGE
order.acme.cert-manager.io/letsencrypt-prod-t7rfg-980989560   valid   10m
```

> Note 
> the *ingress.networking.k8s.io/echo-ingress * represents an ingress with hostname *139-144-159-177.ip.linodeusercontent.com* and will get a let's encrypt production certificate for  *139-144-159-177.ip.linodeusercontent.com*, the ip address 139.144.159.177 math the public ip assigned to the ingress service/ingress-nginx-controller. When deploying the ngix-ingress Linode assign an EXTERNAL-IP and generates a NodeBalancer for it.  



To test that everything works fine
```sh
curl 139-144-159-177.ip.linodeusercontent.com/echo1
```

To cleanup everything including the cluster
```sh
task lks-destroy
```

