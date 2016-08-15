#!/bin/bash
set -e

BASEDIR=$(dirname $0)
CONFDIR=${DEPLOYER_CONF_DIR}

confirmDialog=true
deployToHdfs=true
runOozie=true

parseInputArguments(){
    previousArg=''
    for var in "$@"
    do
	    if [ "$previousArg" = '--cluster' ]; then
		    cluster="$var"
	    elif [ "$previousArg" = '--sshProjectParent' ]; then
		    sshProjectParent="$var"
	    elif [ "$previousArg" = '--project' ]; then
		    project="$var"
		elif [ "$previousArg" = '--confirm' ]; then
		    confirmDialog="$var"
		elif [ "$previousArg" = '--deployToHdfs' ]; then
		    deployToHdfs="$var"
		elif [ "$previousArg" = '--runOozie' ]; then
		    runOozie="$var"
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
    return 0;
}

initConfigs(){
    . ${CONFDIR}/clusters/${cluster}/cluster.properties
    . ${CONFDIR}/clusters/${cluster}/user.properties

    project=${PWD}/${project}
    projectName=$(basename "${project}")
    projectParent=$(dirname "${project}")
    sshProjectParent=${workdir}/${sshProjectParent}
    sshAppPath=${sshProjectParent}/${projectName}

    hdfsAppPath=$(cat ${project}/job.properties | grep "oozie.wf.application.path=" | awk -F"=" '{print $2}')
    [ -z ${hdfsAppPath} ] && {
    	hdfsAppPath=$(cat ${project}/job.properties | grep "oozie.coord.application.path=" | awk -F"=" '{print $2}')
    }
}

printConfirmDialog(){
    echo ----------------------------------------------------------------
    echo ---------------------DEPLOYING ${projectName}-------------------
    echo ----------------------------------------------------------------
    echo Remote server host = ${server}
    echo Ssh username  = ${username}
    echo Destination path on remote server = ${sshAppPath}
    echo Destination path on  hdfs         = ${hdfsAppPath}

    [ ${confirmDialog} = true ] && {
        read -p "Are you sure? " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]
        then
           exit 1
        fi
    }
    return 0;
}

parseInputArguments "$@"
initConfigs

cd ${projectParent}

zip -r ${projectName} ${projectName}
tarball=${projectName}.zip

printConfirmDialog

echo Deploying ${tarball} on ssh host ...
sshpass -p "${password}" ssh ${username}@${server} "rm -r ${sshAppPath} || true"
sshpass -p "${password}" scp "${tarball}" ${username}@${server}:${sshProjectParent}

echo Extracting ${tarball} archive ...
sshpass -p "${password}" ssh ${username}@${server} "cd ${sshProjectParent}; unzip ${tarball}"

[ $deployToHdfs = true ] && {
    echo Deploying ${sshAppPath} to HDFS ${hdfsAppPath} ...
    sshpass -p "${password}" ssh ${username}@${server} 'bash -s' < ${BASEDIR}/remote_scripts/deploy_hdfs.sh   ${sshAppPath}/ \
                                                                        ${hdfsAppPath}

    [ $runOozie = true ] && {
        echo Starting Oozie ...
        sshpass -p "${password}" ssh ${username}@${server} 'bash -s' < ${BASEDIR}/remote_scripts/run_oozie.sh   ${sshAppPath}/job.properties \
                                                                        ${oozieServer}
    }
}




