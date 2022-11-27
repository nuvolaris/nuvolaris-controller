FROM ubuntu:20.04
LABEL maintainer="Michele Sciabarra michele@nuvolaris.io"
# configure dpkg && timezone
ENV TZ=Europe/London
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections ;\
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime ;\
    echo $TZ > /etc/timezone ;\
    useradd -m openwhisk
# add docker and java (amazon corretto) repos
RUN apt-get update && apt-get -y upgrade &&\
    apt-get -y install \
    software-properties-common apt-utils \
    lsb-release ca-certificates \
    curl wget gpg \
    socat telnet inetutils-ping \
    unzip vim telnet less sudo git \
    python2 python3-pip
# install java (amazon corretto) and libs
RUN wget -O- https://apt.corretto.aws/corretto.key | apt-key add - ;\
    add-apt-repository 'deb https://apt.corretto.aws stable main' ;\
    apt-get update && apt-get -y install java-11-amazon-corretto-jdk ;\
    pip3 install --upgrade pip setuptools six ;\
# python2 stuff
RUN ln -sf /usr/bin/python2 /usr/bin/python ;\
    curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py ;\
    python2 get-pip.py ;\
    python2 -m pip install ansible==2.8.18 pydocumentdb humanize requests
# docker
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu bionic stable" > /etc/apt/sources.list.d/docker.list ;\
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor > /usr/share/keyrings/docker-archive-keyring.gpg ;\
    apt-get update && apt-get -y install docker-ce-cli
# bloop and coursier
RUN curl -sfLo /usr/bin/cs https://git.io/coursier-cli-"$(uname | tr LD ld)" ;\
    chmod +x /usr/bin/cs ;\
    cs install bloop --only-prebuilt=true --install-dir /usr/bin
ENV HOME=/home/openwhisk
ENV ANSIBLE_CMD="ansible-playbook -i environments/local -e docker_image_prefix=testing"
ENV GRADLE_PROJS_SKIP=""
WORKDIR /home/openwhisk
ENTRYPOINT /usr/bin/socat \
  UNIX-LISTEN:/var/run/docker.sock,fork,mode=660,user=openwhisk \
  UNIX-CONNECT:/var/run/docker-host.sock
