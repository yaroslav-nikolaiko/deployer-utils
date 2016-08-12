#!/bin/bash
BASEDIR=$(dirname $0)

touch merge.dst.tmp

previousArg=''

for var in "$@"
do
	if [ "$previousArg" = '--cluster' ]; then
		cat ${BASEDIR}/conf/clusters/${var}/cluster.properties >> merge.dst.tmp
	elif [ -f "$var" ]; then
		cat "$var" >> merge.dst.tmp
	fi	
	
	previousArg=${var}
done

[ -f 'merge.dst.tmp' ] &&{
	cat 'merge.dst.tmp'
	rm 'merge.dst.tmp'
}
