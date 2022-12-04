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
## AWS

The demo is based on https://docs.aws.amazon.com/prescriptive-guidance/latest/patterns/set-up-end-to-end-encryption-for-applications-on-amazon-eks-using-cert-manager-and-let-s-encrypt.html using a normal ingress instead of a virtual server as suggested
in the article. It deploys an AWS NLB configured in AWS Route53 with hostname *securedemo-nuvolaris.eu*

> Tested with EKS running Kubernetes 1.22

```sh
# initialize an EKS cluster called nuvolaris cluster
task eks-create

# setup the certificate manager
task setup-cm

# deploy 
task eks:deploy
```

if everything is correct these are the different components deployed inside the EKS nuvolaris-cluster

```sh
# cert-manager namespace content
Every 2.0s: kubectl -n cert-manager get deploy,pod,service,ingress,Issuers,ClusterIssuers,Certificates,CertificateRequests,Orders,Challenges                                                        docker-desktop: Tue Nov 15 11:46:38 2022

NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/cert-manager              1/1     1            1           4h19m
deployment.apps/cert-manager-cainjector   1/1     1            1           4h19m
deployment.apps/cert-manager-webhook      1/1     1            1           4h19m

NAME                                          READY   STATUS    RESTARTS   AGE
pod/cert-manager-84bc577876-lfrpq             1/1     Running   0          4h19m
pod/cert-manager-cainjector-99d4695d7-vkl4h   1/1     Running   0          4h19m
pod/cert-manager-webhook-7bff7c658f-8csz5     1/1     Running   0          4h19m

NAME                           TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
service/cert-manager           ClusterIP   10.100.72.50    <none>        9402/TCP   4h19m
service/cert-manager-webhook   ClusterIP   10.100.17.147   <none>        443/TCP    4h19m

NAME                                                READY   AGE
clusterissuer.cert-manager.io/letsencrypt-prod      True    3h27m
clusterissuer.cert-manager.io/letsencrypt-staging   True    13h

# ingress-nginx namespace content

Every 2.0s: kubectl -n ingress-nginx get deploy,pod,service,ingress                                                                                                                                 docker-desktop: Tue Nov 15 11:53:05 2022

NAME                                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/ingress-nginx-controller   1/1     1            1           3h42m

NAME                                            READY   STATUS      RESTARTS   AGE
pod/ingress-nginx-admission-create-zn2lh        0/1     Completed   0          3h42m
pod/ingress-nginx-admission-patch-m5x7v         0/1     Completed   1          3h42m
pod/ingress-nginx-controller-666f45c794-9594c   1/1     Running     0          3h42m

NAME                                         TYPE           CLUSTER-IP      EXTERNAL-IP                                                                        PORT(S)                      AGE
service/ingress-nginx-controller             LoadBalancer   10.100.174.14   a12663d4407b9448a9facfb75f87cdf4-c4efbaab28eaaae0.elb.eu-central-1.amazonaws.com   80:30687/TCP,443:30958/TCP   3h42m
service/ingress-nginx-controller-admission   ClusterIP      10.100.44.245   <none>                                                                             443/TCP                      3h42m

# demo-https namespace content

Every 2.0s: kubectl -n demo-https get deploy,pod,service,ingress,Issuers,ClusterIssuers,Certificates,CertificateRequests,Orders,Challenges                                                          docker-desktop: Tue Nov 15 11:54:06 2022

NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/echo1   1/1     1            1           4h26m
deployment.apps/echo2   1/1     1            1           4h26m

NAME                         READY   STATUS    RESTARTS   AGE
pod/echo1-7bf4b77fd6-r86tr   1/1     Running   0          4h26m
pod/echo2-79f694787b-52vcq   1/1     Running   0          4h26m

NAME            TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
service/echo1   ClusterIP   10.100.181.66   <none>        80/TCP    4h26m
service/echo2   ClusterIP   10.100.145.80   <none>        80/TCP    4h26m

NAME                                     CLASS    HOSTS                     ADDRESS                                                                            PORTS     AGE
ingress.networking.k8s.io/echo-ingress   <none>   securedemo-nuvolaris.eu   a12663d4407b9448a9facfb75f87cdf4-c4efbaab28eaaae0.elb.eu-central-1.amazonaws.com   80, 443   132m

NAME                                                READY   AGE
clusterissuer.cert-manager.io/letsencrypt-prod      True    3h34m
clusterissuer.cert-manager.io/letsencrypt-staging   True    14h

NAME                                           READY   SECRET             AGE
certificate.cert-manager.io/letsencrypt-prod   True    letsencrypt-prod   130m

NAME                                                        APPROVED   DENIED   READY   ISSUER             REQUESTOR                                         AGE
certificaterequest.cert-manager.io/letsencrypt-prod-lggcc   True                True    letsencrypt-prod   system:serviceaccount:cert-manager:cert-manager   130m

NAME                                                           STATE   AGE
order.acme.cert-manager.io/letsencrypt-prod-lggcc-1491764550   valid   130m
```

> Note 
> the *service/ingress-nginx-controller* represents an AWS NLB with hostname *a12663d4407b9448a9facfb75f87cdf4-c4efbaab28eaaae0.elb.eu-central-1.amazonaws.com* and the same address is used by the *ingress.networking.k8s.io/echo-ingress* ingress linked to host  *securedemo-nuvolaris.eu*.

> To have fully working example with a let's encrypt certificate generated for the host *securedemo-nuvolaris.eu* it is necessary to create an A record in Route53 pointing to the the AWS NLB *a12663d4407b9448a9facfb75f87cdf4-c4efbaab28eaaae0.elb.eu-central-1.amazonaws.com*

To test that everything works fine
```sh
curl https://securedemo-nuvolaris.eu/echo2
```

To cleanup everything including the cluster
```sh
task eks-destroy
```