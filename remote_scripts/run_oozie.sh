#!/usr/bin/env bash

job_properties=$3
oozieServer=$4

oozie job -oozie ${oozieServer}/oozie -config ${job_properties} -run
