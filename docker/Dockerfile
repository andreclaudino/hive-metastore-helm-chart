FROM openjdk:8-slim

LABEL image-name=andreclaudino/hive-metastore
LABEL maintainer="André Claudino"

# Enviromnets and arguments
ARG HADOOP_VERSION=3.2.3
ARG HIVE_METASTORE_VERSION=3.0.0
ARG POSTGRES_VERSION=42.2.16

ENV HIVE_METASTORE_URL=https://dlcdn.apache.org/hive/hive-standalone-metastore-$HIVE_METASTORE_VERSION/hive-standalone-metastore-$HIVE_METASTORE_VERSION-bin.tar.gz
ENV HADOOP_URL=https://dlcdn.apache.org/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz

ENV BASE=/installation

ENV HIVE_HOME=$BASE/hive-home
ENV HADOOP_HOME=$BASE/hadoop-home

EXPOSE 9083

RUN apt-get update && \
	apt-get install wget -y && \
	rm -rf /var/lib/apt/lists/*

# Download Hive Metastore Artifact and create hive-home
RUN mkdir -p $BASE && \
    wget -c $HIVE_METASTORE_URL -O $BASE/hive.tar.gz && \
    mkdir -p $BASE/hive-output && \
	tar -xzvf $BASE/hive.tar.gz -C $BASE/hive-output && \
	mv $BASE/hive-output/apache-hive-metastore-$HIVE_METASTORE_VERSION-bin $HIVE_HOME && \
	rm -rf $BASE/hive-output $BASE/hive.tar.gz && \
    rm -f ${HIVE_HOME}/lib/guava-19.0.jar

# Download postgres driver
RUN wget -c https://jdbc.postgresql.org/download/postgresql-$POSTGRES_VERSION.jar -O $BASE/hive-home/lib/postgresql-$POSTGRES_VERSION.jar

# Download Hadoop Artifact and create hadoop-home
RUN wget -c $HADOOP_URL -O $BASE/hadoop.tar.gz && \
    mkdir -p $BASE/hadoop-output && \
	tar -xzvf $BASE/hadoop.tar.gz -C $BASE/hadoop-output && \
	mv $BASE/hadoop-output/hadoop-$HADOOP_VERSION $HADOOP_HOME && \
	rm -rf $BASE/hadoop-output $BASE/hadoop.tar.gz

ENV HIVE_PATH=$HIVE_HOME/bin/
ENV HADOOP_PATH=$HADOOP_HOME/bin/
ENV HADOOP_CLASSPATH="${HADOOP_HOME}/share/hadoop/tools/lib/*:${HIVE_PATH}/lib:${HADOOP_HOME}/share/hadoop/common/lib"
ENV PATH=$PATH:$HIVE_PATH:$HADOOP_PATH

ADD create-schema.sh /bin/create-schema
RUN chmod +x /bin/create-schema

ADD start.sh /bin/start
RUN chmod +x /bin/start