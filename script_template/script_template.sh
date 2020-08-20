#!/bin/bash
set -o pipefail

debug_msg(){
    if [[ $debug_mode = true ]]; then
        echo -e "$@"
        #for parameter in "$@"
        #do
        #    echo "$parameter"
        #done
    fi
}

debug_function_begin='eval debug_msg "#####\n#Function: ${FUNCNAME[0]} BEGIN\n#####"'
debug_function_end='eval debug_msg "#####\n#Function: ${FUNCNAME[0]} END\n#####\n\n"'

step(){
    local step_num=$1
    local msg="$2"
    echo -e "\n\n##############################"
    echo "# step $1, $msg "
    echo -e "##############################\n"
}

exitMsg(){
  local msg="$1"
  echo "Fatal Error: $msg"
  exit -1

}

clean_build(){
    ${debug_function_begin}
    if [[ -d build ]] && [[ -n $NEED_CLEAN ]]; then
        sudo rm -rf build
        echo "$(ls -tlh build)"
    fi
    ${debug_function_end}
}

# enter and exit must be together
enter_directory(){
    ${debug_function_begin}
    local dir=$1
    if [[ -d $dir ]]; then
        pushd $dir
        pwd
    else
        mkdir -p $dir
        pushd $dir
        pwd
    fi
    ${debug_function_end}
}
exit_directory(){
    popd
    pwd
}

check_mandatory_params(){
}
check_build_type(){
}
check_shared_lib(){
    ldd $1
}
pre_check(){
    ${debug_function_begin}
    check_mandatory_params
    check_build_type
    ${debug_function_end}
}

pre_install(){
    ${debug_function_begin}
    ${debug_function_end}
}




#################################################################################
# main
#################################################################################

######################
# mandatory parameters
######################
BUILD_HOME_DIR=$PWD
BUILD_PROJECT=

######################
# optional parameters
######################
BUILD_TYPE=
BUILD_NUMBER=

######################
# internal parameters
######################
ERROR_STATUS_CODE=1
build_exit_status=0
DEFAULT_GIT_REPOSITORY_URL=https://gerrit.google.cn

declare -a BRANCH_OR_TAG_LIST=(
    [0]="1"
    [1]="2"
)
for branch_index in ${!BRANCH_OR_TAG_LIST[@]}; do
    echo "        $0 ${BRANCH_OR_TAG_LIST[$branch_index]}"
done

declare -A PROJECT_LIST=(
    ["hello"]="HELLO"
)
for project in ${!PROJECT_LIST[@]}; do
    echo "project($project): ${PROJECT_LIST[$project]}"
done

count=0
let count+=1
usage(){
    echo "Usage: $0 -p <hello>"
    echo "options:"
    echo "        p - mandatory: project"
    echo "        y - optional:  xxx"
    echo "example:"

    for branch_index in ${!BRANCH_OR_TAG_LIST[@]}; do
    echo "        $0 -p ${BRANCH_OR_TAG_LIST[$branch_index]}"
    done
}

while getopts ":p:" opt
do
    case "$opt" in
        p|)
            COLLECT_COMPILE_LOG=true
            echo "COLLECT_COMPILE_LOG=$COLLECT_COMPILE_LOG"
            ;;
        ?)
            echo "invalid option: ${OPTARG}"
            usage
            exit -1
            ;;
    esac
done
shift $(($OPTIND-1))
echo -e "#####\n#remaining parameters: [$@]\n#####\n"



step $count "do what"
echo "BUILD_HOME_DIR=$BUILD_HOME_DIR"


case "$BUILD_PROJECT" in
    xxxx)
        build_xxx
        ;;
    *)
        echo "$BUILD_PROJECT not found, please check"
        exit -1
        ;;
esac
