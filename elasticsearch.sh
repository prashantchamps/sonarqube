#!/bin/sh
# elasticsearch.sh
# Use the configuration file SonarQube provides, but keep everything else at the default
cp /opt/sonarqube/temp/conf/es/elasticsearch.yml /opt/sonarqube/elasticsearch/config
# Run the ElasticSearch node (without forcing the bootstrap checks)
exec java \
-XX:+UseConcMarkSweepGC \
-XX:CMSInitiatingOccupancyFraction=75 \
-XX:+UseCMSInitiatingOccupancyOnly \
-Des.networkaddress.cache.ttl=60 \
-Des.networkaddress.cache.negative.ttl=10 \
-XX:+AlwaysPreTouch \
-Xss1m \
-Djava.awt.headless=true \
-Dfile.encoding=UTF-8 \
-Djna.nosys=true \
-XX:-OmitStackTraceInFastThrow \
-Dio.netty.noUnsafe=true \
-Dio.netty.noKeySetOptimization=true \
-Dio.netty.recycler.maxCapacityPerThread=0 \
-Dlog4j.shutdownHookEnabled=false \
-Dlog4j2.disable.jmx=true \
-Djava.io.tmpdir=/opt/sonarqube/temp \
-XX:ErrorFile=../logs/es_hs_err_pid%p.log \
-Xms512m \
-Xmx512m \
-XX:+HeapDumpOnOutOfMemoryError \
-Des.path.home=/opt/sonarqube/elasticsearch \
-Des.path.conf=/opt/sonarqube/elasticsearch/config \
-Des.distribution.flavor=default \
-Des.distribution.type=tar \
-cp '/opt/sonarqube/elasticsearch/lib/*' \
org.elasticsearch.bootstrap.Elasticsearch