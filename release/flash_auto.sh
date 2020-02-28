#!/bin/bash


function check_connect_with_adb(){
    echo "number: $#"
    echo "parameters: $*"
    echo "parameters: $@"
    ip=$1
    minutes=$2
    a=0
    total_time=$[$minutes*60/5]
    echo  "times: $total_time"
    count_time=0
    while [ $a -lt 30 -a $count_time -lt $total_time ]
    do
          connected=`adb -s $ip connect $1 | grep connected`
	  if [[ ! -z $connected ]]; then
              adb devices
	      adb -s $ip shell ls storage
              echo "adb connected $ip"
	      sleep 1
	      let a=30
          else
              sleep 4
	      echo "adb connect $ip, failure"
          fi


    done


}



function time_elapsed(){
    #####$1: $starttime
    #####$2: $endtime
    difftemp=`expr "$2" - "$1"`
    ss=$(( $difftemp%60 ))
    mm=$(( ($difftemp-$ss)/60 ))
    echo "Total time taken = $mm:$ss(mm:ss)"
}


function one_time_elapsed(){
    #####$1: $starttime
    #####$2: $endtime
    difftemp=`expr "$2" - "$1"`
    ss=$(( $difftemp%60 ))
    mm=$(( ($difftemp-$ss)/60 ))
    echo "Loop $3 time taken = $mm:$ss(mm:ss)"
}

function check_adb_connect(){
    #$1 minutes
    #$2 target_ip
    wait_time=$1
    target_ip=$2
    total_times=$[$[60*$1]/5]
    a=0
    count=0
    starttime=$(date +%s)
    echo "Try connect $total_times times, about $wait_time minute(s)"
    while [ $a -lt 30 -a $count -lt $total_times ]
    do
        ExistValue=`adb devices | grep "$target_ip"`
	echo "[$ExistValue]"
	if [ -n "$ExistValue" ]; then
            adb -s $target_ip shell ls storage
	    sleep 1
	    echo "connected"
	    a=30
	else
	    adb connect $target_ip
	    echo "Tried connecting"
	    adb -s $target_ip shell ls storage
	    sleep 1
	fi
	sleep 4
	let count+=1
	echo     "################"
	echo     "#####count:$count"
	echo -e  "################\n"
    done
    endtime=$(date +%s)
    echo "check adb connect:"
    time_elapsed $starttime $endtime

}



function check_enter_fastboot_mode(){
    #####$1: ip address
    #####$2: value of ping parameter -c 
    echo -e "##############################"
    echo -e "##### check_enter_fastboot_mode $1(IP) $2(ping count) $3(loop minutes)"
    echo -e "###############################"
    #check_fastmode $IP_ADDRESS $fastboot_bin
    starttime=$(date +%s);
    let a=0
    let count=1
    total_time=$[60*$3/$2]
    echo "total time: $total_time"
    total_starttime=$(date +%s);
    while [ $a == 0 -a $count -lt $total_time ]
    do
        starttime=$(date +%s)
	ping_reachable=`ping -i 1 -c $2 $1 | grep "ttl=.* time=.* ms" `
	endtime=$(date +%s)
	one_time_elapsed $starttime $endtime $count

	if [[ ! -z $ping_reachable ]]; then
	    echo "ping $1, reachable"
	    adb_connect_refused=`adb connect $1 | grep "unable to connect to $1:[0-9]*: Connection refused"`
	    echo "adb_connect_refused=$adb_connect_refused"
	    adb_connected=`adb connect $1 | grep "connected to $1:[0-9]*"`
	    echo "adb_connected=$adb_connected"
	    if [[ ! -z $adb_connect_refused ]]; then
                echo -e "adb connect $1: unable to connect, so now enter fastboot mode\n\n"
		let a=30
		fastboot_mode=true
		break
            else
                if [[ ! -z $adb_connected ]]; then
                    echo -e "adb connect $1: connected, exit -1\n\n"
		    exit -1
		fi
	    fi
	else
            echo -e "ping $1: not reachable. loop $count ... end\n\n"
	    let count+=1
        fi
    done
    total_endtime=$(date +%s);
    if [[ $count == $total_time ]]; then
        fastboot_mode=false
    fi

    echo "fastboot_mode=$fastboot_mode"
    echo "check enter fastboot mode: $fastboot_mode"

    echo -e "##############################"
    time_elapsed $total_starttime $total_endtime
}


echo "\$#=$#"
echo "\$@=$@"
echo "\$*=$*"
echo "\$?=$?"

