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
