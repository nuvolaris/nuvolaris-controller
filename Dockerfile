FROM amazoncorretto:11
COPY openwhisk/bin/openwhisk-standalone.jar /usr/lib/openwhisk-standalone.jar
COPY docker/docker /usr/bin/docker
COPY wsk/wsk /usr/bin/wsk
ADD start.sh /usr/bin/start.sh