tmp_date=`date +%Y%m%d_%H_%M_%S_%p`
#LOCAL_PATH=`pwd`
LOCAL_PATH=$2

FASTBOOT_PWD=$LOCAL_PATH/fastboot
FASTBOOT_HOME_BIN=$HOME/bin/fastboot
#LOCAL_PATH=/home/mingdong/dailybuild
echo "$tmp_date"

if [[ ! -z $3 ]] && [[ $3 == android ]]; then 
check_connect_with_adb $1 3
adb -s $1 reboot bootloader
#check enter fastboot mode.
ping_count=5
loop_minutes=2
check_enter_fastboot_mode $1 $ping_count $loop_minutes
fi

echo -e "\n>>>>>>>>> begin <<<<<<<<<<\n"
env | grep -i ptah 
#export PATH=$HOME/bin:$PATH
#env | grep -i path
echo -e "\npwd\n"
pwd

if [[ ! -f $FASTBOOT_PWD ]]; then
    ls -lh $LOCAL_PATH
    echo -e "empty\n"
    if [[ ! -f $FASTBOOT_HOME_BIN ]]; then 
        echo -e "\n FASTBOOT_HOME_BIN empty\n"
    else 
        echo -e "\n FASTBOOT_HOME_BIN not empty\n"
        
        $FASTBOOT_HOME_BIN -s tcp:$1 flash gpt $LOCAL_PATH/gpt.bin
        $FASTBOOT_HOME_BIN -s tcp:$1 reboot bootloader
        ping_count=5
	loop_minutes=2
	check_enter_fastboot_mode $1 $ping_count $loop_minutes
        $FASTBOOT_HOME_BIN -s tcp:$1 flash system $LOCAL_PATH/system.img
        $FASTBOOT_HOME_BIN -s tcp:$1 erase vendor 
        $FASTBOOT_HOME_BIN -s tcp:$1 flash vendor $LOCAL_PATH/vendor.img
        $FASTBOOT_HOME_BIN -s tcp:$1 flash boot $LOCAL_PATH/boot.img
        $FASTBOOT_HOME_BIN -s tcp:$1 flash cache $LOCAL_PATH/cache.img
        $FASTBOOT_HOME_BIN -s tcp:$1 flash data $LOCAL_PATH/userdata.img
        $FASTBOOT_HOME_BIN -s tcp:$1 reboot

    fi
else
    echo -e "\n$FASTBOOT_PWD not empty\n"
    chmod 0755 $FASTBOOT_PWD
    ls -lh $LOCAL_PATH
    $FASTBOOT_PWD -s tcp:$1 flash gpt $LOCAL_PATH/gpt.bin
    $FASTBOOT_PWD -s tcp:$1 reboot bootloader
    ping_count=5
    loop_minutes=2
    check_enter_fastboot_mode $1 $ping_count $loop_minutes
    $FASTBOOT_PWD -s tcp:$1 flash misc $LOCAL_PATH/misc.img
    $FASTBOOT_PWD -s tcp:$1 flash boot_a $LOCAL_PATH/boot.img
    $FASTBOOT_PWD -s tcp:$1 flash vbmeta_a $LOCAL_PATH/vbmeta.img
    $FASTBOOT_PWD -s tcp:$1 flash vendor_a $LOCAL_PATH/vendor.img
    $FASTBOOT_PWD -s tcp:$1 flash system_a $LOCAL_PATH/system.img
    #$FASTBOOT_PWD -s tcp:$1 flash boot_b $LOCAL_PATH/boot.img
    #$FASTBOOT_PWD -s tcp:$1 flash vbmeta_b $LOCAL_PATH/vbmeta.img
    #$FASTBOOT_PWD -s tcp:$1 flash vendor_b $LOCAL_PATH/vendor.img
    #$FASTBOOT_PWD -s tcp:$1 flash system_b $LOCAL_PATH/system.img
    $FASTBOOT_PWD -s tcp:$1 flash data $LOCAL_PATH/userdata.img
    $FASTBOOT_PWD -s tcp:$1 reboot
fi

#vncserver :1
#export DISPLAY=:1
#env | grep -i display
#xhost +
#/usr/bin/sudo gnome-terminal -x ~/connect.sh $1
#sleep 120
echo "adb connect and let os stay awake, not screen off"
check_connect_with_adb $1 3
adb devices
adb -s $1  shell settings get global stay_on_while_plugged_in
adb -s $1 shell settings put global stay_on_while_plugged_in 7
adb -s $1 shell settings get global stay_on_while_plugged_in



echo -e "\n>>>>>>>>>> end <<<<<<<<<<\n"




