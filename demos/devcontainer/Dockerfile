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

FROM ubuntu:20.04
LABEL maintainer="Michele Sciabarra michele@nuvolaris.io"
# configure dpkg && timezone
ENV TZ=Europe/London
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections ;\
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime ;\
    echo $TZ > /etc/timezone
# add docker and java (amazon corretto) repos
RUN apt-get update && apt-get -y upgrade &&\
    apt-get -y install \
    software-properties-common apt-utils \
    lsb-release ca-certificates \
    curl wget gpg sudo \
    socat telnet inetutils-ping \
    unzip vim telnet less sudo git jq \
    python2 python3-pip gcc g++ make \
    silversearcher-ag
# install java (amazon corretto) and libs
RUN wget -O- https://apt.corretto.aws/corretto.key | apt-key add - ;\
    add-apt-repository 'deb https://apt.corretto.aws stable main' ;\
    apt-get update && apt-get -y install java-11-amazon-corretto-jdk ;\
    pip3 install --upgrade pip setuptools six 
# python2 stuff
RUN ln -sf /usr/bin/python2 /usr/bin/python ;\
    curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py ;\
    python get-pip.py ;\
    python -m pip install ansible==2.8.18 pydocumentdb humanize requests
# docker
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu bionic stable" > /etc/apt/sources.list.d/docker.list ;\
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor > /usr/share/keyrings/docker-archive-keyring.gpg ;\
    apt-get update && apt-get -y install docker-ce-cli
# bloop and coursier
RUN curl -sfLo /usr/bin/cs https://git.io/coursier-cli-"$(uname | tr LD ld)" ;\
    chmod +x /usr/bin/cs ;\
    cs install bloop --only-prebuilt=true --install-dir /usr/local/bin
# user
RUN useradd -m nuvolaris -s /bin/bash ;\
    echo "nuvolaris ALL=(ALL:ALL) NOPASSWD: ALL" >>/etc/sudoers
# node
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash ;\
    apt-get install -y nodejs ;\
    curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /usr/share/keyrings/yarnkey.gpg >/dev/null ;\
    echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | tee /etc/apt/sources.list.d/yarn.list ;\
    apt-get update && sudo apt-get install yarn
# task
RUN sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b /usr/local/bin
# kind
RUN curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.17.0/kind-linux-amd64 ;\
    chmod +x ./kind ; mv ./kind /usr/local/bin/kind
# ansible
COPY dockerip.yml /etc/dockerip.yml
COPY setup.sh /etc/setup.sh
ENV ANSIBLE_CMD="ansible-playbook -i environments/local -e docker_image_prefix=testing -e @/etc/dockerip.yml"
# commands
ENV HOME=/home/nuvolaris
ENV GRADLE_PROJS_SKIP=""
WORKDIR /home/nuvolaris

ENTRYPOINT /usr/bin/socat \
    UNIX-LISTEN:/var/run/docker.sock,fork,mode=660,user=nuvolaris \
    UNIX-CONNECT:/var/run/docker-host.sock
