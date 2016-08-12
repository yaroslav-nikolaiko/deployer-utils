#!/usr/bin/env bash

scriptsPath="/home/yaroslav/workspace/BigData/deployer-utils"
export PATH=${scriptsPath}:${PATH}

mvn clean package

cd target

tar -xjvf dapdistcp-wf-2.4.4-SNAPSHOT.tar.bz2

merge.sh --cluster big-lab9 ../application.properties > dapdistcp-wf/app.properties
cp  /home/yaroslav/workspace/INTROPRO/BigData/dap-di/dapdistcp-oozie-properties/datasets/ams/coordinator.properties dapdistcp-wf

substitute.sh dapdistcp-wf/coordinator.properties dapdistcp-wf/app.properties > dapdistcp-wf/job.properties

deploy.sh --cluster big-lab9 --sshProjectParent dap-di/distcp --project dapdistcp-wf
