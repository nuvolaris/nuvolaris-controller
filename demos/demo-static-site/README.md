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
- Setup a NGINX-INGRESS serving a URL similar to https://<namespace>.domain.xx/<path> which will serve the content from MINIO hosted in the bucket <namespace>/<path>

This demo has been implemented using a MICROK8S environment installed on a AWS EC2 server and provides and assumes that the MINIO mc client is installed to interact with the MINIO server to upload static content for testing.

- a minio server at URL https://minio.server.44.203.144.96.nip.io
- a nginx webserver at URL https://namespace.44.203.144.96.nip.io

to test it just open the web browser at URLs https://namespace.44.203.144.96.nip.io/static1/ , https://namespace.44.203.144.96.nip.io/static2/, https://namespace.44.203.144.96.nip.io/static3/

A taskfile is provided to simplify the demo setup:

- `task all` to deploy all the basic component
- `task minio-alias` to setup an alias for the minio server to be used by the mc CLI tool
- `task deploy:content` to upload some static content under the `akamai` bucket

If everithing is OK executing `kubectl -n minio get pods,svc,pvc,ingress,secrets` this should be the result

```
NAME                                    READY   STATUS    RESTARTS   AGE
pod/nginx-deployment-6d8754858b-gxh2s   1/1     Running   0          97s
pod/minio-test-dep-6489455b9d-djp4b     1/1     Running   0          99s

NAME                  TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
service/staticminio   ClusterIP   10.152.183.51   <none>        9001/TCP,9091/TCP   99s
service/nginx-svc     ClusterIP   10.152.183.69   <none>        80/TCP              97s

NAME                                    STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS        AGE
persistentvolumeclaim/minio-pvc-claim   Bound    pvc-e2b82b5e-d9db-4c33-8f6c-a610c194fcfc   2Gi        RWO            microk8s-hostpath   99s

NAME                                      CLASS    HOSTS                               ADDRESS     PORTS     AGE
ingress.networking.k8s.io/minio-ingress   <none>   minio.server.44.203.144.96.nip.io   127.0.0.1   80, 443   99s
ingress.networking.k8s.io/nginx-ingress   <none>   namespace.44.203.144.96.nip.io      127.0.0.1   80, 443   97s

NAME                                TYPE                DATA   AGE
secret/namespace-nginx-tls-secret   kubernetes.io/tls   2      95s
secret/minio-server-tls-secret      kubernetes.io/tls   2      73s
```

### Note
This demo assumes that access to a specific namespace bucket is exposed via an ad hoc ingress which will expose the bucket content over https using a let's encrypt provisioned certificates. The ingress contains some specific configuration to automatically forward all the requests to the specific MINIO bucket using these annotations

- `nginx.ingress.kubernetes.io/use-regex: "true"`
- `nginx.ingress.kubernetes.io/rewrite-target: /namespace/$1`

together with the path expression `path: /(.*)`

```
....
      nginx.ingress.kubernetes.io/use-regex: "true"
      nginx.ingress.kubernetes.io/rewrite-target: /namespace/$1
spec:
  tls:
    - hosts:
      - namespace.44.203.144.96.nip.io
      secretName: namespace-nginx-tls-secret
  rules:
    - host: namespace.44.203.144.96.nip.io
      http:
        paths:
          - path: /(.*)
            pathType: Prefix
            backend:
              service:
                name: nginx-svc
                port: 
                  number: 80  
....      
```

the NGINX service `nginx-svc` default configuration contains essentially the required proxy rules to forward all the request to a MINIO instance

```
...
    location / {
        rewrite ^/$ ${request_uri}index.html break;
        rewrite (.*)/$ $1/index.html;        
        rewrite ^([^.]*[^/])$ $1/ permanent;
        
        proxy_hide_header     x-amz-id-2;
        proxy_hide_header     x-amz-meta-etag;
        proxy_hide_header     x-amz-request-id;
        proxy_hide_header     x-amz-meta-server-side-encryption;
        proxy_hide_header     x-amz-server-side-encryption;        
        proxy_set_header Host $http_host;

        proxy_pass http://staticminio.minio.svc.cluster.local:9001/;
	    proxy_redirect     off;
    } 
...     
```
