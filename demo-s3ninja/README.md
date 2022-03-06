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
# S3 Ninja Demo
Simple demo on using [S3 Ninja](https://github.com/scireum/s3ninja) for emulating Amazon S3 REST APIs for local development.
The goal is to demonstrate how to deploy S3 Ninja on a KIND k8s cluster and to interact with it using the [AWS Go SDK](https://github.com/aws/aws-sdk-go).

## How to run

### 1. Deploy S3 Ninja in your KIND k8s cluster
```shell
task deploy
```

The deployment should take few seconds. You can check its status by running:
```shell
task status
```

### 2. Upload random fles to a demo bucket
```shell
task upload-random-file
```
Each time you run the command, a random text file is uploaded to the demo bucket within S3 Ninja.

### 3. List bucket content
```shell
task list-files
```


### 4. Cleanup
```shell
task undeploy
```

