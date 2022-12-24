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

OW=/workspaces/openwhisk
    export ANSIBLE_CMD="$ANSIBLE_CMD -e @$OW/.devcontainer/dockerip.yml"
    # super hacky trick to get the dockerid - assuming there is only one starting with vsc-
    DOCKERID=$(docker ps | awk '/vsc-openwhisk/{print $1}')
    # inspecting the image to find the real path on the host
    REAL_PWD=$(docker inspect $DOCKERID  | jq -r '.[0].Config.Labels["devcontainer.local_folder"]')
    # linking openwhisk to the home
    ln -sf $OW /home/nuvolaris/openwhisk
    # setting the tmp directory
    sudo mkdir -p $REAL_PWD
    sudo chmod 0777 $REAL_PWD
    test -d $OW/tmp || mkdir $OW/tmp
    ln -sf $OW/tmp $REAL_PWD/tmp
    export OPENWHISK_TMP_DIR=$REAL_PWD/tmp
    cd /home/nuvolaris/openwhisk
    ./tools/travis/setupPrereq.sh
    # cd ./tools/travis/
    # SCRIPTDIR=$PWD
    if test -e /.dockerenv
    then /usr/bin/socat \
        UNIX-LISTEN:/var/run/docker.sock,fork,mode=660,user=nuvolaris \
        UNIX-CONNECT:/var/run/docker-host.sock
    fi
