#!/usr/bin/env bash

workdir=$1
hdfs_path=$2

echo workdir=${workdir}
echo hdfs_path=${hdfs_path}

exit 0;

hdfs dfs -rm -r -skipTrash ${hdfs_path} || true
hdfs dfs -mkdir -p ${hdfs_path}
hdfs dfs -copyFromLocal ${workdir}/* ${hdfs_path}
