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
# configure dpkg && timezone
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
ENV TZ=Europe/London
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
# add docker and java (amazon corretto) repos
RUN apt-get update && apt-get -y upgrade &&\
    apt-get -y install curl wget gpg software-properties-common apt-utils unzip vim
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor > /usr/share/keyrings/docker-archive-keyring.gpg &&\
    wget -O- https://apt.corretto.aws/corretto.key | apt-key add -
RUN ARCH=$(dpkg --print-architecture) ;\
    echo "deb [arch=$ARCH signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu bionic stable" > /etc/apt/sources.list.d/docker.list &&\
    add-apt-repository 'deb https://apt.corretto.aws stable main'
# install software
RUN apt-get update && \
 apt-get -y install \
   sudo socat git curl wget jq \
   lsb-release ca-certificates \
   java-11-amazon-corretto-jdk \
   docker-ce-cli
ADD openwhisk-standalone.jar /usr/lib/openwhisk-standalone.jar
ADD start.sh /bin/start.sh
CMD ["/bin/bash", "/bin/start.sh"]

