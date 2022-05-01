#!/usr/bin/env bash

export BASE=resources
export HADOOP_HOME=$BASE/hadoop-home
export HIVE_HOME=$BASE/hive-home

export HIVE_PATH=$HIVE_HOME/bin/
export HADOOP_PATH=$HADOOP_HOME/bin/

export HADOOP_CLASSPATH="${HADOOP_HOME}/share/hadoop/tools/lib/*:${HIVE_PATH}/lib:${HADOOP_HOME}/share/hadoop/common/lib"

export PATH=$PATH:$HIVE_PATH:$HADOOP_PATH

rm -f ${HIVE_HOME}/lib/guava-19.0.jar

schematool -initSchema -dbType postgres