#!/bin/bash



function import_config_module(){
    echo -e "\n\n>>>>>import_config_module: Begin..."
    echo "$# parameter: $@"
    echo "$# parameter: $*"
    script=$1
        module_import=`grep -nr "from test_runner.configure import Configure as conf" $script`
        if [ -z $module_import ]; then
            echo ">>>>>Not from test_runner.configure import Configure as conf"
            sed -i "/#! \/usr\/bin\/python/a from test_runner.configure import Configure as adbsconf" $script
            grep -nr "from test_runner.configure import Configure as adbsconf" $script
            echo ">>>>>Add adb_s_ethernet_ip = adbsconf.property("ethernet_ip","")"
            sed -i "/class.*(object)/i\adb_s_ethernet_ip\ =\ adbsconf.property\(\"ethernet_ip\"\,\"\"\)" $script
            grep -nr "adb_s_ethernet_ip = adbsconf.property" $script
        else
            echo ">>>>>Add adb_s_ethernet_ip = conf.property("ethernet_ip","")"
            sed -i "/class.*(object)/i\adb_s_ethernet_ip\ =\ conf.property\(\"ethernet_ip\"\,\"\"\)" $script
            grep -nr "adb_s_ethernet_ip = conf.property" $script
        fi
 
    module_import=`grep -nr "from test_runner.configure import Configure as adbsconf" $script`
    get_ethernet_ip=`grep -nr "adb_s_ethernet_ip = adbsconf.property" $script`
    if [[ ! -z $module_import ]] && [[ ! -z $get_ethernet_ip ]]; then
        echo -e ">>>>>import_config_module: Success\n\n "
    else
        echo -e ">>>>>import_config_module: Failure\n\n "
    fi
   
}

function substitute_adb_to_adb_s(){
    echo -e "\n\n>>>>>substitute_adb_to_adb_serial: Begin..."
    echo "$# parameter: $@"
    echo "$# parameter: $*"
    script=$1

        sed -i "s/'adb shell/'adb -s ' + adb_s_ethernet_ip + ' shell/g" $script
        sed -i "s/' adb shell/'adb -s ' + adb_s_ethernet_ip + ' shell/g" $script
        sed -i "s/\"adb shell/\"adb -s \" + adb_s_ethernet_ip + \" shell/g" $script
        sed -i "s/\" adb shell/\"adb -s \" + adb_s_ethernet_ip + \" shell/g" $script

        sed -i "s/'adb reboot/'adb -s ' + adb_s_ethernet_ip + ' reboot/g" $script
        sed -i "s/\"adb reboot/\"adb -s \" + adb_s_ethernet_ip + \" reboot/g" $script

        sed -i "s/'adb install/'adb -s ' + adb_s_ethernet_ip + ' install/g" $script
        sed -i "s/\"adb install/\"adb -s \" + adb_s_ethernet_ip + \" install/g" $script

        sed -i "s/'adb uninstall/'adb -s ' + adb_s_ethernet_ip + ' uninstall/g" $script
        sed -i "s/\"adb uninstall/\"adb -s \" + adb_s_ethernet_ip + \" uninstall/g" $script

        sed -i "s/'adb get-state/'adb -s ' + adb_s_ethernet_ip + ' get-state/g" $script
        sed -i "s/\"adb get-state/\"adb -s \" + adb_s_ethernet_ip + \" get-state/g" $script

        sed -i "s/'adb push/'adb -s ' + adb_s_ethernet_ip + ' push/g" $script
        sed -i "s/' adb push/'adb -s ' + adb_s_ethernet_ip + ' push/g" $script
        sed -i "s/\"adb push/\"adb -s \" + adb_s_ethernet_ip + \" push/g" $script
        sed -i "s/\" adb push/\"adb -s \" + adb_s_ethernet_ip + \" push/g" $script

        sed -i "s/'adb pull/'adb -s ' + adb_s_ethernet_ip + ' pull/g" $script
        sed -i "s/\"adb pull/\"adb -s \" + adb_s_ethernet_ip + \" pull/g" $script

        sed -i "s/'adb bugreport/'adb -s ' + adb_s_ethernet_ip + ' bugreport/g" $script
        sed -i "s/\"adb bugreport/\"adb -s \" + adb_s_ethernet_ip + \" bugreport/g" $script

        sed -i "s/'adb root/'adb -s ' + adb_s_ethernet_ip + ' root/g" $script
        sed -i "s/\"adb root/\"adb -s \" + adb_s_ethernet_ip + \" root/g" $script
        
        echo "check whether adb command exist after substitute"
        adb_command=`grep -nr "[\"'][ ]*adb shell\|[\"'][ ]*adb reboot\|[\"'][ ]*adb install\|[\"'][ ]*adb uninstall\|[\"'][ ]*adb get-state\|[\"'][ ]*adb push\|[\"'][ ]*adb pull\|[\"'][ ]*adb bugreport\|[\"'][ ]*adb root" $script`

    if [ -z $adb_command ]; then
        echo -e ">>>>>import_config_module: Success\n\n "
    else
        echo -e ">>>>>import_config_module: Failure\n\n "

    fi


}

function substitute_all(){
    echo -e "\n\n>>>>>substitute_all: Begin..."
    echo "$# parameter: $@"
    echo "$# parameter: $*"
    #replace $1/*.py
    cd "$1"

    for script in `ls *.py`
    do
        echo "script: $script"
        adb_command=`grep -nr "[\"'][ ]*adb shell\|[\"'][ ]*adb reboot\|[\"'][ ]*adb install\|[\"'][ ]*adb uninstall\|[\"'][ ]*adb get-state\|[\"'][ ]*adb push\|[\"'][ ]*adb pull\|[\"'][ ]*adb bugreport\|[\"'][ ]*adb root" $script`
        if [[ ! -z $adb_command ]]; then
            echo ">>>>>contain adb command"
            #check whether from test_runner.configure import Configure as conf
            import_config_module $script

            substitute_adb_to_adb_s $script 
            echo "check whether adb command exist after substitute"
            grep -nr "[\"'][ ]*adb shell\|[\"'][ ]*adb reboot\|[\"'][ ]*adb install\|[\"'][ ]*adb uninstall\|[\"'][ ]*adb get-state\|[\"'][ ]*adb push\|[\"'][ ]*adb pull\|[\"'][ ]*adb bugreport\|[\"'][ ]*adb root" $script
            grep -nr "adb shell\|adb reboot\|adb install\|adb uninstall\|adb get-state\|adb push\|adb pull\|adb bugreport\|adb root" $script

        fi
    done

}

function check_substitute(){
    echo -e "\n\n>>>>check_substitute: Begin..."
    echo "$# parameter: $@"
    echo "$# parameter: $*"

grep -nr "[\"'][ ]*adb shell\|[\"'][ ]*adb reboot\|[\"'][ ]*adb install\|[\"'][ ]*adb uninstall\|[\"'][ ]*adb get-state\|[\"'][ ]*adb push\|[\"'][ ]*adb pull\|[\"'][ ]*adb bugreport\|[\"'][ ]*adb root" $script
#grep -nr "adb shell\|adb reboot\|adb install\|adb uninstall\|adb get-state\|adb push\|adb pull\|adb bugreport\|adb root" $1



}










#----------------------------body------------------------------
echo "$# parameter: $@"
echo "$# parameter: $*"

test_framework_path=$1
#replace $1/core/*.py
substitute_all "$test_framework_path/core"


#replace $1/tests/*.py
substitute_all "$test_framework_path/tests"

            
#check substitute result
check_substitute "$test_framework_path/core"
check_substitute "$test_framework_path/tests"
