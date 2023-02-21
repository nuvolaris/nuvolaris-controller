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
# Minio static site hosting DEMO

This demo is part of the Nuvolaris project, an [Open Source](https://opensource.org/) project to build a complete and portable [Serverless](https://martinfowler.com/articles/serverless.html) environment that runs in every [Kubernetes](https://kubernetes.io/).

Purpose of the demo

- Setup a MINIO server to be used to host static content inside a buckets having similar structure <namespace>/<path>
- Setup a NGINX server capable to serve content from MINIO
- Setup a NGINX-INGRESS serving a RUL similar to https://<namespace>.domain.xx/<path> which will serve the content from MINIO hosted in the bucket <namespace>/<path>

This demo has been implemented using a MICROK8S environment installed on a AWS EC2 server and provides and assumes that the MINIO mc client is installed to interact with the MINIO server to upload static content for testing.

- a minio server at URL https://nuvolaris.minio.44.203.144.96.nip.io 
- a nginx webserver at URL https://akamai.44.203.144.96.nip.io

to test it just open the web browser at URLs https://akamai.44.203.144.96.nip.io/static1/ , https://akamai.44.203.144.96.nip.io/static2/, https://akamai.44.203.144.96.nip.io/static3/

A taskfile is provided to simplify the demo setup:

- `task all` to deploy all the basic component
- `task minio-alias` to setup an alias for the minio server to be used by the mc CLI tool
- `task deploy:content` to upload some static content under the `akamai` bucket

If everithing is OK executing `kubectl -n minio get pods,svc,pvc,ingress,secrets` this should be the result

```
NAME                                    READY   STATUS    RESTARTS   AGE
pod/nginx-deployment-6d8754858b-rttct   1/1     Running   0          16m
pod/minio-test-dep-6489455b9d-vxtc9     1/1     Running   0          16m

NAME                  TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE
service/staticminio   ClusterIP   10.152.183.85    <none>        9001/TCP,9091/TCP   16m
service/nginx-svc     ClusterIP   10.152.183.157   <none>        80/TCP              16m

NAME                                    STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS        AGE
persistentvolumeclaim/minio-pvc-claim   Bound    pvc-333f58a5-5379-4391-9142-dc79b2c6f22b   2Gi        RWO            microk8s-hostpath   16m

NAME                                      CLASS    HOSTS                                  ADDRESS     PORTS     AGE
ingress.networking.k8s.io/minio-ingress   <none>   nuvolaris.minio.44.203.144.96.nip.io   127.0.0.1   80, 443   16m
ingress.networking.k8s.io/nginx-ingress   <none>   akamai.44.203.144.96.nip.io            127.0.0.1   80, 443   16m

NAME                             TYPE                DATA   AGE
secret/minio-tls-secret          kubernetes.io/tls   2      16m
secret/akamai-nginx-tls-secret   kubernetes.io/tls   2      15m
```
