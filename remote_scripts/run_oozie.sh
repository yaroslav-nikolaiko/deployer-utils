#!/usr/bin/env bash

job_properties=$1
oozieServer=$2

oozie job -oozie ${oozieServer}/oozie -config ${job_properties} -run 2>&1