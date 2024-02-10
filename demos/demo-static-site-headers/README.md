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

to test it just open the web browser at URLs https://namespace.44.203.144.96.nip.io/static1/ , https://namespace2.44.203.144.96.nip.io/static1/

A taskfile is provided to simplify the demo setup:

- `task setup` to initialize a minio namespace and minio itself running on port 9001
- `task minio-alias` to setup an alias for the minio server to be used by the mc CLI tool
- `task deploy:static` to deploy an ingress exposing the wildcard hostname `*.static.44.203.144.96.nip.io`

If everithing is OK executing `kubectl -n minio get pods,svc,pvc,ingress,secrets` this should be the result

```
NAME                                    READY   STATUS    RESTARTS   AGE
pod/minio-test-dep-6489455b9d-8zkxv     1/1     Running   0          22h
pod/nginx-deployment-6d8754858b-wjj5k   1/1     Running   0          4h42m

NAME                  TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE
service/staticminio   ClusterIP   10.152.183.83    <none>        9001/TCP,9091/TCP   22h
service/nginx-svc     ClusterIP   10.152.183.227   <none>        80/TCP              4h42m

NAME                                    STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS        AGE
persistentvolumeclaim/minio-pvc-claim   Bound    pvc-7e31e3d6-7c25-400e-a01c-1a49665851fd   2Gi        RWO            microk8s-hostpath   22h

NAME                                           CLASS    HOSTS                               ADDRESS     PORTS     AGE
ingress.networking.k8s.io/minio-ingress        <none>   minio.static.44.203.144.96.nip.io   127.0.0.1   80, 443   22h
ingress.networking.k8s.io/nginx-http-ingress   <none>   *.static.44.203.144.96.nip.io       127.0.0.1   80        4h42m

NAME                             TYPE                DATA   AGE
secret/minio-static-tls-secret   kubernetes.io/tls   2      22h
```

### Note
This demo assumes that access to a specific namespace bucket is exposed via a wildcard hostname based ingress which will expose the bucket content over http. As cert-manager requires DNS01 challenge to generate HTTPS certificate when using wildcard hostname. For the purpose of this demo https endpoint has not been provided. For reference aboiut the DNS01 challenge take a look at the official [cert-manager](https://cert-manager.io/docs/configuration/acme/dns01/) documentation.

```
....
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-http-ingress
  namespace: minio
  annotations:
      kubernetes.io/ingress.class: public
      nginx.ingress.kubernetes.io/proxy-body-size: "48m"
      nginx.ingress.kubernetes.io/proxy-connect-timeout: "600"
      nginx.ingress.kubernetes.io/proxy-send-timeout: "600"
      nginx.ingress.kubernetes.io/proxy-read-timeout: "600"
spec:
  rules:
    - host: "*.static.44.203.144.96.nip.io"
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: nginx-svc
                port: 
                  number: 80 
....      
```

the NGINX service `nginx-svc` contains a map processing to extract the requested MINIO bucket by parsing the Host header value and assign it to a `$namespace` variable.

```
map $http_host $namespace {
  default "nuvolaris";
  "~^(\S+)\.static\.44\.203\.144\.96\.nip\.io$" $1;
}
```

The default `/` location is defined to proxy the request to `http://staticminio.minio.svc.cluster.local:9001/$namespace${uri}`

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
        
        # as we add the namespace to the proxypass directive, we need to set the resolver to the internal kube-dns
        resolver kube-dns.kube-system.svc.cluster.local;

        proxy_pass http://staticminio.minio.svc.cluster.local:9001/$namespace${uri};     
	    proxy_redirect     off;
    } 
...     
```

The proxy_pass URL contains variable and therefore it is necessary to instruct NGINX to use a resolver. As the hostname `staticminio.minio.svc.cluster.local` it is the internal Kubernetes hostnmae linked to the MINIO service, as resolver value we use the Internal coreDNS hostname proper of Kubernetes itself `kube-dns.kube-system.svc.cluster.local`