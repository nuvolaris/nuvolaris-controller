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

# Ingress Demo
Simple demo on using [ingress-nginx]() for serving static files hosted on a S3 compatible storage ([S3 Ninja](https://github.com/scireum/s3ninja)).


## How to run

### 1. Initialize the solution
```shell
task init
```

The command above runs a task that does the following: 
* deploy ingress-nginx as ingress controller
* deploy s3ninja as S3 compatible storage
* configure an ingress that forwards all the requests to the s3ninja svc
* create a list of buckets on s3ninja and, for each of them, upload a random html file to it.

The initialization should take around 1 minute.

### 2. Enable port forwarding 
In order to be able to access the ingress controller from your browser, forward the port 8080 on your machine to the port 80 of the ingress service:
```shell
kubectl port-forward --namespace=ingress-nginx service/ingress-nginx-controller 8080:80
```

Replace <bucket> with the actual bucket name.

### 3. Access the HTML files from your browser
You can access the HTML files stored in the S3 buckets from your browser by navigating to the following URL:
```
http://<bucket>.localhost:8080/<filename>
```

You can get the list of buckets with the respective files by running the following task:
```shell
task list-files
```
