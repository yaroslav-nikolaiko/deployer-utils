#!/bin/bash
set -e

touch merge.dst.tmp

previousArg=''

for var in "$@"
do
	if [ "$previousArg" = '--cluster' ]; then
		cat ${DEPLOYER_CONF_DIR}/clusters/${var}/cluster.properties
	elif [ -f "$var" ]; then
		cat "$var" >> merge.dst.tmp
	fi	
	
	previousArg=${var}
done

[ -f 'merge.dst.tmp' ] &&{
	cat 'merge.dst.tmp'
	rm 'merge.dst.tmp'
}

exit 0
