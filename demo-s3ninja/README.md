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

## Known issues
### 1. Creating buckets with the same name does not return any error
When creating multiple buckets with the same name, S3 Ninja does not return any error, even though 
it does not create the buckets either. 

The expected result instead was to get an error with code s3.ErrCodeBucketAlreadyExists, 
as described in the [aws go sdk documentation](https://docs.aws.amazon.com/sdk-for-go/api/service/s3/#S3.CreateBucket).

### 2. Using "hostname -f" instead of "localhost" as S3 Ninja URL
When using the full hostname (e.g. hostname -f) in the URL for connecting to S3 Ninja, GET requests work fine but PUT
requests fail with the following error:

```html
<!DOCTYPE html><html lang="en"><head><meta http-equiv="X-UA-Compatible" content="IE=Edge"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Error - S3 ninja</title><link rel="stylesheet" media="screen" href="/assets/dynamic/80b55a44814af111623c1cb7d3627cb6/tycho/lib.css"><link rel="stylesheet" media="screen" href="/assets/dynamic/80b55a44814af111623c1cb7d3627cb6/tycho/libs/fontawesome/css/all.css"><link rel="stylesheet" media="screen" href="/assets/dynamic/80b55a44814af111623c1cb7d3627cb6/tycho/styles/tycho.css"><link rel="shortcut icon" type="image/vnd.microsoft.icon" href="/assets/dynamic/80b55a44814af111623c1cb7d3627cb6/tycho/images/favicon.ico"><script type="text/javascript">try{electronRemote="undefined"!=typeof electronRemote&&electronRemote?electronRemote:require("electron").remote,electronIpc="undefined"!=typeof electronIpc&&electronIpc?electronIpc:require("electron").ipcRenderer}catch(e){electronRemote=null,electronIpc=null}"object"==typeof module&&(window._module=module,module=void 0)</script><script src="/assets/dynamic/80b55a44814af111623c1cb7d3627cb6/tycho/lib.js" type="text/javascript"></script><script src="/assets/dynamic/80b55a44814af111623c1cb7d3627cb6/tycho/libs/fontawesome/js/all.js" type="text/javascript"></script><script src="/assets/dynamic/80b55a44814af111623c1cb7d3627cb6/tycho/scripts/tycho.js" type="text/javascript"></script><script type="text/javascript">// This cannot be moved into tycho.js as it has to be re-evaluated for each call and must not be cached...
        const tycho_current_locale = 'en';</script></head><body><div id="wrapper"><div id="wrapper-menu" class="sticky-top-lg"><nav class="navbar navbar-expand-lg navbar-light bg-white"><a class="navbar-brand" href="/"><img src="/assets/dynamic/80b55a44814af111623c1cb7d3627cb6/tycho/images/menu_logo.svg" height="33px" alt="Start"></a><button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation"><span class="navbar-toggler-icon"></span></button><div class="collapse navbar-collapse" id="navbarSupportedContent"><ul class="navbar-nav mr-auto"></ul><ul class="navbar-nav"></ul></div></nav></div><div id="wrapper-body" class="d-flex flex-column"><div id="page-header"><div class="container-fluid"><div id="page-nav"><div class="d-flex flex-column flex-lg-row"></div></div></div></div><div id="main-container" class="container-fluid mb-2 pb-lg-5"><div class="card shadow-sm mb-4 page-header"><div class="card-body pl-3 pr-3 pt-3 pb-1"><div class="d-flex flex-row"><a class="btn btn-link btn-outline-link sidebar-button-js d-none d-lg-none mr-2"><i class="fa fa-bars"></i></a><h1 class="legend mr-auto overflow-hidden text-nowrap">Error</h1></div><div class="mt-2 d-flex flex-wrap"><span><span class="mb-2 mr-2 dot-block"><span class="d-inline-block dot mr-1 bg-sirius-red">&nbsp;</span><div>500 - Internal Server Error</div></span></span></div></div></div><div class="row"><div class="col-12" id="message-box"></div></div><div class="card"><div class="card-body"><h5 class="card-title">Diagnostic</h5><div class="mb-4"><pre style="font-size:small">sirius.kernel.health.HandledException: An unexpected exception occurred: PUT (java.lang.IllegalArgumentException)
        at sirius.kernel.health.Exceptions$ErrorHandler.handle(Exceptions.java:234)
        at sirius.kernel.health.Exceptions.handle(Exceptions.java:393)
        at sirius.web.http.DispatcherPipeline.handleInternalServerError(DispatcherPipeline.java:106)
        at sirius.web.http.DispatcherPipeline.dispatch(DispatcherPipeline.java:97)
        at sirius.web.http.DispatcherPipeline.lambda$dispatch$1(DispatcherPipeline.java:65)
        at sirius.kernel.async.ExecutionBuilder$TaskWrapper.run(ExecutionBuilder.java:123)
        at java.base/java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1136)
        at java.base/java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:635)
        at java.base/java.lang.Thread.run(Thread.java:833)
Caused by: java.lang.IllegalArgumentException: PUT
        at ninja.S3Dispatcher.listBuckets(S3Dispatcher.java:427)
        at ninja.S3Dispatcher.dispatch(S3Dispatcher.java:237)
        at sirius.web.http.DispatcherPipeline.dispatch(DispatcherPipeline.java:80)
        ... 5 more
</pre></div><ul><li><b>Node:</b>s3ninja-69cdcfb96c-crnxd</li><li><b>Duration:</b>6 Milliseconds</li><li><b>parent:</b>HTTP::GENERIC::/</li><li><b>scope:</b>default</li><li><b>userId:</b>(public)</li><li><b>flow:</b>s3ninja-69cdcfb96c-crnxd/2327</li><li><b>username:</b>(public)</li></ul></div></div></div></div><div id="wrapper-footer" class="fixed-bottom-lg"><div class="footer"><div class="container-fluid d-flex justify-content-between"><div><div class="d-flex flex-row overflow-hidden"><span class="small">S3 ninja emulates the S3 API for development and testing purposes.</span></div></div><div class="text-right"><span class="d-none d-md-inline-block"><a class="text-muted small cycle-js cursor-pointer" data-cycle="7 ms (Version: 7.2.4, Build: 284 (2022-01-24 10:06), Revision: 4963affd9a159316bec47b487f4582613ad4bebe)">s3ninja-69cdcfb96c-crnxd</a></span></div></div></div></div></div><div id="link-confirm-modal" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="link-confirm-modalTitle"><div class="modal-dialog" role="document"><div class="modal-content"><div class="modal-header"><h4 class="modal-title" id="link-confirm-modalTitle">Are you sure?</h4><button type="button" class="close" data-dismiss="modal" aria-label="Close"><i class="fa fa-times" aria-hidden="true"></i></button></div><div class="modal-body"><p>Press &#039;Yes&#039; to continue or Cancel to go back.</p><form action="" method="post" class="confirm-form-js"><input name="CSRFToken" value="0f8b8bb5-d17c-4d54-b049-8a69a5d057a4" type="hidden"></form></div><div class="modal-footer"><button type="submit" class="btn btn-primary">Yes</button><button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button></div></div></div></div><script type="text/javascript">appendHistoryUrl("")</script></body></html>Node: s3ninja-69cdcfb96c-crnxd Duration: 6 Milliseconds parent: HTTP::GENERIC::/ scope: default userId: (public) flow: s3ninja-69cdcfb96c-crnxd/2327 username: (public) ​​<div id="wrapper-footer" class="fixed-bottom-lg">​<div class="footer"><div class="container-fluid d-flex justify-content-between">​<div>​<div class="d-flex flex-row overflow-hidden"><span class="small">​S3 ninja emulates the S3 API for development and testing purposes.</span></div>​</div>​<div class="text-right">​<span class="d-none d-md-inline-block">​<a class="text-muted small cycle-js cursor-pointer" data-cycle="7 ms (Version: 7.2.4, Build: 284 (2022-01-24 10:06), Revision: 4963affd9a159316bec47b487f4582613ad4bebe)">​s3ninja-69cdcfb96c-crnxd ​</a>​</span>​</div></div>
```
