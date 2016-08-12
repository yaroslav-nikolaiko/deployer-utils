#!/bin/bash

[ -d target ] && rm -rf target

mkdir target

cp config-default.xml target


bash ../merge.sh --cluster big-lab9 application.properties > target/application.properties
bash ../substitute.sh config-default.xml target/application.properties > target/config-default.xml

