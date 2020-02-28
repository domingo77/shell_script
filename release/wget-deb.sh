#!/bin/bash

function wget_aosp_image(){
   echo "number: $#"
   echo "parameter(s): $* "
   echo "parameter(s): $@ "

   name=$1
   passwd=$2
   url=$3
   img_name=$4
   img_exist=`curl -u  $name:$passwd  $url | grep -i "$img_name"`

   if [[ ! -z $img_exist ]]; then
    echo "download $img_name >>>>> begin"
    wget --http-user="$name" --http-password="$passwd" $url/"$img_name"
    echo "download $img_name <<<<< end"
else
    echo "no $img_name ,so exit "
    exit -1
fi


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

echo "$tmp_date"

build_path=$1
build_url=$2
username=
password=


echo -e "\n>>>>>>>>> begin <<<<<<<<<<\n"
if [[ ! -d $build_path ]]; then
    mkdir -p $build_path
    chmod -R 0777 $build_path
fi
cd $build_path
#system.img
wget_aosp_image $username $password $build_url "kernel.deb"

chmod 0777 *
echo -e "\n>>>>>>>>>> end <<<<<<<<<<\n"
