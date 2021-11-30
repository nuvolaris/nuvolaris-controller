#!/bin/bash
java $EXTRA_JVM_ARGS\
 -Dwhisk.standalone.host.name="$(hostname)"\
 -Dwhisk.standalone.host.internal="$(hostname -i)"\
 -Dwhisk.standalone.host.external="$HOST_EXTERNAL" \
 -jar /usr/lib/openwhisk-standalone.jar --no-browser "$@"
