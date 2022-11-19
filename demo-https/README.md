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
# Ingress with HTTPS protocol enabled demo (with Let's encrypt based certificates): 

> References:
>* EKS
>   * https://aws.amazon.com/blogs/opensource/network-load-balancer-nginx-ingress-controller-eks/
>   * https://docs.aws.amazon.com/prescriptive-guidance/latest/patterns/set-up-end-to-end-encryption-for-applications-on-amazon-eks-using-cert-manager-and-let-s-encrypt.html
>   * https://aws.amazon.com/blogs/containers/setting-up-end-to-end-tls-encryption-on-amazon-eks-with-the-new-aws-load-balancer-controller/
>* https://www.digitalocean.com/community/tutorials/how-to-set-up-an-nginx-ingress-with-cert-manager-on-digitalocean-kubernetes
>* https://blog.palark.com/using-ssl-certificates-from-lets-encrypt-in-your-kubernetes-ingress-via-cert-manager/

## Scope

This folder contains various kubernetes configuration files to showcase how to setup and https protected ingress expsosing http enabled services. The general idea it is to:

* Setup a Certificate Manager under an ad hoc cert-mamager namespace
* Deploy a couple of http echo services
* Deploy a cluster wide certificate issuer using let's encrypt staging environment (or production for real projects)
* Deploy an ingress exposing the 2 echo services with https certificate released by the deployed let's encrypt issuer

The showcase covers different kubernetes deployment scenarios

>* [local](standard/KIND.md)
>* [microk8s](microk8s/MICROK8S.md)
>* [AWS EKS](eks/EKS.md)
>* [LKS (Akamai Cloud Computing)](lks/LKS.md)
>* Azure (Available as PR)