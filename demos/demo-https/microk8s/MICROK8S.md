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
## MICROK8S

> Tested with a microk8s cluster running on an AWS EC2 ubuntu istance preconfigured with the ingress and cert-manager add-on, and hostname 54.196.247.123.nip.io

```sh
# initialize a microk8s cluster (install microk8s) configuring the cluster with the hostname corresponding to the public ip address of the EC2 machine
task k8s-create

# copy the remote configuration to the local kubectl installation to control the cluster from a nuvolaris dev environment
task k8s-config

# deploy 
task k8s-deploy
```

if everything is correct these are the different components deployed inside the microk8s cluster

```sh
# cert-manager namespace content
Every 2.0s: kubectl -n cert-manager get deploy,pod,service,ingress,Issuers,ClusterIssuers,Certificates,CertificateRequests,Orders,Challenges                                                      

NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/cert-manager              1/1     1            1           3m39s
deployment.apps/cert-manager-cainjector   1/1     1            1           3m39s
deployment.apps/cert-manager-webhook      1/1     1            1           3m39s

NAME                                           READY   STATUS    RESTARTS   AGE
pod/cert-manager-655bf9748f-rzc6j              1/1     Running   0          2m4s
pod/cert-manager-cainjector-7985fb445b-fj8q9   1/1     Running   0          2m4s
pod/cert-manager-webhook-6dc9656f89-6dskx      1/1     Running   0          2m4s

NAME                           TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
service/cert-manager           ClusterIP   10.152.183.158   <none>        9402/TCP   3m40s
service/cert-manager-webhook   ClusterIP   10.152.183.124   <none>        443/TCP    3m40s

# ingress namespace content

Every 2.0s: kubectl -n ingress get deploy,pod,service,ingress                                                                                                                                     

NAME                                          READY   STATUS    RESTARTS   AGE
pod/nginx-ingress-microk8s-controller-zftm6   1/1     Running   0          2m31s

# demo-https namespace content
Every 2.0s: kubectl -n demo-https get deploy,pod,service,ingress,Issuers,ClusterIssuers,Certificates,CertificateRequests,Orders,Challenges                                                       
NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/echo1   1/1     1            1           42s
deployment.apps/echo2   1/1     1            1           41s

NAME                         READY   STATUS    RESTARTS   AGE
pod/echo1-784f6fbcc7-769vs   1/1     Running   0          42s
pod/echo2-6846b6f6f-4hb2c    1/1     Running   0          41s

NAME            TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
service/echo1   ClusterIP   10.152.183.206   <none>        80/TCP    43s
service/echo2   ClusterIP   10.152.183.246   <none>        80/TCP    42s

NAME                                     CLASS    HOSTS                   ADDRESS     PORTS     AGE
ingress.networking.k8s.io/echo-ingress   <none>   54.196.247.123.nip.io   127.0.0.1   80, 443   41s

NAME                                                READY   AGE
clusterissuer.cert-manager.io/letsencrypt-staging   True    45s
clusterissuer.cert-manager.io/letsencrypt-prod      True    45s

NAME                                           READY   SECRET             AGE
certificate.cert-manager.io/letsencrypt-prod   True    letsencrypt-prod   41s

NAME                                                        APPROVED   DENIED   READY   ISSUER             REQUESTOR                                         AGE
certificaterequest.cert-manager.io/letsencrypt-prod-qs6l2   True                True    letsencrypt-prod   system:serviceaccount:cert-manager:cert-manager   40s

NAME                                                           STATE   AGE
order.acme.cert-manager.io/letsencrypt-prod-qs6l2-1918872649   valid   40s
```

> Note 
> the *ingress.networking.k8s.io/echo-ingress * represents an ingress with hostname *54.196.247.123.nip.io* and will get a let's encrypt production certificate for  *54.196.247.123.nip.io*.
> It is important to note that the http01 solvers have the ingress class set to *public* when deployed on microk8s and additionally the *k8s-echo-ingress.yaml* uses the *kubernetes.io/ingress.class: "public"*
> this is extremenly important for microk8s clusters


To test that everything works fine
```sh
curl https://54.196.247.123.nip.io/echo1
```

To cleanup everything including the cluster
```sh
task k8s-destroy
```