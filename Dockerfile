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
FROM ubuntu:20.04 as builder
# download required component
ENV DOCKER_VERSION=18.06.3-ce
ENV WSK_VERSION=1.2.0
ENV DOCKER_BASE=https://download.docker.com/linux/static/stable
ENV WSK_BASE=https://github.com/apache/openwhisk-cli/releases/download
RUN apt-get update && apt-get -y install curl file
RUN DOCKER_URL="$DOCKER_BASE/$(arch)/docker-$DOCKER_VERSION.tgz" ;\
    curl -sL "$DOCKER_URL" | tar xzvf -
RUN ARCH=amd64 ; test $(arch) = "aarch64" && ARCH=arm64 ;\
    WSK_URL="$WSK_BASE/$WSK_VERSION/OpenWhisk_CLI-$WSK_VERSION-linux-$ARCH.tgz" ;\
    curl -sL "$WSK_URL" | tar xzvf -
FROM amazoncorretto:11
COPY openwhisk/bin/openwhisk-standalone.jar /usr/lib/openwhisk-standalone.jar
COPY --from=builder /docker/docker /usr/bin/docker
COPY --from=builder /wsk /usr/bin/wsk
ADD start.sh /usr/bin/start.sh
