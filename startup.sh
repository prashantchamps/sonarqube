#!/bin/sh
# startup.sh
SONAR_VERSION=9.0.0.45539
SONARQUBE_HOME=/opt/sonarqube
# Download SonarQube and put it into an ephemeral folder
wget -O /tmp/sonarqube.zip https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-$SONAR_VERSION.zip
mkdir /opt
unzip /tmp/sonarqube.zip -d /opt/
mv /opt/sonarqube-$SONAR_VERSION /opt/sonarqube
chmod 0777 -R $SONARQUBE_HOME
# Workaround for ElasticSearch
adduser -DH elasticsearch
echo "su - elasticsearch -c '/bin/sh /home/site/wwwroot/elasticsearch.sh'" > /opt/sonarqube/elasticsearch/bin/elasticsearch
# Install any plugins
cd $SONARQUBE_HOME/extensions/plugins
wget https://github.com/hkamel/sonar-auth-aad/releases/download/1.1/sonar-auth-aad-plugin-1.1.jar
# Start the server
cd $SONARQUBE_HOME
exec java -jar lib/sonar-application-$SONAR_VERSION.jar \
  -Dsonar.log.console=true \
  -Dsonar.jdbc.username="$SONARQUBE_JDBC_USERNAME" \
  -Dsonar.jdbc.password="$SONARQUBE_JDBC_PASSWORD" \
  -Dsonar.jdbc.url="$SONARQUBE_JDBC_URL" \
  -Dsonar.web.port="$WEBSITES_PORT" \
  -Dsonar.web.javaAdditionalOpts="$SONARQUBE_WEB_JVM_OPTS -Djava.security.egd=file:/dev/./urandom"
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