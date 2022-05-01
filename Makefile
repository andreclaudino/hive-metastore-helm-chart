HIVE_METASTORE_VERSION=3.0.0
HIVE_METASTORE_URL=https://dlcdn.apache.org/hive/hive-standalone-metastore-$(HIVE_METASTORE_VERSION)/hive-standalone-metastore-$(HIVE_METASTORE_VERSION)-bin.tar.gz

HADOOP_VERSION=3.2.3
HADOOP_URL=https://dlcdn.apache.org/hadoop/common/hadoop-$(HADOOP_VERSION)/hadoop-$(HADOOP_VERSION).tar.gz

BASE=resources

DOCKER_IMAGE_NAME=andreclaudino/hive-metastore
DOCKER_IMAGE_TAG=1.0.0-hive3.0.0-hadoop3.2.3
DOCKER_IMAGE_TAG_SIMPLIFIED=1.0.0

METASTORE_SITE_FILE=metastore-site.template.xml

$(BASE):
	mkdir -p $(BASE)

$(BASE)/hive-home: $(BASE)
	wget -c $(HIVE_METASTORE_URL) -O $(BASE)/hive.tar.gz
	mkdir -p resources/hive-output
	tar -xzvf resources/hive.tar.gz -C resources/hive-output
	mv resources/hive-output/apache-hive-metastore-$(HIVE_METASTORE_VERSION)-bin $(BASE)/hive-home
	rm -rf resources/hive-output $(BASE)/hive.tar.gz

$(BASE)/hive-home/lib/postgresql-42.2.16.jar: $(BASE)/hive-home
	wget -c https://jdbc.postgresql.org/download/postgresql-42.2.16.jar -O $(BASE)/hive-home/lib/postgresql-42.2.16.jar

$(BASE)/hive-home/conf/metastore-site.xml: $(BASE)/hive-home
	cp $(METASTORE_SITE_FILE) $(BASE)/hive-home/conf/metastore-site.xml

$(BASE)/hadoop-home: $(BASE)
	wget -c $(HADOOP_URL) -O resources/hadoop.tar.gz
	mkdir -p resources/hadoop-output
	tar -xzvf resources/hadoop.tar.gz -C resources/hadoop-output
	mv resources/hadoop-output/hadoop-$(HADOOP_VERSION) $(BASE)/hadoop-home
	rm -rf resources/hadoop-output resources/hadoop.tar.gz

$(BASE)/setup-homes: $(BASE)/hive-home $(BASE)/hadoop-home $(BASE)/hive-home/lib/postgresql-42.2.16.jar
	touch resources/setup-homes

docker/image: $(BASE)/setup-homes
	docker build docker/ -f docker/Dockerfile -t $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG)
	touch docker/image

docker/push: docker/image
	docker push $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG)
	touch docker/push

docker/push-simplified: docker/image
	docker tag $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG) $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG_SIMPLIFIED)
	docker push $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG_SIMPLIFIED)
	touch docker/push-simplified

docker/push-latest: docker/image
	docker tag $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG) $(DOCKER_IMAGE_NAME):latest
	docker push $(DOCKER_IMAGE_NAME):latest
	touch docker/push-latest

docker/push-all: docker/push docker/push-latest docker/push-simplified
	touch docker/push-all
	
create-schema: $(BASE)/setup-homes
	bash bin/create-schema.sh

start: $(BASE)/setup-homes $(BASE)/hive-home/conf/metastore-site.xml
	bash bin/start.sh

clean:
	rm -rf resources
	rm -rf docker/image
	rm -rf docker/push
	rm -rf docker/push-latest
	rm -rf docker/push-all
	rm -rf docker/push-simplified
