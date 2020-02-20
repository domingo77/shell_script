#!/bin/bash

#$1 is username
#$2 is password
#$4 /home/$USERNAME

function time_elapsed(){
    difftemp=`expr "$2" - "$1"`
    ss=$(( $difftemp%60 ))
    mm=$(( ($difftemp-$ss)/60 ))
    echo "Total time taken = $mm:$ss(mm:ss)"
}
#####
#####hope: only one parameter:  website 
#####

function delete_download(){
    delete_path=$1
    ls -l $delete_path
    rm -rf $delete_path/*.img
    rm -rf $delete_path/gpt.bin
    rm -rf $delete_path/fastboot
    rm -rf $delete_path/*.txt
    rm -rf $delete_path/*.efi
    rm -rf $delete_path/*.log
}

function download_files(){
    #####
    #####2 download all image
    #####
    #$1: username
    #$2: password
    #$3: dailybuild_url
    #$4: directory which used to save downloaded files.
    #$5: tmp_time
    echo "\$#=$#"
    echo "\$@=$@"
    echo "\$*=$*"
    echo "\$?=$?"
    if [ $# -ne 5 ];then 
        echo "parameter number is not match. need $username $password $dailybuild_url $build_path $tmp_time"
        exit -1
    fi
    cd $4
    savedtxt=$4/$5_images_website.txt
    echo "savedtxt=$savedtxt" 
    curl -u "$1":"$2"  $3  > $savedtxt
    cat $savedtxt

    starttime=$(date +%s);
    #####2.1 download all suffix .img files
    all_images=`cat $savedtxt  | grep "img"  | awk -F "\"" '{print $2}'`
    echo -e "\nall_iamges: $all_images\n" 

    for image in `cat $savedtxt  | grep "img"  | awk -F "\"" '{print $2}'`
    do
        echo "downloading $image: $3$image"
        wget  -awget.log  --http-user="$1" --http-password="$2" $3$image
    done

    #####2.2 download fastboot
    fastboot=`cat $savedtxt  | grep "fastboot"  | awk -F "\"" '{print $2}'`
    echo -e "\nfastboot: $fastboot\n" 
    if [[ -z $fastboot ]]; then
        echo -e  "fastboot empty\n"
    else 
        fastboot_url=$3$fastboot
	echo -e "downloading fastboot: $fastboot_url\n"
        wget  -awget.log  --http-user="$1" --http-password="$2" $fastboot_url
        chmod 0777 fastboot
    fi

    #####2.3 download gpt.bin 
    gpt=`cat $savedtxt  | grep "gpt\.bin"  | awk -F "\"" '{print $2}'`
    echo -e "\ngpt: $gpt\n" 
    if [[ -z $gpt ]]; then
        echo -e  "gpt empty\n"
    else 
        gpt_url=$3$gpt
	echo -e "downloading gpt.bin: $gpt_url\n"
        wget  -awget.log  --http-user="$1" --http-password="$2" $gpt_url
    fi

    #####2.4 download AndroidBootApp.efi
    efi=`cat $savedtxt  | grep "AndroidBootApp.*efi"  | awk -F "\"" '{print $2}'`
    echo -e "\nefi: $efi\n" 
    if [[ -z $efi ]]; then
	echo -e  "AndroidBootApp.efi empty\n"
    else 
        efi_url=$3$efi
	echo -e "downloading AndroidBootApp.efi: $efi_url\n"
        wget  -awget.log  --http-user="$1" --http-password="$2" $efi_url
    fi

    iso=`cat $savedtxt  | grep "android_x86_raven.iso"  | awk -F "\"" '{print $2}'`
    echo -e "\niso: $efi\n" 
    if [[ -z $iso ]]; then
	echo -e  "android_x86_raven.iso empty\n"
    else 
        iso_url=$3$iso
	echo -e "downloading android_x86_raven.iso: $iso_url\n"
        wget  -awget.log  --http-user="$1" --http-password="$2" $iso_url
    fi
    endtime=$(date +%s);
    echo "##########################"
    time_elapsed $starttime $endtime
    echo "##########################"
    enddate=`date +%Y%m%d_%T`
    echo -e "wget_end $enddate\n\n" >> wget.log
#####
#####3 if img exist, now download it to specified directory.
#####
#if [[ -z $system ]] || [[ -z $boot ]] || [[ -z $cache ]] || [[ -z $userdata ]] || [[ -z $vendor ]];then

#	echo -e "\nThe number of img is not enough \n"

#else
#	echo -e "\n now download img ...\n"
        

#curl -u "$2":"$3" $system_url --output $system
#curl -u "$2":"$3" $boot_url --output $boot
#curl -u "$2":"$3" $boot_url --output $cache
#curl -u "$2":"$3" $boot_url --output $userdata
#enddate=`date +%Y%m%d_%T`
#echo -e "wget_end $enddate\n\n" >> wget.log
#fi

}


echo "\$#=$#"
echo "\$@=$@"
echo "\$*=$*"
echo "\$?=$?"
##### 
tmp_date=`date +%Y%m%d_%H_%M_%S_%p`
echo "$tmp_date"
dailybuild_home=`echo $HOME`
echo -e "dailybuild_home: $dailybuild_home"
sudo_path=`which sudo`
echo -e "sudo_path: $sudo_path"
myusername=mingdong
mypassword=welcome2Srdc


echo -e "\n>>>>>>>>> begin <<<<<<<<<<\n"



#1,parse the driectory 
release_verison_1=`echo "$1" | sed -e "s/\/$//g" | awk -F "/" '{print $(NF-1)}'`
release_verison_2=`echo "$1" | sed -e "s/\/$//g" | awk -F "/" '{print $(NF-2)}'`
release_build_path=
echo "release_build=$release_build"
echo "release_verison_1=$release_verison_1"
echo "release_verison_2=$release_verison_2"
if [[ -z $release_verison_1 ]] && [[ ! -z $release_verison_2 ]]; then
    if [[ ! -d $HOME/1-release/"$release_verison_2" ]]; then
        echo "create new $HOME/1-release/"$release_verison_2""
        mkdir -p $HOME/1-release/"$release_verison_2"
    fi
    release_build=`echo "$1" | sed -e "s/\/$//g" | awk -F "/" '{print $NF}'`
    echo "release_build=$release_build"
    if [[ ! -d $HOME/1-release/"$release_verison_2"/$release_build ]]; then
        echo "create new $HOME/1-release/"$release_verison_2"/$release_build"
        mkdir -p $HOME/1-release/"$release_verison_2/$release_build"
        release_build_path=$HOME/1-release/"$release_verison_2"/"$release_build"
    else
        SRDCQA_exist=`ls $HOME/1-release/"$release_verison_2"/"$release_build"* | grep "SRDCQA"`
        if [[ -z $SRDCQA_exist ]]; then
            mkdir -p $HOME/1-release/"$release_verison_2"/"$release_build"_SRDCQA_1
            release_build_path=$HOME/1-release/"$release_verison_2"/"$release_build"_SRDCQA_1
        else
            suffix_SRDCQA=`ls $HOME/1-release/"$release_verison_2"/"$release_build"* | grep "SRDCQA" | awk -F "SRDCQA_" '{print $2}' | awk -F ":" '{print $1}' | sort -n | tail -1`
            count=$(( $suffix_SRDCQA + 1 ))
            mkdir -p $HOME/1-release/"$release_verison_2"/"$release_build"_SRDCQA_$count
            release_build_path=$HOME/1-release/"$release_verison_2"/"$release_build"_SRDCQA_$count
        fi
    fi
    echo "release_build_path=$release_build_path"
    dailybuild_url=$1/
    curl -u "$myusername":"$mypassword" $1/  > $release_build_path/${tmp_date}_parse_website.txt
    download_files $myusername $mypassword $dailybuild_url $release_build_path ${tmp_date}
else 
    echo "ERROR:no release_version"
    exit -1
fi

echo -e "\n>>>>>>>>>> end <<<<<<<<<<\n"
