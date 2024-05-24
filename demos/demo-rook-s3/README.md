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

- dev
    - controller
        - demos
            - demo-rook-s3
                - README.md
                - constants.sh
                - s3-policy.json
                - object.yaml
                - object-bucket-claim-delete.yaml
                - storageclass-bucket-delete.yaml
                - traefik-ingress.yaml

# CMDS

```kubectl apply -f rook-object-store.yaml```
will create the ceph object store into the rook-ceph namespace

```kubectl apply -f rook-storageclass.yaml``` 
will create the storage class for the object created above

```kubectl apply -f rook-object-bucket-claim.yaml``` 
will create the OBC into the namespace nuvolaris

```kubectl apply -f traefik-ingress.yaml``` 
will create the traefik ingress for the rook-bucket

```kubectl apply -f rook-nginx-cm.yaml``` 
will create the config map for rook-nginx

```kubectl apply -f rook-static-sts.yaml``` 
will create the stateful set for rook-nginx

```kubectl apply -f rook-nginx-static-svc.yaml``` 
will create the service for rook-nginx

```kubectl apply -f rook-middleware.yaml``` 
will create the middleware for rook-nginx

```kubectl apply -f rook-nginx-static-ingress.yaml``` 
will create the ingress for rook-nginx

```aws s3api put-bucket-policy --policy file://s3-policy.json --endpoint-url=https://rook-s3.metlabs.cloud --bucket ceph-bkt-57332554-f148-44e0-a988-d55773f79d8a```
set the public access policy S3


# TO-DO
- [X] middleware ingress to rook-ceph 
- [ ] perfezionare installazione objectstore
- [ ] gestione affinity sul OS
- [ ] installazione StorageClass DEL BUCKET che usa OS di cui sopra
- [ ] (optional) User Management granting access to 2 or more buckets to a user