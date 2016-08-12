#!/bin/bash
set -e

BASEDIR=$(dirname $0)


previousArg=''
for var in "$@"
do
	if [ "$previousArg" = '--cluster' ]; then
		cluster="$var"
	elif [ "$previousArg" = '--sshProjectParent' ]; then
		sshProjectParent="$var"
	elif [ "$previousArg" = '--project' ]; then
		project="$var"
	fi	
	previousArg=${var}
done

[ -z "${sshProjectParent}" ] && {
        echo "Please, specify sshProjectParent"
        exit 1
}

[ -z "${project}" ] && {
        echo "Please, specify project"
        exit 1
}

. ${BASEDIR}/conf/clusters/${cluster}/cluster.properties
. ${BASEDIR}/conf/clusters/${cluster}/user.properties

project=${PWD}/${project}
projectName=$(basename "${project}")
projectParent=$(dirname "${project}")
sshProjectParent=${workdir}/${sshProjectParent}
sshAppPath=${sshProjectParent}/${projectName}
#appPathParent=$(dirname "$appPath")
hdfsAppPath=$(cat ${project}/job.properties | grep "oozie.wf.application.path=" | awk -F"=" '{print $2}')

[ -z ${hdfsAppPath} ] && {
	hdfsAppPath=$(cat ${project}/job.properties | grep "oozie.coord.application.path=" | awk -F"=" '{print $2}')
}

cat ${project}/job.properties
echo sshAppPath = ${sshAppPath}
echo sshProjectParent = ${sshProjectParent}
echo tarball = ${tarball}
echo projectParent = ${projectParent}
echo hdfsAppPath = ${hdfsAppPath}

cd ${projectParent}

zip ${projectName}
tarball=${projectName}.zip

echo sshAppPath = ${sshAppPath}
echo sshProjectParent = ${sshProjectParent}
echo tarball = ${tarball}
echo appPathParent = ${appPathParent}
echo hdfsAppPath = ${hdfsAppPath}

exit 0;


sshpass -p "${password}" ssh ${username}@${server} "rm -r ${sshAppPath} || true ; mkdir -p ${sshAppPath}"
sshpass -p "${password}" scp "${tarball}" ${username}@${server}:${sshProjectParent}
#sshpass -p "${password}" ssh ${username}@${server} "tar -xjvf ${appPathParent}/${tarball} --directory ${appPath}"
sshpass -p "${password}" ssh ${username}@${server} "unzip ${sshProjectParent}/${tarball}"

sshpass -p "${password}" ssh ${username}@${server} 'bash -s' < bash ${BASEDIR}/remote_scripts/deploy_hdfs.sh   ${sshAppPath}/ \
                                                                        ${hdfsAppPath}

