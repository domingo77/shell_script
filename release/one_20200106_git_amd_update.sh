#!/bin/bash

function print_help(){
    echo "Help"
    echo -e "Mandotory paramter:"
    echo -e "-a|--username USERNAME\t\t\t\tdailybuilt website authentication username"
    echo -e "-b|--password PASSWORD\t\t\t\tdailybuilt website authentication password"
    echo -e "-c|--http_url HTTP URL\t\t\t\tdailybuilt website http url"
    echo -e "-d|--key_search KEY SEARCH\t\t\tkey search for dailybuild"
    echo -e "-e|--ipaddress IPADDRESS\t\t\tip address of target device"
    echo -e "-f|--android_version VERSION\t\t\tAndroid version, P/p/Pie/pie/N/n/Nougat/nougat"
    echo -e "-g|--enable_slot_ab FEATURE A/B PARTITION\tEnable/disable A/B partition on Android P(true/false) or none on Android N"
    echo -e "-i|--slot_ab A/B PARTITION\t\t\tChoose A/B partition for flashing:a/b/all/none"
    echo -e "-j|--test_framework TEST FRAMEWORK PATH\t\ttest framework absolute path"
    echo -e "-k|--automation_type AUTOMATION TEST\t\tautomation test type: smoke/sanity/regression"
    echo -e "-l|--final_template\t\t\t\tfinal email template"
    echo -e "-m|--inject_env INJECT ENV TEXT\t\t\tinject env txt"
    echo -e "-n|--final_subject FINAL SUBJECT\t\tfinal email subject"
    echo -e "-o|--detail_info DETAIL INFO\t\tdetail info, such as: AOSP URL/BIOS/Flash duration"
    echo -e "-p|--xml_path XML PATH\t\tspecify the path to JUnit XML files and  Archived files"
    echo -e "-q|--exception_reason FAILURE REASON\t\tfailure reason, appear behind build status if exception "
    echo -e "-r|--git_branch GIT BRANCH\t\tgit branch for email subject"
    echo -e "\n"
    echo -e "optional parameter:"
    echo -e "-h|--help\t\t\t\t\tHelp"
    echo -e "-v|--sleep_time SLEEP_time\t\t\twhat hour(s) need to sleep"
    echo -e "-w|--sleep_control SLEEP_CONTROL\t\t\twhether need to sleep sleep_time hour(s)"
    echo -e "-x|--flash_script FLASH SCRIPT\t\t\tflash script for flashing"
    echo -e "-y|--real_download REALLY DOWNLOAD\t\tWhether really download AOSP images"
    echo -e "-z|--real_flash REALLY FLASH\t\t\tWhether really flash AOSP images"
    echo -e "\n"
    echo -e "For example:\n
             \$SHELL_SCRIPT                                            \\
                             --username         \$DAILYBUILT_USERNAME  \\
                             --password         \$DAILYBUILT_PASSWORD  \\
                             --http_url         \$DAILYBUILT_WEBSITE   \\
                             --key_search       \$KEY_SEARCH           \\
                             --ipaddress        \$TARGET_IP            \\
                             --android_version  \$ANDROID_VERSION      \\
                             --enable_slot_ab   \$ENABLE_SLOT_AB       \\
                             --slot_ab          \$SLOT_AB              \\
                             --test_framework   \$TEST_FRAMEWORK       \\
                             --automation_type  \$AUTOMATION_TEST_TYPE \\
                             --final_template   \$FINAL_TEMPLATE       \\
                             --inject_env       \$INJECT_ENV_TXT       \\
                             --final_subject    \$FINAL_SUBJECT        \\
                             --xml_path         \$XML_PATH             \\
                             --exception_reason \$EXCEPTION_REASON      "
    exit 0
}
function time_elapsed(){
    #####$1: $starttime
    #####$2: $endtime
    difftemp=`expr "$2" - "$1"`
    ss=$(( $difftemp%60 ))
    mm=$(( ($difftemp-$ss)/60 ))
    echo "Total time taken = $mm:$ss(mm:ss)"
}

function enter_directory(){
    #####$1 enter_directory
    echo -e "##############################"
    echo -e "##### enter_directory "
    echo -e "###############################"
    starttime=$(date +%s);
    pwd
    if [[ "$1" != "`pwd`" ]]; then
       cd "$1"
    fi
    pwd
    endtime=$(date +%s);
    echo -e "##############################"
    time_elapsed $starttime $endtime
    echo -e "###############################\n\n"
}

function flash_time_elapsed(){
    #####$1: $starttime
    #####$2: $endtime
    #####$3: $file_name
    pwd
    if [[ "$WORKSPACE" != "`pwd`" ]]; then
       cd "$WORKSPACE"
    fi
    pwd
    difftemp=`expr "$2" - "$1"`
    ss=$(( $difftemp%60 ))
    mm=$(( ($difftemp-$ss)/60%60 ))
    hh=$(( ($difftemp-$ss-$mm*60)/3600 ))
    echo "Total time taken = $hh:$mm:$ss(hh:mm:ss)"
    if [ $hh -gt 0 ]; then
        echo "$hh hr $mm min $ss sec" >> $3.txt
    elif [ $mm -gt 0 ]; then
        echo "$mm min $ss sec" >> $3.txt
    elif [ $ss -gt 0 ]; then
        echo "$ss sec" >> $3.txt
    fi
}

function delete_last_build_artifacts(){
    #####$1: ${WORKSPACE}
    #####$2: $xml_path
    echo -e "##############################"
    echo -e "##### delete_last_build_artifacts "
    echo -e "###############################"
    starttime=$(date +%s);
    enter_directory "$1"
    rm -rf "$1/$2"
    rm -rf "$1/${2}_adb_logs"
    rm -rf "$1/${2}_logs"
    rm -rf "$1/smoke_logs"
    rm -rf "$1/smoke_adb_logs"
    ls  "$1/$2"
    ls  "$1/${2}_adb_logs"
    ls  "$1/${2}_logs"
    endtime=$(date +%s);
    echo -e "##############################"
    time_elapsed $starttime $endtime
    echo -e "###############################\n\n"

}

function restore_origin(){
    #####$1: ${WORKSPACE}
    echo -e "##############################"
    echo -e "##### delete ${WORKSPACE}/* "
    echo -e "###############################"
    pwd
    if [[ "$WORKSPACE" != "`pwd`" ]]; then
       cd "$WORKSPACE"
    fi
    pwd
    starttime=$(date +%s);
    delete_path=$1
    ls -l "$delete_path"
    rm -rf "$delete_path"/*.img
    rm -rf "$delete_path"/gpt.bin
    rm -rf "$delete_path"/fastboot
    rm -rf "$delete_path"/*.txt
    rm -rf "$delete_path"/*.efi
    rm -rf "$delete_path"/*.log
    rm -rf "$delete_path"/*.template
    rm -rf "$delete_path"/*.bak
    rm -rf "$delete_path"/*.html
    rm -rf *.txt
    rm -rf *.template
    rm -rf *.html
    rm -rf *.date
    ls -l
    ls -l "$delete_path"
    endtime=$(date +%s);
    echo -e "##############################"
    time_elapsed $starttime $endtime
    echo -e "###############################\n\n"
}

function download_files(){
    #####
    #####2 download all image
    #####
    #$1: username
    #$2: password
    #$3: dailybuild_url
    #$4: tmp_time
    echo -e "##############################"
    echo -e "##### download all images to ${WORKSPACE}/ "
    echo -e "###############################"
    pwd
    if [[ "$WORKSPACE" != "`pwd`" ]]; then
       cd "$WORKSPACE"
    fi
    pwd
    echo "\$@=$@"
    if [ $# -ne 4 ];then
        echo "parameter number is not match. need $username $password $dailybuild_url $build_path $tmp_time"
        exit -1
    fi
    savedtxt=$4_images_website.txt
    echo "savedtxt=$savedtxt"
    curl -u "$1":"$2"  $3  > $savedtxt
    #cat $savedtxt

    starttime=$(date +%s);
    #####2.1 download all suffix .img files
    all_images=`cat $savedtxt  | grep "img"  | awk -F "\"" '{print $2}'`
    echo -e "all_iamges: $all_images"

    for image in `cat $savedtxt  | grep "img"  | awk -F "\"" '{print $2}'`
    do
        echo "downloading $image: $3$image"
        wget  -awget.log  --http-user="$1" --http-password="$2" $3$image
    done

    #####2.2 download fastboot
    fastboot=`cat $savedtxt  | grep "fastboot"  | awk -F "\"" '{print $2}'`
    echo -e "fastboot: $fastboot"
    if [[ -z $fastboot ]]; then
        echo -e  "fastboot empty"
    else
        fastboot_url=$3$fastboot
	echo -e "downloading fastboot: $fastboot_url"
        wget  -awget.log  --http-user="$1" --http-password="$2" $fastboot_url
        chmod 0777 fastboot
    fi

    #####2.3 download gpt.bin
    gpt=`cat $savedtxt  | grep "gpt\.bin"  | awk -F "\"" '{print $2}'`
    echo -e "gpt: $gpt"
    if [[ -z $gpt ]]; then
        echo -e  "gpt empty"
    else
        gpt_url=$3$gpt
	echo -e "downloading gpt.bin: $gpt_url"
        wget  -awget.log  --http-user="$1" --http-password="$2" $gpt_url
    fi

    #####2.4 download AndroidBootApp.efi
    efi=`cat $savedtxt  | grep "AndroidBootApp.*efi"  | awk -F "\"" '{print $2}'`
    echo -e "efi: $efi"
    if [[ -z $efi ]]; then
	echo -e  "AndroidBootApp.efi empty"
    else
        efi_url=$3$efi
	echo -e "downloading AndroidBootApp.efi: $efi_url"
        wget  -awget.log  --http-user="$1" --http-password="$2" $efi_url
    fi

    enddate=`date +%Y%m%d_%T`
    endtime=$(date +%s);
    echo -e "wget_end $enddate\n\n" >> wget.log
    echo -e "##############################"
    time_elapsed $starttime $endtime
    flash_time_elapsed $starttime $endtime  "download_duration"
    echo -e "##############################\n\n"
    pwd
    if [[ "$WORKSPACE" != "`pwd`" ]]; then
       cd "$WORKSPACE"
    fi
    pwd

}

function check_dailybuild_is_new(){
    #####$1: ${tmp_date}_parse_website.txt
    #####$2: $image_website
    #####$3: $bootimgornot
    #####$4: $keyForGrep
    echo -e "##############################"
    echo -e "##### check_dailybuild_is_new "
    echo -e "###############################"
    pwd
    echo -e "$@"
    if [[ "$WORKSPACE" != "`pwd`" ]]; then
       cd "$WORKSPACE"
    fi
    pwd
    starttime=$(date +%s);
    if [[ $3 == false ]]; then
        current_max_dailybuild_suffix=`cat "$1"  | grep -i "$4" | awk -F "\"" '{print $2 }' | awk -F "-" '{print $NF }' | sort -n | tail -1`
        echo -e "current_max_dailybuild_suffix=$current_max_dailybuild_suffix"
        max_dailybuild_index_date=`grep -nr "$4".*"$current_max_dailybuild_suffix" "$1"  | awk -F " " '{print $3}'`
        echo "max_dailybuild_index_date=$max_dailybuild_index_date"
        #max_dailybuild_index_date="14-Nov-2019"
        echo "max_dailybuild_index_date=$max_dailybuild_index_date"
        echo "expected_dailybuild_date=$expected_dailybuild_date"

        if [[ $max_dailybuild_index_date == $expected_dailybuild_date ]]; then 
            echo "new dailybuild exists."
            is_new_dailybuild=true
        else  
            echo "new dailybuild not exists."
            is_new_dailybuild=false

            DAILYBUILT_DATE=`echo "$expected_dailybuild_date" | awk -F "-" '{print $3$2$1}'`
            #DAILYBUILT_NUMBER=no_build_image
            if [[ $4 == sanity ]] || [[ $4 == smoke ]]; then
                echo "AOSP-${git_branch}-Smoke-Test_${DAILYBUILT_DATE}_dailybuilt#${DAILYBUILT_NUMBER}_result" >  "$final_subject"
            elif [[ $4 == regression ]]; then
                echo "AOSP-${git_branch}-Regression-Test_${DAILYBUILT_DATE}_dailybuilt#${DAILYBUILT_NUMBER}_result" >  "$final_subject"
            else
                echo "AOSP-${git_branch}-Test_${DAILYBUILT_DATE}_dailybuilt#${DAILYBUILT_NUMBER}_result" >  "$final_subject"
            fi
            cat  "$final_subject"

            if [[ $DAILYBUILT_DATE == *Jan* ]]; then
                sed -e "s/Jan/01/g" -i  $2
                sed -e "s/Jan/01/g" -i  "$final_subject"
            elif [[ $DAILYBUILT_DATE == *Feb* ]]; then
                sed -e "s/Feb/02/g" -i  $2
                sed -e "s/Feb/02/g" -i  "$final_subject"
            elif [[ $DAILYBUILT_DATE == *Mar* ]]; then
                sed -e "s/Mar/03/g" -i  $2
                sed -e "s/Mar/03/g" -i  "$final_subject"
            elif [[ $DAILYBUILT_DATE == *Apr* ]]; then
                sed -e "s/Apr/04/g" -i  $2
                sed -e "s/Apr/04/g" -i  "$final_subject"
            elif [[ $DAILYBUILT_DATE == *May* ]]; then
                sed -e "s/May/05/g" -i  $2
                sed -e "s/May/05/g" -i  "$final_subject"
            elif [[ $DAILYBUILT_DATE == *Jun* ]]; then
                sed -e "s/Jun/06/g" -i  $2
                sed -e "s/Jun/06/g" -i  "$final_subject"
            elif [[ $DAILYBUILT_DATE == *Jul* ]]; then
                sed -e "s/Jul/07/g" -i  $2
                sed -e "s/Jul/07/g" -i  "$final_subject"
            elif [[ $DAILYBUILT_DATE == *Aug* ]]; then
                sed -e "s/Aug/08/g" -i  $2
                sed -e "s/Aug/08/g" -i  "$final_subject"
            elif [[ $DAILYBUILT_DATE == *Sep* ]]; then
                sed -e "s/Sep/09/g" -i  $2
                sed -e "s/Sep/09/g" -i  "$final_subject"
            elif [[ $DAILYBUILT_DATE == *Oct* ]]; then
                sed -e "s/Oct/10/g" -i  $2
                sed -e "s/Oct/10/g" -i  "$final_subject"
            elif [[ $DAILYBUILT_DATE == *Nov* ]]; then
                sed -e "s/Nov/11/g" -i  $2
                sed -e "s/Nov/11/g" -i  "$final_subject"
            elif [[ $DAILYBUILT_DATE == *Dec* ]]; then
                sed -e "s/Dec/12/g" -i  $2
                sed -e "s/Dec/12/g" -i  "$final_subject"
            fi

            cat  "$final_subject"
            #dailybuild_suffix=80/

            dailybuild_url=$2
            echo "dailybuild_url=$dailybuild_url"
            echo "$dailybuild_url" > dailybuild_url.txt
            cat dailybuild_url.txt
            sed -e "s#\/#\\\/#g" -i dailybuild_url.txt
            cat dailybuild_url.txt
        fi
    elif [[ $3 == true ]]; then

        dailybuild_url=$2/
    fi
    endtime=$(date +%s);
    echo -e "##############################"
    time_elapsed $starttime $endtime
    echo -e "##############################\n\n"
}


function get_and_save_dailybuilt_url(){
    #####$1: ${tmp_date}_parse_website.txt
    #####$2: $image_website
    #####$3: $bootimgornot
    #####$4: $keyForGrep
    echo -e "##############################"
    echo -e "##### get dailybuilt URL "
    echo -e "###############################"
    pwd
    echo -e "$@"
    if [[ "$WORKSPACE" != "`pwd`" ]]; then
       cd "$WORKSPACE"
    fi
    pwd
    starttime=$(date +%s);
    if [[ $3 == false ]]; then
        dailybuild_suffix=`cat "$1"  | grep -i "$4" | awk -F "\"" '{print $2 }' | awk -F "-" '{print $NF }' | sort -n | tail -1`
        echo -e "dailybuild_suffix=$dailybuild_suffix"

        #dailybuild_suffix=80/
        dailybuild=`grep -nr "$4".*"$dailybuild_suffix" "$1"  | awk -F "\"" '{print $2}'`
        echo -e "dailybuild=$dailybuild"

        dailybuild_url=$2/$dailybuild
        TEMP_DAILYBUILT_NUMBER=`cat "$1" | grep -i "$4" | awk -F "\"" '{print $2 }' | awk -F "-" '{print $NF }' | sort -n | tail -1 | tr -cd "[0-9]" `
        echo "TEMP_DAILYBUILT_NUMBER=$TEMP_DAILYBUILT_NUMBER"
        TEMP_DAILYBUILT_NUMBER=`echo ${dailybuild_suffix%?}`
        echo "TEMP_DAILYBUILT_NUMBER=$TEMP_DAILYBUILT_NUMBER"

        TEMP_DAILYBUILT_DATE=`grep -nr "$4".*"$dailybuild_suffix" "$1"  | awk -F " " '{print $3}' | awk -F "-" '{print $3$2$1}'`
        echo "TEMP_DAILYBUILT_DATE=$TEMP_DAILYBUILT_DATE"
    elif [[ $3 == true ]]; then

        dailybuild_url=$2/
    fi
    echo "dailybuild_url=$dailybuild_url"
    echo "$dailybuild_url" > dailybuild_url.txt
    cat dailybuild_url.txt
    sed -e "s#\/#\\\/#g" -i dailybuild_url.txt
    cat dailybuild_url.txt
    endtime=$(date +%s);
    echo -e "##############################"
    time_elapsed $starttime $endtime
    echo -e "##############################\n\n"
}

function get_dailybuilt_date_number(){
    ##### $1 ${tmp_date}_parse_website.txt
    ##### $2 inject env txt
    ##### $3 dailybuild_suffix
    ##### $4 automation_type
    ##### $5 key_search
    echo -e "##############################"
    echo -e "##### get dailybuilt date and number "
    echo -e "###############################"
    pwd
    if [[ "$WORKSPACE" != "`pwd`" ]]; then
       cd "$WORKSPACE"
    fi
    pwd
    starttime=$(date +%s);

    DAILYBUILT_NUMBER=`cat $1 | grep -i "$5" | awk -F "\"" '{print $2 }' | awk -F "-" '{print $NF }' | sort -n | tail -1 | tr -cd "[0-9]" `
    echo "DAILYBUILT_NUMBER=$DAILYBUILT_NUMBER"
    DAILYBUILT_NUMBER=`echo ${dailybuild_suffix%?}`
    echo "DAILYBUILT_NUMBER=$DAILYBUILT_NUMBER"

    current_dailybuilt_date=`grep -nr "$5".*"$3" $1  | awk -F " " '{print $3}'`
    echo "current_dailybuilt_date=$current_dailybuilt_date"
    echo "expected dailybuilt date: `date +%d-%b-%Y`"
    DAILYBUILT_DATE=`grep -nr "$5".*"$3" $1  | awk -F " " '{print $3}' | awk -F "-" '{print $3$2$1}'`
    echo "DAILYBUILT_DATE=$DAILYBUILT_DATE"
    if [[ $4 == sanity ]] || [[ $4 == smoke ]]; then
        echo "CUSTOMIZED_EMAIL_CONTENT=AOSP-P-Smoke-Test_${DAILYBUILT_DATE}_dailybuilt#${DAILYBUILT_NUMBER}_result" >  $2
        echo "AOSP-${git_branch}-Smoke-Test_${DAILYBUILT_DATE}_dailybuilt#${DAILYBUILT_NUMBER}_result" >  "$final_subject"
    elif [[ $4 == regression ]]; then
        echo "CUSTOMIZED_EMAIL_CONTENT=AOSP-P-Regression-Test_${DAILYBUILT_DATE}_dailybuilt#${DAILYBUILT_NUMBER}_result" >  $2
        echo "AOSP-${git_branch}-Regression-Test_${DAILYBUILT_DATE}_dailybuilt#${DAILYBUILT_NUMBER}_result" >  "$final_subject"
    else
        echo "CUSTOMIZED_EMAIL_CONTENT=AOSP-P-Test_${DAILYBUILT_DATE}_dailybuilt#${DAILYBUILT_NUMBER}_result" >  $2
        echo "AOSP-${git_branch}-Test_${DAILYBUILT_DATE}_dailybuilt#${DAILYBUILT_NUMBER}_result" >  "$final_subject"
    fi

    cat  $2
    cat  "$final_subject"

    if [[ $DAILYBUILT_DATE == *Jan* ]]; then
        sed -e "s/Jan/01/g" -i  $2
        sed -e "s/Jan/01/g" -i  "$final_subject"
    elif [[ $DAILYBUILT_DATE == *Feb* ]]; then
        sed -e "s/Feb/02/g" -i  $2
        sed -e "s/Feb/02/g" -i  "$final_subject"
    elif [[ $DAILYBUILT_DATE == *Mar* ]]; then
        sed -e "s/Mar/03/g" -i  $2
        sed -e "s/Mar/03/g" -i  "$final_subject"
    elif [[ $DAILYBUILT_DATE == *Apr* ]]; then
        sed -e "s/Apr/04/g" -i  $2
        sed -e "s/Apr/04/g" -i  "$final_subject"
    elif [[ $DAILYBUILT_DATE == *May* ]]; then
        sed -e "s/May/05/g" -i  $2
        sed -e "s/May/05/g" -i  "$final_subject"
    elif [[ $DAILYBUILT_DATE == *Jun* ]]; then
        sed -e "s/Jun/06/g" -i  $2
        sed -e "s/Jun/06/g" -i  "$final_subject"
    elif [[ $DAILYBUILT_DATE == *Jul* ]]; then
        sed -e "s/Jul/07/g" -i  $2
        sed -e "s/Jul/07/g" -i  "$final_subject"
    elif [[ $DAILYBUILT_DATE == *Aug* ]]; then
        sed -e "s/Aug/08/g" -i  $2
        sed -e "s/Aug/08/g" -i  "$final_subject"
    elif [[ $DAILYBUILT_DATE == *Sep* ]]; then
        sed -e "s/Sep/09/g" -i  $2
        sed -e "s/Sep/09/g" -i  "$final_subject"
    elif [[ $DAILYBUILT_DATE == *Oct* ]]; then
        sed -e "s/Oct/10/g" -i  $2
        sed -e "s/Oct/10/g" -i  "$final_subject"
    elif [[ $DAILYBUILT_DATE == *Nov* ]]; then
        sed -e "s/Nov/11/g" -i  $2
        sed -e "s/Nov/11/g" -i  "$final_subject"
    elif [[ $DAILYBUILT_DATE == *Dec* ]]; then
        sed -e "s/Dec/12/g" -i  $2
        sed -e "s/Dec/12/g" -i  "$final_subject"
    fi

    echo "CUSTOMIZED_TEMPLATE=$final_template" >>  $2
    cat  $2
    cat  "$final_subject"
    endtime=$(date +%s);
    echo -e "###############################"
    time_elapsed $starttime $endtime
    echo -e "###############################\n\n"
}

function check_new_dailybuilt(){
    echo -e "##############################"
    echo -e "##### check_new_dailybuilt"
    echo -e "###############################"
    starttime=$(date +%s);
   
    if [[ $current_dailybuilt_date == "`date +%d-%b-%Y`" ]]; then 
       is_new_dailybuilt=true
    else 
       is_new_dailybuilt=false
    fi
    endtime=$(date +%s);
    echo -e "##############################"
    time_elapsed $starttime $endtime
    echo -e "##############################\n\n"
}

function check_images_before_download(){
    ##### $1: android version
    ##### $2: enable_slot_ab
    echo -e "##############################"
    echo -e "##### check asop image according to Android version"
    echo -e "###############################"
    starttime=$(date +%s);
    boot_image=`cat $3  | grep "boot\.img"  | awk -F "\"" '{print $2}'`
    system_image=`cat $3  | grep "system\.img"  | awk -F "\"" '{print $2}'`
    userdata_image=`cat $3  | grep "userdata\.img"  | awk -F "\"" '{print $2}'`
    cache_image=`cat $3  | grep "cache\.img"  | awk -F "\"" '{print $2}'`
    vendor_image=`cat $3  | grep "vendor\.img"  | awk -F "\"" '{print $2}'`
    misc_image=`cat $3  | grep "misc\.img"  | awk -F "\"" '{print $2}'`
    vbmeta_image=`cat $3  | grep "vbmeta\.img"  | awk -F "\"" '{print $2}'`
    all_images=`cat $3  | grep "img"  | awk -F "\"" '{print $2}'`
    echo -e "all_iamges: $all_images"
    #cat $savedtxt
    fastboot=`cat $3  | grep "fastboot"  | awk -F "\"" '{print $2}'`
    echo -e "fastboot: $fastboot"
    gpt=`cat $3  | grep "gpt\.bin"  | awk -F "\"" '{print $2}'`
    echo -e "gpt: $gpt"

    if [[ $1 == [Nn]* ]]; then
        if [[ ! -z $boot_image ]] && [[ ! -z $system_image ]] && [[ ! -z $userdata_image ]] && [[ ! -z $cache_image ]] && [[ ! -z $gpt ]]; then
            echo "Android N AOSP images only contains boot/system/cache/userdata/gpt.bin images"
            is_download=true
        else
            echo "Not Android N AOSP images"
            is_download=false
        fi
    fi

    if [[ $1 == [Pp]* ]]; then
        if [[ $2 == false ]]; then
            if [[ ! -z $boot_image ]] && [[ ! -z $system_image ]] && [[ ! -z $userdata_image ]] && [[ ! -z $cache_image ]] && [[ ! -z $vendor_image ]] && [[ ! -z $gpt ]]; then
                echo "Android P AOSP images but not A/B partion, only contains boot/system/cache/userdata/vendor images"
                is_download=true
            else
                echo "Not Android P AOSP images without A/B "
                is_download=false
            fi
        elif [[ $2 == true ]]; then
            if [[ ! -z $boot_image ]] && [[ ! -z $system_image ]] && [[ ! -z $userdata_image ]] && [[ ! -z $misc_image ]] && [[ ! -z $vendor_image ]] && [[ ! -z $vbmeta_image ]] && [[ ! -z $gpt ]]; then
                echo "Android P AOSP images and A/B partition only contains boot/system/userdata/vendor/misc/vbmeta images"
                is_download=true
            else
                echo "Not Android P AOSP images with A/B"
                is_download=false
            fi
        fi
    fi
    echo "whether download: $is_download"
    endtime=$(date +%s);
    echo -e "##############################"
    time_elapsed $starttime $endtime
    echo -e "##############################\n\n"
}

function check_images(){
    ##### $1: android version
    ##### $2: enable_slot_ab
    echo -e "##############################"
    echo -e "##### check asop image according to Android version"
    echo -e "###############################"
    pwd
    if [[ "$WORKSPACE" != "`pwd`" ]]; then
       cd "$WORKSPACE"
    fi
    pwd
    starttime=$(date +%s);
    if [[ $1 == [Nn]* ]]; then
        if [[ -f  boot.img ]] && [[ -f  system.img ]] && [[ -f  userdata.img ]] && [[ -f  cache.img ]] && [[ ! -f  vendor.img ]] && [[ ! -f  misc.img ]] && [[ ! -f  vbmeta.img ]]; then
            echo "Android N AOSP images only contains boot/system/cache/userdata images"
        else
            echo "Not Android N AOSP images"
            exit -1
        fi
    fi

    if [[ $1 == [Pp]* ]]; then
        if [[ $2 == false ]]; then
            if [[ -f  boot.img ]] && [[ -f  system.img ]] && [[ -f  userdata.img ]] && [[ -f  cache.img ]] && [[ -f  vendor.img ]] && [[ ! -f  misc.img ]] && [[ ! -f  vbmeta.img ]]; then
                echo "Android P AOSP images but not A/B partition, only contains boot/system/cache/userdata/vendor images"
            else
                echo "Not Android P AOSP images without A/B partition "
                exit -1
            fi
        elif [[ $2 == true ]]; then
            if [[ -f  boot.img ]] && [[ -f  system.img ]] && [[ -f  userdata.img ]] && [[ ! -f  cache.img ]] && [[ -f  vendor.img ]] && [[ -f  misc.img ]] && [[ -f  vbmeta.img ]]; then
                echo "Android P AOSP images and A/B partition only contains boot/system/userdata/vendor/misc/vbmeta images"
            else
                echo "Not Android P AOSP images with A/B partition"
                exit -1
            fi
        fi
    fi
    if [[ -f  gpt.bin ]]; then
        echo "gpt.bin found at ${WORKSPACE}"
    else
        echo "gpt.bin not found at ${WORKSPACE}"
        exit -1
    fi

    endtime=$(date +%s);
    echo -e "##############################"
    time_elapsed $starttime $endtime
    echo -e "##############################\n\n"
}

function check_adb_connect(){
    #####$1 target ip address
    #####$2 "before" or "after"
    #####$3 time for timeout, minute
    echo -e "##############################"
    echo -e "##### check target is adb connect successfully"
    echo -e "###############################"
    adb version
    starttime=$(date +%s);
    a=0
    count=0
    total_times=$[$[60*$3]/5]
    echo "Try connect $total_times times, about $3 minute(s)"
    while [ $a -lt 30 -a $count -lt $total_times ]
    do
            ExistValue=`adb devices | grep "$1"`
            echo "[$ExistValue]"
            if [ -n "$ExistValue" ]; then
                adb shell ls storage
                sleep 1
                echo "connected"
                a=30
            else
                adb connect $1
                echo "Tried connecting"
                adb shell ls storage
                sleep 1
            fi
        sleep 4
        let count+=1
        echo     "################"
        echo     "#####count:$count"
        echo -e  "################\n"

    done
    if [[ $a == 30 ]]; then
        if [[ $2 == before ]]; then
            target_is_reachable_before_flash=true
        elif [[ $2 == after ]]; then
            target_is_reachable_after_flash=true
        fi
    else
        if [[ $2 == before ]]; then
            target_is_reachable_before_flash=false
        elif [[ $2 == after ]]; then
            target_is_reachable_after_flash=false
        fi
    fi
    echo  "target_is_reachable_before_flash: $target_is_reachable_before_flash"
    echo  "target_is_reachable_after_flash: $target_is_reachable_after_flash"
    endtime=$(date +%s);
    echo -e "##############################"
    time_elapsed $starttime $endtime
    echo -e "##############################\n\n"
}

function check_target_is_reachable_before_flash(){
    #####$1 deadline
    #####$2 target ip address
    echo -e "##############################"
    echo -e "##### check target is reachable and adb connect successfully"
    echo -e "###############################"
    starttime=$(date +%s);
    a=0
    while [ $a -lt 30 ]
    do
        Reachable=`ping -w $2 $1   | grep -i "time="`
        echo -e "Reachable=$Reachable\n"
        if [[ -z $Reachable ]]; then
            echo -e "Unreachable target device ip:$1\n"
        else
            echo -e "Reachable target device ip:$1\n"
            ExistValue=`adb devices | grep "$1"`
            echo "[$ExistValue]"
            if [ -n "$ExistValue" ]; then
                adb shell ls storage
                sleep 1
                echo "connected"
                a=30
            else
                adb connect $1
                echo "Tried connecting"
                adb shell ls storage
                sleep 1
            fi

        fi
    done
    endtime=$(date +%s);
    echo -e "##############################"
    time_elapsed $starttime $endtime
    echo -e "##############################\n\n"
}

function check_target_is_reachable_timeout(){
    #####$1 deadline
    #####$2 target ip address
    echo -e "##############################"
    echo -e "##### check target is reachable and adb connect successfully but have timeout"
    echo -e "###############################"
    starttime=$(date +%s);
    a=0
    count=0
    total_times=$[$[60/$2]*$3]
    echo "Try connect $total_times times"
    echo  "start time: `date +%Y%m%d_%H_%M_%S_%p`"
    while [ $a -lt 30 -a $count -lt $total_times ]
    do
        Reachable=`ping -w $2 $1   | grep -i "time="`
        echo -e "Reachable=$Reachable\n"
        if [[ -z $Reachable ]]; then
            echo -e "Unreachable target device ip:$1\n"
        else
            echo -e "Reachable target device ip:$1\n"
            ExistValue=`adb devices | grep "$1"`
            echo "[$ExistValue]"
            if [ -n "$ExistValue" ]; then
                adb shell ls storage
                sleep 1
                echo "connected"
                a=30
            else
                adb connect $1
                echo "Tried connecting"
                adb shell ls storage
                sleep 1
            fi
        fi
        let count+=1
        echo     "################"
        echo     "#####count:$count"
        echo -e  "################\n"
    done
    echo  "End time: `date +%Y%m%d_%H_%M_%S_%p`"
    if [[ $a == 30 ]]; then
        if [[ $4 == before ]]; then
            target_is_reachable_before_flash=true
        elif [[ $4 == after ]]; then
            target_is_reachable_after_flash=true
        fi
    else
        if [[ $4 == before ]]; then
            target_is_reachable_before_flash=false
        elif [[ $4 == after ]]; then
            target_is_reachable_after_flash=false
        fi
    fi
    echo  "target_is_reachable_before_flash: $target_is_reachable_before_flash"
    echo  "target_is_reachable_after_flash: $target_is_reachable_after_flash"
    endtime=$(date +%s);
    echo -e "##############################"
    time_elapsed $starttime $endtime
    echo -e "##############################\n\n"
}

function check_string_tail(){
    #####$1 $String:
    #####$2 $substring:
    istailornot=`echo $1 | grep "$2$"`
    if [ -z $istailornot ]; then
        echo 0
    else
        echo 1
    fi
}

function merge_style_into_missing_template(){
    #####$1: style
    #####$2: missing_template
    #####$3: what line
    echo -e "##############################"
    echo -e "##### merge_style_into_missing_template"
    echo -e "###############################"
    starttime=$(date +%s);

    count=$3
    while read line
    do
        count=$(( count+1 ))
        sed "`echo $count`a\\$line" -i $2
    done < $1

    endtime=$(date +%s);
    echo -e "##############################"
    time_elapsed $starttime $endtime
    echo -e "##############################\n\n"

}


function create_normal_exception_reason_info_email_template(){
    #####$1: $exception_reason
    echo -e "##############################"
    echo -e "##### create_normal_exception_reason_info_email_template"
    echo -e "###############################"
    pwd
    if [[ "$WORKSPACE" != "`pwd`" ]]; then
       cd "$WORKSPACE"
    fi
    pwd
    starttime=$(date +%s);


echo "<html>" >  $1
echo "</html>" >>  $1

    endtime=$(date +%s);
    echo -e "##############################"
    time_elapsed $starttime $endtime
    echo -e "##############################\n\n"
}

function create_normal_build_info_email_template(){
    #####$1: $detail_info
    echo -e "##############################"
    echo -e "##### create_normal_build_info_email_template"
    echo -e "###############################"
    pwd
    if [[ "$WORKSPACE" != "`pwd`" ]]; then
       cd "$WORKSPACE"
    fi
    pwd
    starttime=$(date +%s);


echo "<html>" >  $1
echo "<STYLE>" >>  $1
echo "  BODY, TABLE, TD, TH, P {" >>  $1
echo "    font-family: Calibri, Verdana, Helvetica, sans serif;" >>  $1
echo "    font-size: 12px;" >>  $1
echo "    color: black;" >>  $1
echo "  }" >>  $1
echo "  .console {" >>  $1
echo "    font-family: Courier New;" >>  $1
echo "  }" >>  $1
echo "  .filesChanged {" >>  $1
echo "    width: 10%;" >>  $1
echo "    padding-left: 10px;" >>  $1
echo "  }" >>  $1
echo "  .section {" >>  $1
echo "    width: 100%;" >>  $1
echo "    border: thin black dotted;" >>  $1
echo "  }" >>  $1
echo "  .td-title-main {" >>  $1
echo "    color: white;" >>  $1
echo "    font-size: 200%;" >>  $1
echo "    padding-left: 5px;" >>  $1
echo "    font-weight: bold;" >>  $1
echo "  }" >>  $1
echo "  .td-title {" >>  $1
echo "    color: white;" >>  $1
echo "    font-size: 120%;" >>  $1
echo "    font-weight: bold;" >>  $1
echo "    padding-left: 5px;" >>  $1
echo "    text-transform: uppercase;" >>  $1
echo "  }" >>  $1
echo "  .td-title-tests {" >>  $1
echo "    font-weight: bold;" >>  $1
echo "    font-size: 120%;" >>  $1
echo "  }" >>  $1
echo "  .td-header-maven-module {" >>  $1
echo "    font-weight: bold;" >>  $1
echo "    font-size: 120%;    " >>  $1
echo "  }" >>  $1
echo "  .td-maven-artifact {" >>  $1
echo "    padding-left: 5px;" >>  $1
echo "  }" >>  $1
echo "  .tr-title {" >>  $1
echo "    background-color: #27AE60 " >>  $1
#echo "    background-color: <%= (build.result == null || build.result.toString() == 'SUCCESS') ? '#27AE60' : build.result.toString() == 'FAILURE' ? '#E74C3C' : '#f4e242' %>;" >>  $1
echo "  }" >>  $1
echo "  .test {" >>  $1
echo "    padding-left: 20px;" >>  $1
echo "  }" >>  $1
echo "  .test-fixed {" >>  $1
echo "    color: #27AE60;" >>  $1
echo "  }" >>  $1
echo "  .test-failed {" >>  $1
echo "    color: #E74C3C;" >>  $1
echo "  }" >>  $1
echo "</STYLE>" >>  $1
echo "<BODY>" >>  $1
echo "  <!-- BUILD RESULT -->" >>  $1
echo "  <table class=\"section\" border=\"1\">" >>  $1
echo "    <tr class=\"tr-title\">" >>  $1
echo "      <td class=\"td-title-main\" colspan=2>" >>  $1
echo "        BIOS & AOSP INFO" >>  $1
echo "      </td>" >>  $1
echo "    </tr>" >>  $1
echo "    <tr>" >>  $1
echo "      <td>BIOS:</td>" >>  $1
echo "      <td>BIOSVERSION</td>" >>  $1
echo "    </tr>" >>  $1
echo "    <tr>" >>  $1
echo "      <td>AOSP URL:</td>" >>  $1
echo "      <td><A href=\"aosp_url\">aosp_url</A></td>" >>  $1
echo "    </tr>" >>  $1
echo "    <tr>" >>  $1
echo "      <td>Duration of flash:</td>" >>  $1
echo "      <td>flash_duration</td>" >>  $1
echo "    </tr>" >>  $1
echo "    <tr>" >>  $1
echo "      <td>Duration of download:</td>" >>  $1
echo "      <td>download_duration</td>" >>  $1
echo "    </tr>" >>  $1
echo "    <tr>" >>  $1
echo "      <td>Duration of test:</td>" >>  $1
echo "      <td>test_duration</td>" >>  $1
echo "    </tr>" >>  $1
echo "  </table>" >>  $1
echo "  <br/>" >>  $1
echo "</BODY>" >>  $1
echo "</html>" >>  $1

#echo "<BODY>" >>  $1
#echo "  <table class=\"section\" border=\"1\">" >>  $1
#echo "    <tr class=\"tr-title\">" >>  $1
#echo "      <td class=\"td-title-main\" colspan=2>" >>  $1
#echo "        Failure reason: Missing images" >>  $1
#echo "      </td>" >>  $1
#echo "    </tr>" >>  $1
#echo "  </table>" >>  $1
#echo "  <br/>" >>  $1

#echo "</BODY>" >>  $1


    endtime=$(date +%s);
    echo -e "##############################"
    time_elapsed $starttime $endtime
    echo -e "##############################\n\n"

}



function create_exception_email_template(){
    #####$1: $final_template
    echo -e "##############################"
    echo -e "##### create_exception_email_template"
    echo -e "###############################"
    pwd
    if [[ "$WORKSPACE" != "`pwd`" ]]; then
       cd "$WORKSPACE"
    fi
    pwd
    starttime=$(date +%s);


echo "<STYLE>" >  $1
echo "  BODY, TABLE, TD, TH, P {" >>  $1
echo "    font-family: Calibri, Verdana, Helvetica, sans serif;" >>  $1
echo "    font-size: 12px;" >>  $1
echo "    color: black;" >>  $1
echo "  }" >>  $1
echo "  .console {" >>  $1
echo "    font-family: Courier New;" >>  $1
echo "  }" >>  $1
echo "  .filesChanged {" >>  $1
echo "    width: 10%;" >>  $1
echo "    padding-left: 10px;" >>  $1
echo "  }" >>  $1
echo "  .section {" >>  $1
echo "    width: 100%;" >>  $1
echo "    border: thin black dotted;" >>  $1
echo "  }" >>  $1
echo "  .td-title-main {" >>  $1
echo "    color: white;" >>  $1
echo "    font-size: 200%;" >>  $1
echo "    padding-left: 5px;" >>  $1
echo "    font-weight: bold;" >>  $1
echo "  }" >>  $1
echo "  .td-title {" >>  $1
echo "    color: white;" >>  $1
echo "    font-size: 120%;" >>  $1
echo "    font-weight: bold;" >>  $1
echo "    padding-left: 5px;" >>  $1
echo "    text-transform: uppercase;" >>  $1
echo "  }" >>  $1
echo "  .td-title-tests {" >>  $1
echo "    font-weight: bold;" >>  $1
echo "    font-size: 120%;" >>  $1
echo "  }" >>  $1
echo "  .td-header-maven-module {" >>  $1
echo "    font-weight: bold;" >>  $1
echo "    font-size: 120%;    " >>  $1
echo "  }" >>  $1
echo "  .td-maven-artifact {" >>  $1
echo "    padding-left: 5px;" >>  $1
echo "  }" >>  $1
echo "  .tr-title {" >>  $1
echo "    background-color: <%= (build.result == null || build.result.toString() == 'SUCCESS') ? '#27AE60' : build.result.toString() == 'FAILURE' ? '#E74C3C' : '#f4e242' %>;" >>  $1
echo "  }" >>  $1
echo "  .test {" >>  $1
echo "    padding-left: 20px;" >>  $1
echo "  }" >>  $1
echo "  .test-fixed {" >>  $1
echo "    color: #27AE60;" >>  $1
echo "  }" >>  $1
echo "  .test-failed {" >>  $1
echo "    color: #E74C3C;" >>  $1
echo "  }" >>  $1
echo "</STYLE>" >>  $1
echo "<BODY>" >>  $1
echo "  <!-- BUILD RESULT -->" >>  $1
echo "  <table class=\"section\" border=\"1\">" >>  $1
echo "    <tr class=\"tr-title\">" >>  $1
echo "      <td class=\"td-title-main\" colspan=2>" >>  $1
echo "        BUILD \${build.result ?: 'COMPLETED'}" >>  $1
echo "      </td>" >>  $1
echo "    </tr>" >>  $1
echo "    <tr>" >>  $1
echo "      <td>URL:</td>" >>  $1
echo "      <td><A href=\"\${rooturl}\${build.url}\">\${rooturl}\${build.url}</A></td>" >>  $1
echo "    </tr>" >>  $1
echo "    <tr>" >>  $1
echo "      <td>Project:</td>" >>  $1
echo "      <td>\${project.name}</td>" >>  $1
echo "    </tr>" >>  $1
echo "    <tr>" >>  $1
echo "      <td>Date:</td>" >>  $1
echo "      <td>\${it.timestampString}</td>" >>  $1
echo "    </tr>" >>  $1
echo "    <tr>" >>  $1
echo "      <td>Duration:</td>" >>  $1
echo "      <td>\${build.durationString}</td>" >>  $1
echo "    </tr>" >>  $1
echo "    <tr>" >>  $1
echo "      <td>Cause:</td>" >>  $1
echo "      <td><% build.causes.each() { cause -> %> \${cause.shortDescription} <%  } %></td>" >>  $1
echo "    </tr>" >>  $1
echo "  </table>" >>  $1
echo "  <br/>" >>  $1
echo "</BODY>" >>  $1



    endtime=$(date +%s);
    echo -e "##############################"
    time_elapsed $starttime $endtime
    echo -e "##############################\n\n"

}


function create_no_new_dailybuild_exception_build_info_email_template(){
    #####$1: miss_template_file_name, such as "missing_style.template"
    echo -e "##############################"
    echo -e "##### create_no_new_dailybuild_exception_build_info_email_template"
    echo -e "###############################"
    pwd
    if [[ "$WORKSPACE" != "`pwd`" ]]; then
       cd "$WORKSPACE"
    fi
    pwd
    starttime=$(date +%s);

echo "<html>" > $1
echo "<STYLE>" >>  $1
echo "  BODY, TABLE, TD, TH, P {" >>  $1
echo "    font-family: Calibri, Verdana, Helvetica, sans serif;" >>  $1
echo "    font-size: 12px;" >>  $1
echo "    color: black;" >>  $1
echo "  }" >>  $1
echo "  .console {" >>  $1
echo "    font-family: Courier New;" >>  $1
echo "  }" >>  $1
echo "  .filesChanged {" >>  $1
echo "    width: 10%;" >>  $1
echo "    padding-left: 10px;" >>  $1
echo "  }" >>  $1
echo "  .section {" >>  $1
echo "    width: 100%;" >>  $1
echo "    border: thin black dotted;" >>  $1
echo "  }" >>  $1
echo "  .td-title-main {" >>  $1
echo "    color: white;" >>  $1
echo "    font-size: 200%;" >>  $1
echo "    padding-left: 5px;" >>  $1
echo "    font-weight: bold;" >>  $1
echo "  }" >>  $1
echo "  .td-title {" >>  $1
echo "    color: white;" >>  $1
echo "    font-size: 120%;" >>  $1
echo "    font-weight: bold;" >>  $1
echo "    padding-left: 5px;" >>  $1
echo "    text-transform: uppercase;" >>  $1
echo "  }" >>  $1
echo "  .td-title-tests {" >>  $1
echo "    font-weight: bold;" >>  $1
echo "    font-size: 120%;" >>  $1
echo "  }" >>  $1
echo "  .td-header-maven-module {" >>  $1
echo "    font-weight: bold;" >>  $1
echo "    font-size: 120%;    " >>  $1
echo "  }" >>  $1
echo "  .td-maven-artifact {" >>  $1
echo "    padding-left: 5px;" >>  $1
echo "  }" >>  $1
echo "  .tr-title {" >>  $1
echo "    background-color: #E74C3C" >>  $1
echo "  }" >>  $1
echo "  .test {" >>  $1
echo "    padding-left: 20px;" >>  $1
echo "  }" >>  $1
echo "  .test-fixed {" >>  $1
echo "    color: #27AE60;" >>  $1
echo "  }" >>  $1
echo "  .test-failed {" >>  $1
echo "    color: #E74C3C;" >>  $1
echo "  }" >>  $1
echo "</STYLE>" >>  $1

echo "<BODY>" >>  $1
echo "  <!-- BUILD RESULT -->" >>  $1
echo "  <table class=\"section\" border=\"1\">" >>  $1
echo "    <tr class=\"tr-title\">" >>  $1
echo "      <td class=\"td-title-main\" colspan=2>" >>  $1
echo "        AOSP INFO: Not found new dailybuild with date expecteddate" >>  $1
echo "      </td>" >>  $1
echo "    </tr>" >>  $1
echo "    <tr>" >>  $1
echo "      <td>AOSP URL:</td>" >>  $1
echo "      <td><A href=\"aosp_url\">aosp_url</A></td>" >>  $1
echo "    </tr>" >>  $1
echo "<!--bios_flag" >>  $1
echo "    <tr>" >>  $1
echo "      <td>BIOS:</td>" >>  $1
echo "      <td>BIOSVERSION</td>" >>  $1
echo "    </tr>" >>  $1
echo "bios_flag-->" >>  $1
echo "  </table>" >>  $1
echo "  <br/>" >>  $1
echo "</BODY>" >>  $1

#echo "<BODY>" >>  $1
#echo "  <table class=\"section\" border=\"1\">" >>  $1
#echo "    <tr class=\"tr-title\">" >>  $1
#echo "      <td class=\"td-title-main\" colspan=2>" >>  $1
#echo "        Failure reason: Missing images" >>  $1
#echo "      </td>" >>  $1
#echo "    </tr>" >>  $1
#echo "  </table>" >>  $1
#echo "  <br/>" >>  $1

#echo "</BODY>" >>  $1
echo "</html>" >> $1


    endtime=$(date +%s);
    echo -e "##############################"
    time_elapsed $starttime $endtime
    echo -e "##############################\n\n"

}



function create_exception_build_info_email_template(){
    #####$1: miss_template_file_name, such as "missing_style.template"
    echo -e "##############################"
    echo -e "##### create_exception_build_info_email_template"
    echo -e "###############################"
    pwd
    if [[ "$WORKSPACE" != "`pwd`" ]]; then
       cd "$WORKSPACE"
    fi
    pwd
    starttime=$(date +%s);

echo "<html>" > $1
echo "<STYLE>" >>  $1
echo "  BODY, TABLE, TD, TH, P {" >>  $1
echo "    font-family: Calibri, Verdana, Helvetica, sans serif;" >>  $1
echo "    font-size: 12px;" >>  $1
echo "    color: black;" >>  $1
echo "  }" >>  $1
echo "  .console {" >>  $1
echo "    font-family: Courier New;" >>  $1
echo "  }" >>  $1
echo "  .filesChanged {" >>  $1
echo "    width: 10%;" >>  $1
echo "    padding-left: 10px;" >>  $1
echo "  }" >>  $1
echo "  .section {" >>  $1
echo "    width: 100%;" >>  $1
echo "    border: thin black dotted;" >>  $1
echo "  }" >>  $1
echo "  .td-title-main {" >>  $1
echo "    color: white;" >>  $1
echo "    font-size: 200%;" >>  $1
echo "    padding-left: 5px;" >>  $1
echo "    font-weight: bold;" >>  $1
echo "  }" >>  $1
echo "  .td-title {" >>  $1
echo "    color: white;" >>  $1
echo "    font-size: 120%;" >>  $1
echo "    font-weight: bold;" >>  $1
echo "    padding-left: 5px;" >>  $1
echo "    text-transform: uppercase;" >>  $1
echo "  }" >>  $1
echo "  .td-title-tests {" >>  $1
echo "    font-weight: bold;" >>  $1
echo "    font-size: 120%;" >>  $1
echo "  }" >>  $1
echo "  .td-header-maven-module {" >>  $1
echo "    font-weight: bold;" >>  $1
echo "    font-size: 120%;    " >>  $1
echo "  }" >>  $1
echo "  .td-maven-artifact {" >>  $1
echo "    padding-left: 5px;" >>  $1
echo "  }" >>  $1
echo "  .tr-title {" >>  $1
echo "    background-color: #E74C3C" >>  $1
echo "  }" >>  $1
echo "  .test {" >>  $1
echo "    padding-left: 20px;" >>  $1
echo "  }" >>  $1
echo "  .test-fixed {" >>  $1
echo "    color: #27AE60;" >>  $1
echo "  }" >>  $1
echo "  .test-failed {" >>  $1
echo "    color: #E74C3C;" >>  $1
echo "  }" >>  $1
echo "</STYLE>" >>  $1

echo "<BODY>" >>  $1
echo "  <!-- BUILD RESULT -->" >>  $1
echo "  <table class=\"section\" border=\"1\">" >>  $1
echo "    <tr class=\"tr-title\">" >>  $1
echo "      <td class=\"td-title-main\" colspan=2>" >>  $1
echo "        AOSP INFO" >>  $1
echo "      </td>" >>  $1
echo "    </tr>" >>  $1
echo "    <tr>" >>  $1
echo "      <td>AOSP URL:</td>" >>  $1
echo "      <td><A href=\"aosp_url\">aosp_url</A></td>" >>  $1
echo "    </tr>" >>  $1
echo "<!--bios_flag" >>  $1
echo "    <tr>" >>  $1
echo "      <td>BIOS:</td>" >>  $1
echo "      <td>BIOSVERSION</td>" >>  $1
echo "    </tr>" >>  $1
echo "bios_flag-->" >>  $1
echo "  </table>" >>  $1
echo "  <br/>" >>  $1
echo "</BODY>" >>  $1

#echo "<BODY>" >>  $1
#echo "  <table class=\"section\" border=\"1\">" >>  $1
#echo "    <tr class=\"tr-title\">" >>  $1
#echo "      <td class=\"td-title-main\" colspan=2>" >>  $1
#echo "        Failure reason: Missing images" >>  $1
#echo "      </td>" >>  $1
#echo "    </tr>" >>  $1
#echo "  </table>" >>  $1
#echo "  <br/>" >>  $1

#echo "</BODY>" >>  $1
echo "</html>" >> $1


    endtime=$(date +%s);
    echo -e "##############################"
    time_elapsed $starttime $endtime
    echo -e "##############################\n\n"

}


function create_exception_reason_info_email_template(){
    #####$1: miss_template_file_name, such as "missing_style.template"
    echo -e "##############################"
    echo -e "##### create_exception_reason_info_email_template"
    echo -e "###############################"
    pwd
    if [[ "$WORKSPACE" != "`pwd`" ]]; then
       cd "$WORKSPACE"
    fi
    pwd
    starttime=$(date +%s);

echo "<html>" > $1
echo "<STYLE>" >>  $1
echo "  BODY, TABLE, TD, TH, P {" >>  $1
echo "    font-family: Calibri, Verdana, Helvetica, sans serif;" >>  $1
echo "    font-size: 12px;" >>  $1
echo "    color: black;" >>  $1
echo "  }" >>  $1
echo "  .console {" >>  $1
echo "    font-family: Courier New;" >>  $1
echo "  }" >>  $1
echo "  .filesChanged {" >>  $1
echo "    width: 10%;" >>  $1
echo "    padding-left: 10px;" >>  $1
echo "  }" >>  $1
echo "  .section {" >>  $1
echo "    width: 100%;" >>  $1
echo "    border: thin black dotted;" >>  $1
echo "  }" >>  $1
echo "  .td-title-main {" >>  $1
echo "    color: white;" >>  $1
echo "    font-size: 200%;" >>  $1
echo "    padding-left: 5px;" >>  $1
echo "    font-weight: bold;" >>  $1
echo "  }" >>  $1
echo "  .td-title {" >>  $1
echo "    color: white;" >>  $1
echo "    font-size: 120%;" >>  $1
echo "    font-weight: bold;" >>  $1
echo "    padding-left: 5px;" >>  $1
echo "    text-transform: uppercase;" >>  $1
echo "  }" >>  $1
echo "  .td-title-tests {" >>  $1
echo "    font-weight: bold;" >>  $1
echo "    font-size: 120%;" >>  $1
echo "  }" >>  $1
echo "  .td-header-maven-module {" >>  $1
echo "    font-weight: bold;" >>  $1
echo "    font-size: 120%;    " >>  $1
echo "  }" >>  $1
echo "  .td-maven-artifact {" >>  $1
echo "    padding-left: 5px;" >>  $1
echo "  }" >>  $1
echo "  .tr-title {" >>  $1
echo "    background-color: #E74C3C" >>  $1
echo "  }" >>  $1
echo "  .test {" >>  $1
echo "    padding-left: 20px;" >>  $1
echo "  }" >>  $1
echo "  .test-fixed {" >>  $1
echo "    color: #27AE60;" >>  $1
echo "  }" >>  $1
echo "  .test-failed {" >>  $1
echo "    color: #E74C3C;" >>  $1
echo "  }" >>  $1
echo "</STYLE>" >>  $1

#echo "<BODY>" >>  $1
#echo "  <!-- BUILD RESULT -->" >>  $1
#echo "  <table class=\"section\" border=\"1\">" >>  $1
#echo "    <tr class=\"tr-title\">" >>  $1
#echo "      <td class=\"td-title-main\" colspan=2>" >>  $1
#echo "        BUILD INFO" >>  $1
#echo "      </td>" >>  $1
#echo "    </tr>" >>  $1
#echo "    <tr>" >>  $1
#echo "      <td>AOSP URL:</td>" >>  $1
#echo "      <td><A href=\"aosp_url\">aosp_url</A></td>" >>  $1
#echo "    </tr>" >>  $1
#echo "  </table>" >>  $1
#echo "  <br/>" >>  $1
#echo "</BODY>" >>  $1

echo "<BODY>" >>  $1
echo "  <table class=\"section\" border=\"1\">" >>  $1
echo "    <tr class=\"tr-title\">" >>  $1
echo "      <td class=\"td-title-main\" colspan=2>" >>  $1
echo "        Failure reason: Missing images" >>  $1
echo "      </td>" >>  $1
echo "    </tr>" >>  $1
echo "  </table>" >>  $1
echo "  <br/>" >>  $1

echo "</BODY>" >>  $1
echo "</html>" >> $1


    endtime=$(date +%s);
    echo -e "##############################"
    time_elapsed $starttime $endtime
    echo -e "##############################\n\n"

}


function create_missing_images_email_template(){
    #####$1: miss_template_file_name, such as "missing_style.template"
    echo -e "##############################"
    echo -e "##### create_missing_images_email_template"
    echo -e "###############################"
    pwd
    if [[ "$WORKSPACE" != "`pwd`" ]]; then
       cd "$WORKSPACE"
    fi
    pwd
    starttime=$(date +%s);


echo "<STYLE>" >  $1
echo "  BODY, TABLE, TD, TH, P {" >>  $1
echo "    font-family: Calibri, Verdana, Helvetica, sans serif;" >>  $1
echo "    font-size: 12px;" >>  $1
echo "    color: black;" >>  $1
echo "  }" >>  $1
echo "  .console {" >>  $1
echo "    font-family: Courier New;" >>  $1
echo "  }" >>  $1
echo "  .filesChanged {" >>  $1
echo "    width: 10%;" >>  $1
echo "    padding-left: 10px;" >>  $1
echo "  }" >>  $1
echo "  .section {" >>  $1
echo "    width: 100%;" >>  $1
echo "    border: thin black dotted;" >>  $1
echo "  }" >>  $1
echo "  .td-title-main {" >>  $1
echo "    color: white;" >>  $1
echo "    font-size: 200%;" >>  $1
echo "    padding-left: 5px;" >>  $1
echo "    font-weight: bold;" >>  $1
echo "  }" >>  $1
echo "  .td-title {" >>  $1
echo "    color: white;" >>  $1
echo "    font-size: 120%;" >>  $1
echo "    font-weight: bold;" >>  $1
echo "    padding-left: 5px;" >>  $1
echo "    text-transform: uppercase;" >>  $1
echo "  }" >>  $1
echo "  .td-title-tests {" >>  $1
echo "    font-weight: bold;" >>  $1
echo "    font-size: 120%;" >>  $1
echo "  }" >>  $1
echo "  .td-header-maven-module {" >>  $1
echo "    font-weight: bold;" >>  $1
echo "    font-size: 120%;    " >>  $1
echo "  }" >>  $1
echo "  .td-maven-artifact {" >>  $1
echo "    padding-left: 5px;" >>  $1
echo "  }" >>  $1
echo "  .tr-title {" >>  $1
echo "    background-color: <%= (build.result == null || build.result.toString() == 'SUCCESS') ? '#27AE60' : build.result.toString() == 'FAILURE' ? '#E74C3C' : '#f4e242' %>;" >>  $1
echo "  }" >>  $1
echo "  .test {" >>  $1
echo "    padding-left: 20px;" >>  $1
echo "  }" >>  $1
echo "  .test-fixed {" >>  $1
echo "    color: #27AE60;" >>  $1
echo "  }" >>  $1
echo "  .test-failed {" >>  $1
echo "    color: #E74C3C;" >>  $1
echo "  }" >>  $1
echo "</STYLE>" >>  $1
echo "<BODY>" >>  $1
echo "  <!-- BUILD RESULT -->" >>  $1
echo "  <table class=\"section\" border=\"1\">" >>  $1
echo "    <tr class=\"tr-title\">" >>  $1
echo "      <td class=\"td-title-main\" colspan=2>" >>  $1
echo "        BUILD \${build.result ?: 'COMPLETED'}" >>  $1
echo "      </td>" >>  $1
echo "    </tr>" >>  $1
echo "    <tr>" >>  $1
echo "      <td>URL:</td>" >>  $1
echo "      <td><A href=\"\${rooturl}\${build.url}\">\${rooturl}\${build.url}</A></td>" >>  $1
echo "    </tr>" >>  $1
echo "    <tr>" >>  $1
echo "      <td>Project:</td>" >>  $1
echo "      <td>\${project.name}</td>" >>  $1
echo "    </tr>" >>  $1
echo "    <tr>" >>  $1
echo "      <td>Date:</td>" >>  $1
echo "      <td>\${it.timestampString}</td>" >>  $1
echo "    </tr>" >>  $1
echo "    <tr>" >>  $1
echo "      <td>Duration:</td>" >>  $1
echo "      <td>\${build.durationString}</td>" >>  $1
echo "    </tr>" >>  $1
echo "<!--" >>  $1
echo "    <tr>" >>  $1
echo "      <td>Duration of flash:</td>" >>  $1
echo "      <td>flash_duration</td>" >>  $1
echo "    </tr>" >>  $1
echo "    <tr>" >>  $1
echo "      <td>Duration of download:</td>" >>  $1
echo "      <td>download_duration</td>" >>  $1
echo "    </tr>" >>  $1
echo "    <tr>" >>  $1
echo "      <td>Duration of test:</td>" >>  $1
echo "      <td>test_duration</td>" >>  $1
echo "    </tr>" >>  $1
echo "-->" >>  $1
echo "    <tr>" >>  $1
echo "      <td>Cause:</td>" >>  $1
echo "      <td><% build.causes.each() { cause -> %> \${cause.shortDescription} <%  } %></td>" >>  $1
echo "    </tr>" >>  $1
echo "    <tr>" >>  $1
echo "      <td>AOSP URL:</td>" >>  $1
echo "      <td><A href=\"aosp_url\">aosp_url</A></td>" >>  $1
echo "    </tr>" >>  $1
echo "<!--" >>  $1
echo "    <tr>" >>  $1
echo "      <td>BIOS:</td>" >>  $1
echo "      <td>BIOSVERSION</td>" >>  $1
echo "    </tr>" >>  $1
echo "-->" >>  $1
echo "  </table>" >>  $1
echo "  <br/>" >>  $1
echo "</BODY>" >>  $1

echo "<BODY>" >>  $1
echo "  <table class=\"section\" border=\"1\">" >>  $1
echo "    <tr class=\"tr-title\">" >>  $1
echo "      <td class=\"td-title-main\" colspan=2>" >>  $1
echo "        Failure reason: Missing images" >>  $1
echo "      </td>" >>  $1
echo "    </tr>" >>  $1
echo "  </table>" >>  $1
echo "  <br/>" >>  $1

echo "</BODY>" >>  $1


    endtime=$(date +%s);
    echo -e "##############################"
    time_elapsed $starttime $endtime
    echo -e "##############################\n\n"

}

function create_normal_email_template(){
    #####$1: $final_template
    echo -e "##############################"
    echo -e "##### create_normal_email_template"
    echo -e "###############################"
    pwd
    if [[ "$WORKSPACE" != "`pwd`" ]]; then
       cd "$WORKSPACE"
    fi
    pwd
    starttime=$(date +%s);

echo "<STYLE>" >  $1
echo "  BODY, TABLE, TD, TH, P {" >>  $1
echo "    font-family: Calibri, Verdana, Helvetica, sans serif;" >>  $1
echo "    font-size: 12px;" >>  $1
echo "    color: black;" >>  $1
echo "  }" >>  $1
echo "  .console {" >>  $1
echo "    font-family: Courier New;" >>  $1
echo "  }" >>  $1
echo "  .filesChanged {" >>  $1
echo "    width: 10%;" >>  $1
echo "    padding-left: 10px;" >>  $1
echo "  }" >>  $1
echo "  .section {" >>  $1
echo "    width: 100%;" >>  $1
echo "    border: thin black dotted;" >>  $1
echo "  }" >>  $1
echo "  .td-title-main {" >>  $1
echo "    color: white;" >>  $1
echo "    font-size: 200%;" >>  $1
echo "    padding-left: 5px;" >>  $1
echo "    font-weight: bold;" >>  $1
echo "  }" >>  $1
echo "  .td-title {" >>  $1
echo "    color: white;" >>  $1
echo "    font-size: 120%;" >>  $1
echo "    font-weight: bold;" >>  $1
echo "    padding-left: 5px;" >>  $1
echo "    text-transform: uppercase;" >>  $1
echo "  }" >>  $1
echo "  .td-title-tests {" >>  $1
echo "    font-weight: bold;" >>  $1
echo "    font-size: 120%;" >>  $1
echo "  }" >>  $1
echo "  .td-header-maven-module {" >>  $1
echo "    font-weight: bold;" >>  $1
echo "    font-size: 120%;    " >>  $1
echo "  }" >>  $1
echo "  .td-maven-artifact {" >>  $1
echo "    padding-left: 5px;" >>  $1
echo "  }" >>  $1
echo "  .tr-title {" >>  $1
echo "    background-color: <%= (build.result == null || build.result.toString() == 'SUCCESS') ? '#27AE60' : build.result.toString() == 'FAILURE' ? '#E74C3C' : '#f4e242' %>;" >>  $1
echo "  }" >>  $1
echo "  .test {" >>  $1
echo "    padding-left: 20px;" >>  $1
echo "  }" >>  $1
echo "  .test-fixed {" >>  $1
echo "    color: #27AE60;" >>  $1
echo "  }" >>  $1
echo "  .test-failed {" >>  $1
echo "    color: #E74C3C;" >>  $1
echo "  }" >>  $1
echo "</STYLE>" >>  $1
echo "<BODY>" >>  $1
echo "  <!-- BUILD RESULT -->" >>  $1
echo "  <table class=\"section\" border=\"1\">" >>  $1
echo "    <tr class=\"tr-title\">" >>  $1
echo "      <td class=\"td-title-main\" colspan=2>" >>  $1
echo "        BUILD \${build.result ?: 'COMPLETED'}" >>  $1
echo "      </td>" >>  $1
echo "    </tr>" >>  $1
echo "    <tr>" >>  $1
echo "      <td>URL:</td>" >>  $1
echo "      <td><A href=\"\${rooturl}\${build.url}\">\${rooturl}\${build.url}</A></td>" >>  $1
echo "    </tr>" >>  $1
echo "    <tr>" >>  $1
echo "      <td>Project:</td>" >>  $1
echo "      <td>\${project.name}</td>" >>  $1
echo "    </tr>" >>  $1
echo "    <tr>" >>  $1
echo "      <td>Date:</td>" >>  $1
echo "      <td>\${it.timestampString}</td>" >>  $1
echo "    </tr>" >>  $1
echo "    <tr>" >>  $1
echo "      <td>Duration:</td>" >>  $1
echo "      <td>\${build.durationString}</td>" >>  $1
echo "    </tr>" >>  $1
#echo "    <tr>" >>  $1
#echo "      <td>Duration of flash:</td>" >>  $1
#echo "      <td>flash_duration</td>" >>  $1
#echo "    </tr>" >>  $1
#echo "<!--" >>  $1
#echo "    <tr>" >>  $1
#echo "      <td>Duration of download:</td>" >>  $1
#echo "      <td>download_duration</td>" >>  $1
#echo "    </tr>" >>  $1
#echo "-->" >>  $1
#echo "    <tr>" >>  $1
#echo "      <td>Duration of test:</td>" >>  $1
#echo "      <td>test_duration</td>" >>  $1
#echo "    </tr>" >>  $1
echo "    <tr>" >>  $1
echo "      <td>Cause:</td>" >>  $1
echo "      <td><% build.causes.each() { cause -> %> \${cause.shortDescription} <%  } %></td>" >>  $1
echo "    </tr>" >>  $1
#echo "    <tr>" >>  $1
#echo "      <td>AOSP URL:</td>" >>  $1
#echo "      <td><A href=\"aosp_url\">aosp_url</A></td>" >>  $1
#echo "    </tr>" >>  $1
#echo "    <tr>" >>  $1
#echo "      <td>BIOS:</td>" >>  $1
#echo "      <td>BIOSVERSION</td>" >>  $1
#echo "    </tr>" >>  $1
echo "  </table>" >>  $1
echo "  <br/>" >>  $1

echo "<!-- TEST RESULTS SUMMARY -->" >>  $1

echo "  <%" >>  $1
echo "  def junitResultList1 = it.JUnitTestResult" >>  $1
echo "  try {" >>  $1
echo "    def cucumberTestResultAction1 = it.getAction(\"org.jenkinsci.plugins.cucumber.jsontestsupport.CucumberTestResultAction\")" >>  $1
echo "    junitResultList1.add( cucumberTestResultAction1.getResult() )" >>  $1
echo "  } catch(e) {" >>  $1
echo "    //cucumberTestResultAction not exist in this build" >>  $1
echo "  }" >>  $1
echo "  if ( junitResultList1.size() > 0 ) { %>" >>  $1
echo "      <table class=\"section\" border=\"1\">" >>  $1
echo "          <tr class=\"tr-title\">" >>  $1
echo "              <td class=\"td-title\" colspan=\"3\">\${junitResultList1.first().displayName} Summary</td>" >>  $1
echo "          </tr>" >>  $1

echo "      <!-- search the module, if find, exclude it in passcount or failcount; else nothing to do  -->" >>  $1
echo "        <%def int log_passcount = 0 " >>  $1
echo "          def int log_failcount = 0" >>  $1
echo "          def junitResultList4 = new ArrayList() " >>  $1
echo "          def excludeList = new ArrayList<String>()" >>  $1
echo "              excludeList.add(\"test_kill_\")" >>  $1
echo "          junitResultList1.each {" >>  $1
echo "              junitResult -> junitResult.getChildren().each {" >>  $1
echo "                  packageResult -> " >>  $1
echo "                  if (packageResult.getName().contains(excludeList[0])){" >>  $1
echo "                      junitResultList4.add(packageResult)" >>  $1
echo "                  }" >>  $1
echo "              } " >>  $1
echo "          }%>" >>  $1


echo "        <%if (junitResultList4.size() > 0) {%>" >>  $1
echo "              <tr>" >>  $1
echo "                  <td class=\"td-title-tests\"> Pass rate:\${Math.round((junitResultList1[0].getPassCount() - junitResultList4[0].getPassCount())/(junitResultList1[0].getTotalCount() - 1)*100)}%</td>" >>  $1
echo "                  <td class=\"td-title-tests\" \${junitResultList1[0].getPassCount() != junitResultList1[0].getTotalCount()?'bgcolor=\"green\"':''}> Pass:\${junitResultList1[0].getPassCount() - junitResultList4[0].getPassCount()}</td>" >>  $1
echo "                  <td class=\"td-title-tests\" \${junitResultList1[0].getFailCount() > 0 ? 'bgcolor=\"red\"':''}> Fail:\${junitResultList1[0].getFailCount() - junitResultList4[0].getFailCount()}</td>" >>  $1
echo "              </tr>" >>  $1
echo "        <%}%>" >>  $1

echo "        <%if (junitResultList4.size() == 0) {%>" >>  $1
echo "              <tr>" >>  $1
echo "                  <td class=\"td-title-tests\"> Pass rate:\${Math.round(junitResultList1[0].getPassCount()/junitResultList1[0].getTotalCount()*100)}%</td>" >>  $1
echo "                  <td class=\"td-title-tests\" \${junitResultList1[0].getPassCount() != junitResultList1[0].getTotalCount()?'bgcolor=\"green\"':''}> Pass:\${junitResultList1[0].getPassCount()}</td>" >>  $1
echo "                  <td class=\"td-title-tests\" \${junitResultList1[0].getFailCount() > 0 ? 'bgcolor=\"red\"':''}> Fail:\${junitResultList1[0].getFailCount()}</td>" >>  $1
echo "              </tr>" >>  $1
echo "        <%}%>" >>  $1
echo "      <!-- END: search the module, if find, exclude it in passcount or failcount; else nothing to do  -->" >>  $1

echo "          <tr>" >>  $1
echo "              <td class=\"td-title-tests\">Component</td>" >>  $1
echo "              <td class=\"td-title-tests\">Items</td>" >>  $1
echo "              <td class=\"td-title-tests\">Result(Pass/Fail)</td>" >>  $1
echo "          </tr>" >>  $1

echo "      <!-- one by one, find module test case number in JunitResult, and merge same component column by case number -->" >>  $1
echo "        <% def int dmcount2 = 0 " >>  $1
echo "           def junitResultList3 = new ArrayList()" >>  $1
echo "           def searchList = new ArrayList<String>()" >>  $1
echo "               searchList.add(\"test_video_\")" >>  $1
echo "               searchList.add(\"test_audio_\")" >>  $1
echo "               searchList.add(\"test_ethernet_\")" >>  $1
echo "               searchList.add(\"test_usb_\")" >>  $1
echo "               searchList.add(\"test_storage_\")" >>  $1
echo "               searchList.add(\"test_IO_\")" >>  $1
echo "               searchList.add(\"test_boot_\")" >>  $1
echo "               searchList.add(\"test_airplane_\")" >>  $1
echo "               searchList.add(\"test_bt_\")" >>  $1
echo "               searchList.add(\"test_wifi_\")" >>  $1
echo "               searchList.add(\"test_browser_\")" >>  $1
echo "               searchList.add(\"test_suspend_resume\")" >>  $1
echo "           def componentList = new ArrayList<String>()" >>  $1
echo "               componentList.add(\"Video\")" >>  $1
echo "               componentList.add(\"Audio\")" >>  $1
echo "               componentList.add(\"Ethernet\")" >>  $1
echo "               componentList.add(\"USB\")" >>  $1
echo "               componentList.add(\"Storage\")" >>  $1
echo "               componentList.add(\"IO\")" >>  $1
echo "               componentList.add(\"Boot\")" >>  $1
echo "               componentList.add(\"Airplane\")" >>  $1
echo "               componentList.add(\"BT\")" >>  $1
echo "               componentList.add(\"Wi-Fi\")" >>  $1
echo "               componentList.add(\"Browser\")" >>  $1
echo "               componentList.add(\"Suspend & Resume\")" >>  $1
echo "           def int j = 0" >>  $1
echo "        %>" >>  $1
echo "    " >>  $1
echo "        <% for(j=0;j<searchList.size();j++ ) { " >>  $1
echo "               dmcount2 = 0 " >>  $1
echo "               junitResultList3.clear()" >>  $1
echo "               junitResultList1.each {" >>  $1
echo "                   junitResult -> junitResult.getChildren().each {" >>  $1
echo "                       packageResult ->" >>  $1
echo "                       if (packageResult.getName().contains(searchList[j]) == true){" >>  $1
echo "                           dmcount2 = dmcount2 + 1" >>  $1
echo "                           junitResultList3.add(packageResult)" >>  $1
echo "                       }" >>  $1
echo "                   } " >>  $1
echo "               }%>" >>  $1
echo "     " >>  $1
echo "               <% for(i=0;dmcount2>=1 &&i!=1;i=1 ) {%> " >>  $1
echo "                      <tr>" >>  $1
echo "                          <td rowspan=<%=dmcount2%> \${junitResultList3[0].getPassCount() == 1 ? '' : 'bgcolor=\"red\"'}><%=componentList[j]%></td>" >>  $1
echo "                          <td \${junitResultList3[0].getPassCount() == 1 ? '' : 'bgcolor=\"red\"'}>\${junitResultList3[0].getName()}</td>" >>  $1
echo "                          <td \${junitResultList3[0].getPassCount() == 1 ? '' : 'bgcolor=\"red\"'}>\${junitResultList3[0].getPassCount() == 1? \"Pass\":\"Fail\"} </td>" >>  $1
echo "                      </tr>" >>  $1
echo "                      <% for (i=1;i < dmcount2;i++){%>" >>  $1
echo "                             <tr>" >>  $1
echo "                                 <td \${junitResultList3[i].getPassCount() == 1 ? '' : 'bgcolor=\"red\"'}>\${junitResultList3[i].getName()}</td>" >>  $1
echo "                                 <td \${junitResultList3[i].getPassCount() == 1 ? '' : 'bgcolor=\"red\"'}>\${junitResultList3[i].getPassCount() == 1? \"Pass\":\"Fail\"} </td>" >>  $1
echo "                             </tr>" >>  $1
echo "                      <%}%>" >>  $1
echo "               <%}%>" >>  $1
echo "        <%}%>" >>  $1
echo "      <!-- END: one by one,find module test case number in JunitResult, and merge same component column by case number -->" >>  $1

echo "      <!-- multi by one, find module test case number in JunitResult, and merge same component column by case number,  -->" >>  $1
echo "        <%def int dmcount1 = 0 " >>  $1
echo "          def junitResultList2 = new ArrayList() " >>  $1
echo "          junitResultList1.each {" >>  $1
echo "              junitResult -> junitResult.getChildren().each {" >>  $1
echo "                  packageResult -> " >>  $1
echo "                  if (packageResult.getName().contains('test_dp_') == true || packageResult.getName().contains('test_display_') == true){" >>  $1
echo "                      dmcount1 = dmcount1 + 1 " >>  $1
echo "                      junitResultList2.add(packageResult)" >>  $1
echo "                  }" >>  $1
echo "              } " >>  $1
echo "          }%>" >>  $1
echo "     " >>  $1
echo "        <% for(i=0;dmcount1>=1 &&i!=1;i=1 ) {%> " >>  $1
echo "               <tr>" >>  $1
echo "                   <td rowspan=<%=dmcount1%> \${junitResultList2[0].getPassCount() == 1 ? '' : 'bgcolor=\"red\"'}>Display</td>" >>  $1
echo "                   <td \${junitResultList2[0].getPassCount() == 1 ? '' : 'bgcolor=\"red\"'}>\${junitResultList2[0].getName()}</td>" >>  $1
echo "                   <td \${junitResultList2[0].getPassCount() == 1 ? '' : 'bgcolor=\"red\"'}>\${junitResultList2[0].getPassCount() == 1? \"Pass\":\"Fail\"} </td>" >>  $1
echo "               </tr>" >>  $1
echo "           <% for (i=1;i < dmcount1;i++){%>" >>  $1
echo "                  <tr>" >>  $1
echo "                      <td \${junitResultList2[i].getPassCount() == 1 ? '' : 'bgcolor=\"red\"'}>\${junitResultList2[i].getName()}</td>" >>  $1
echo "                      <td \${junitResultList2[i].getPassCount() == 1 ? '' : 'bgcolor=\"red\"'}>\${junitResultList2[i].getPassCount() == 1? \"Pass\":\"Fail\"} </td>" >>  $1
echo "                  </tr>" >>  $1
echo "           <% }%>" >>  $1
echo "        <% }%>" >>  $1
echo "      <!-- END: multi by one, search test case number of specified module in JunitResult, and merge same component column by case number,  -->" >>  $1

echo "      <!-- multi by one, find module test case number in JunitResult, and merge same component column by case number,  -->" >>  $1
echo "        <%dmcount1 = 0 " >>  $1
echo "          junitResultList2.clear()" >>  $1
echo "          junitResultList1.each {" >>  $1
echo "              junitResult -> junitResult.getChildren().each {" >>  $1
echo "                  packageResult ->" >>  $1
echo "                  if (packageResult.getName().contains('test_image_') == true || packageResult.getName().contains('test_jpeg_image') == true || packageResult.getName().contains('test_png_image') == true){" >>  $1
echo "                      dmcount1 = dmcount1 + 1 " >>  $1
echo "                      junitResultList2.add(packageResult)" >>  $1
echo "                  }" >>  $1
echo "              }" >>  $1
echo "          }%>" >>  $1
echo "     " >>  $1
echo "        <% for(i=0;dmcount1>=1 &&i!=1;i=1 ) {%> " >>  $1
echo "               <tr>" >>  $1
echo "                   <td rowspan=<%=dmcount1%> \${junitResultList2[0].getPassCount() == 1 ? '' : 'bgcolor=\"red\"'}>Image</td>" >>  $1
echo "                   <td \${junitResultList2[0].getPassCount() == 1 ? '' : 'bgcolor=\"red\"'}>\${junitResultList2[0].getName()}</td>" >>  $1
echo "                   <td \${junitResultList2[0].getPassCount() == 1 ? '' : 'bgcolor=\"red\"'}>\${junitResultList2[0].getPassCount() == 1? \"Pass\":\"Fail\"} </td>" >>  $1
echo "               </tr>" >>  $1
echo "               <% for (i=1;i < dmcount1;i++){%>" >>  $1
echo "                      <tr>" >>  $1
echo "                          <td \${junitResultList2[i].getPassCount() == 1 ? '' : 'bgcolor=\"red\"'}>\${junitResultList2[i].getName()}</td>" >>  $1
echo "                          <td \${junitResultList2[i].getPassCount() == 1 ? '' : 'bgcolor=\"red\"'}>\${junitResultList2[i].getPassCount() == 1? \"Pass\":\"Fail\"} </td>" >>  $1
echo "                      </tr>" >>  $1
echo "               <%}%>" >>  $1
echo "        <%}%>" >>  $1
echo "      <!-- END: multi by one, find module test case number in JunitResult, and merge same component column by case number,  -->" >>  $1


echo "  </table>" >>  $1
echo "  <br/>" >>  $1
echo "  <% } %>" >>  $1


echo "<!-- JUnit TEMPLATE -->" >>  $1

echo "  <%" >>  $1
echo "  def junitResultList = it.JUnitTestResult" >>  $1
echo "  try {" >>  $1
echo "    def cucumberTestResultAction = it.getAction(\"org.jenkinsci.plugins.cucumber.jsontestsupport.CucumberTestResultAction\")" >>  $1
echo "    junitResultList.add( cucumberTestResultAction.getResult() )" >>  $1
echo "  } catch(e) {" >>  $1
echo "    //cucumberTestResultAction not exist in this build" >>  $1
echo "  }" >>  $1
echo "  if ( junitResultList.size() > 0 ) { %>" >>  $1
echo "  <table class=\"section\" border=\"1\">" >>  $1
echo "    <tr class=\"tr-title\">" >>  $1
echo "      <td class=\"td-title\" colspan=\"5\">\${junitResultList.first().displayName}</td>" >>  $1
echo "    </tr>" >>  $1
echo "    <tr>" >>  $1
echo "        <td class=\"td-title-tests\">Name</td>" >>  $1
echo "        <td class=\"td-title-tests\">Failed</td>" >>  $1
echo "        <td class=\"td-title-tests\">Passed</td>" >>  $1
echo "        <td class=\"td-title-tests\">Skipped</td>" >>  $1
echo "        <td class=\"td-title-tests\">Total</td>" >>  $1
echo "      </tr>" >>  $1
echo "    <% junitResultList.each {" >>  $1
echo "      junitResult -> junitResult.getChildren().each {" >>  $1
echo "        packageResult -> %>" >>  $1
echo "    <tr>" >>  $1
echo "      <td>\${packageResult.getName()}</td>" >>  $1
echo "      <td>\${packageResult.getFailCount()}</td>" >>  $1
echo "      <td>\${packageResult.getPassCount()}</td>" >>  $1
echo "      <td>\${packageResult.getSkipCount()}</td>" >>  $1
echo "      <td>\${packageResult.getPassCount() + packageResult.getFailCount() + packageResult.getSkipCount()}</td>" >>  $1
echo "    </tr>" >>  $1
echo "    <% packageResult.getPassedTests().findAll({it.getStatus().toString() == \"FIXED\";}).each{" >>  $1
echo "        test -> %>" >>  $1
echo "            <tr>" >>  $1
echo "              <td class=\"test test-fixed\" colspan=\"5\">" >>  $1
echo "                \${test.getFullName()} \${test.getStatus()}" >>  $1
echo "              </td>" >>  $1
echo "            </tr>" >>  $1
echo "        <% } %>" >>  $1
echo "        <% packageResult.getFailedTests().sort({a,b -> a.getAge() <=> b.getAge()}).each{" >>  $1
echo "          failed_test -> %>" >>  $1
echo "    <tr>" >>  $1
echo "      <td class=\"test test-failed\" colspan=\"5\">" >>  $1
echo "        \${failed_test.getFullName()} (Age: \${failed_test.getAge()})" >>  $1
echo "      </td>" >>  $1
echo "    </tr>" >>  $1
echo "        <% }" >>  $1
echo "      }" >>  $1
echo "    } %>" >>  $1
echo "  </table>" >>  $1
echo "  <br/>" >>  $1
echo "  <% } %>" >>  $1

echo "  <!-- CHANGE SET -->" >>  $1
echo "  <%" >>  $1
echo "  def changeSets = build.changeSets" >>  $1
echo "  if(changeSets != null) {" >>  $1
echo "    def hadChanges = false %>" >>  $1
echo "  <table class=\"section\">" >>  $1
echo "    <tr class=\"tr-title\">" >>  $1
echo "      <td class=\"td-title\" colspan=\"2\">CHANGES</td>" >>  $1
echo "    </tr>" >>  $1
echo "    <% changeSets.each() { " >>  $1
echo "      cs_list -> cs_list.each() { " >>  $1
echo "        cs -> hadChanges = true %>" >>  $1
echo "    <tr>" >>  $1
echo "      <td>" >>  $1
echo "        Revision" >>  $1
echo "        <%= cs.metaClass.hasProperty('commitId') ? cs.commitId : cs.metaClass.hasProperty('revision') ? cs.revision : cs.metaClass.hasProperty('changeNumber') ? cs.changeNumber : \"\" %>" >>  $1
echo "        by <B><%= cs.author %></B>" >>  $1
echo "      </td>" >>  $1
echo "      <td>\${cs.msgAnnotated}</td>" >>  $1
echo "    </tr>" >>  $1
echo "        <% cs.affectedFiles.each() {" >>  $1
echo "          p -> %>" >>  $1
echo "    <tr>" >>  $1
echo "      <td class=\"filesChanged\">\${p.editType.name}</td>" >>  $1
echo "      <td>\${p.path}</td>" >>  $1
echo "    </tr>" >>  $1
echo "        <% }" >>  $1
echo "      }" >>  $1
echo "    }" >>  $1
echo "    if ( !hadChanges ) { %>" >>  $1
echo "    <tr>" >>  $1
echo "      <td colspan=\"2\">No Changes</td>" >>  $1
echo "    </tr>" >>  $1
echo "    <% } %>" >>  $1
echo "  </table>" >>  $1
echo "  <br/>" >>  $1
echo "  <% } %>" >>  $1

echo "<!-- ARTIFACTS -->" >>  $1
echo "  <% " >>  $1
echo "  def artifacts = build.artifacts" >>  $1
echo "  if ( artifacts != null && artifacts.size() > 0 ) { %>" >>  $1
echo "  <table class=\"section\">" >>  $1
echo "    <tr class=\"tr-title\">" >>  $1
echo "      <td class=\"td-title\">BUILD ARTIFACTS</td>" >>  $1
echo "    </tr>" >>  $1
echo "    <% artifacts.each() {" >>  $1
echo "      f -> %>" >>  $1
echo "      <tr>" >>  $1
echo "        <td>" >>  $1
echo "          <a href=\"\${rooturl}\${build.url}artifact/\${f}\">\${f}</a>" >>  $1
echo "      </td>" >>  $1
echo "    </tr>" >>  $1
echo "    <% } %>" >>  $1
echo "  </table>" >>  $1
echo "  <br/>" >>  $1
echo "  <% } %>" >>  $1

echo "<!-- MAVEN ARTIFACTS -->" >>  $1
echo "  <%" >>  $1
echo "  try {" >>  $1
echo "    def mbuilds = build.moduleBuilds" >>  $1
echo "    if ( mbuilds != null ) { %>" >>  $1
echo "  <table class=\"section\">" >>  $1
echo "    <tr class=\"tr-title\">" >>  $1
echo "      <td class=\"td-title\">BUILD ARTIFACTS</td>" >>  $1
echo "    </tr>" >>  $1
echo "      <%" >>  $1
echo "      try {" >>  $1
echo "        mbuilds.each() {" >>  $1
echo "          m -> %>" >>  $1
echo "    <tr>" >>  $1
echo "      <td class=\"td-header-maven-module\">\${m.key.displayName}</td>" >>  $1
echo "    </tr>" >>  $1
echo "          <%" >>  $1
echo "          m.value.each() { " >>  $1
echo "            mvnbld -> def artifactz = mvnbld.artifacts" >>  $1
echo "            if ( artifactz != null && artifactz.size() > 0) { %>" >>  $1
echo "    <tr>" >>  $1
echo "      <td class=\"td-maven-artifact\">" >>  $1
echo "              <% artifactz.each() {" >>  $1
echo "                f -> %>" >>  $1
echo "        <a href=\"\${rooturl}\${mvnbld.url}artifact/\${f}\">\${f}</a><br/>" >>  $1
echo "              <% } %>" >>  $1
echo "      </td>" >>  $1
echo "    </tr>" >>  $1
echo "            <% }" >>  $1
echo "          }" >>  $1
echo "        }" >>  $1
echo "      } catch(e) {" >>  $1
echo "        // we don't do anything" >>  $1
echo "      } %>" >>  $1
echo "  </table>" >>  $1
echo "  <br/>" >>  $1
echo "    <% }" >>  $1
echo "  } catch(e) {" >>  $1
echo "    // we don't do anything" >>  $1
echo "  } %>" >>  $1

echo "<!-- CONSOLE OUTPUT -->" >>  $1
echo "  <%" >>  $1
echo "  if ( build.result == hudson.model.Result.FAILURE ) { %>" >>  $1
echo "  <table class=\"section\" cellpadding=\"0\" cellspacing=\"0\">" >>  $1
echo "    <tr class=\"tr-title\">" >>  $1
echo "      <td class=\"td-title\">CONSOLE OUTPUT</td>" >>  $1
echo "    </tr>" >>  $1
echo "    <% 	build.getLog(100).each() {" >>  $1
echo "      line -> %>" >>  $1
echo "	  <tr>" >>  $1
echo "      <td class=\"console\">\${org.apache.commons.lang.StringEscapeUtils.escapeHtml(line)}</td>" >>  $1
echo "    </tr>" >>  $1
echo "    <% } %>" >>  $1
echo "  </table>" >>  $1
echo "  <br/>" >>  $1
echo "  <% } %>" >>  $1
echo "</BODY>" >>  $1

    endtime=$(date +%s);
    echo -e "##############################"
    time_elapsed $starttime $endtime
    echo -e "##############################\n\n"
}

function make_no_new_dailybuild_email_template(){
    #####$1: ${WORKSPACE}
    #####$2: $final_template
    #####$3: miss_template_file_name, such as "missing_style.template"
    #####$4: $detail_info
    #####$5: $exception_reason
    local_workspace=$1
    local_final_template=$2
    local_miss_template_file_name=$3
    local_detail_info=$4
    local_exception_reason=$5
    echo -e "##############################"
    echo -e "##### make_no_new_dailybuild_email_template"
    echo -e "###############################"
    enter_directory "${WORKSPACE}"
    echo -e "$@"
    starttime=$(date +%s);

    cat dailybuild_url.txt
    AOSP_URL=`cat dailybuild_url.txt`
    if [[ -z $AOSP_URL ]];then
        AOSP_URL=unknown
        echo -e "AOSP_URL is empty"
    else
        echo -e "AOSP_URL=$AOSP_URL"
    fi

        ##### build status
        create_exception_email_template $local_final_template
        cat $local_final_template
        ##### build info, such as: AOSP URL
        create_no_new_dailybuild_exception_build_info_email_template $local_detail_info
        cat $local_detail_info
        ##### exception info
        create_exception_reason_info_email_template $local_miss_template_file_name
        cat $local_miss_template_file_name
    pwd
        ##### build info
        sed -e "s/aosp_url/$AOSP_URL/g" -i $local_detail_info
        sed -e "s/expecteddate/$expected_dailybuild_date/g" -i $local_detail_info
        cat $local_detail_info | grep -i date
        ##### Failure info
        sed -e "/html/d" -i  $local_miss_template_file_name
        cat $local_miss_template_file_name | grep -i html
        cp -rf "$local_exception_reason".bak  $local_exception_reason
        #####insert below linenumber, $3= linenumber-1
        merge_style_into_missing_template $local_miss_template_file_name  $local_exception_reason 1
        sed -e "s/Missing images/Not found new Dailybuild with $expected_dailybuild_date/g" -i $local_exception_reason
        cat $local_exception_reason | grep -i "Failure reason"

    endtime=$(date +%s);
    echo -e "##############################"
    time_elapsed $starttime $endtime
    echo -e "##############################\n\n"
}

function make_email_template(){
    #####$1: ${WORKSPACE}
    #####$2: $final_template
    #####$3: $is_download
    #####$4: $target_is_reachable_before_flash
    #####$5: $target_is_reachable_after_flash
    #####$6: miss_template_file_name, such as "missing_style.template"
    #####$7: $detail_info
    #####$8: $background_color
    #####$9: $exception_reason
    local_workspace=$1
    local_final_template=$2
    local_is_download=$3
    local_target_is_reachable_before_flash=$4
    local_target_is_reachable_after_flash=$5
    local_miss_template_file_name=$6
    local_detail_info=$7
    local_background_color=$8
    local_exception_reason=$9
    echo -e "##############################"
    echo -e "##### make email template"
    echo -e "###############################"
    enter_directory "${WORKSPACE}"
    echo -e "$@"
    starttime=$(date +%s);

    cat dailybuild_url.txt
    AOSP_URL=`cat dailybuild_url.txt`
    if [[ -z $AOSP_URL ]];then
        AOSP_URL=unknown
        echo -e "AOSP_URL is empty"
    else
        echo -e "AOSP_URL=$AOSP_URL"
    fi

    if [[ $local_is_download == true ]] && [[ $local_target_is_reachable_before_flash == true ]] && [[ $local_target_is_reachable_after_flash == true ]]; then
        cat dmesg.txt |grep -i "DMI.*bios"
        #2 1
        BIOS_VERSION=`cat dmesg.txt |grep -i "DMI.*bios" | awk -F "BIOS" '{print $2}' | awk -F " " '{print $1}'`
        echo -e "BIOS_VERSION=$BIOS_VERSION"
        if [[ -z $BIOS_VERSION ]];then
            BIOS_VERSION=unknown
            echo -e "BIOS_VERSION is empty"
        else
            echo -e "BIOS_VERSION=$BIOS_VERSION"
        fi

        cat download_duration.txt
        DOWNLOAD_DURATION=`cat download_duration.txt`
        if [[ -z $DOWNLOAD_DURATION ]];then
            DOWNLOAD_DURATION=unknown
            echo -e "DOWNLOAD_DURATION is empty"
        else
            echo -e "DOWNLOAD_DURATION=$DOWNLOAD_DURATION"
        fi

        cat flash_duration.txt
        FLASH_DURATION=`cat flash_duration.txt`
        if [[ -z $FLASH_DURATION ]];then
            FLASH_DURATION=unknown
            echo -e "FLASH_DURATION= is empty"
        else
            echo -e "FLASH_DURATION=$FLASH_DURATION"
        fi

        cat automation_duration.txt
        AUTOMATION_DURATION=`cat automation_duration.txt`
        if [[ -z $AUTOMATION_DURATION ]];then
            AUTOMATION_DURATION=unknown
            echo -e "AUTOMATION_DURATION is empty"
        else
            echo -e "AUTOMATION_DURATION=$AUTOMATION_DURATION"
        fi
    fi

    if [[ $local_is_download == true ]] && [[ $local_target_is_reachable_before_flash == true ]] && [[ $local_target_is_reachable_after_flash == true ]]; then
        ##### build status/test result
        create_normal_email_template $local_final_template
        ##### build info, such as: BIOS/AOSP URL/DURATION
        create_normal_build_info_email_template $local_detail_info
        ##### exception info
        create_normal_exception_reason_info_email_template $local_exception_reason
    else
        ##### build status
        create_exception_email_template $local_final_template
        cat $local_final_template
        ##### build info, such as: AOSP URL
        create_exception_build_info_email_template $local_detail_info
        cat $local_detail_info
        ##### exception info
        create_exception_reason_info_email_template $local_miss_template_file_name
        cat $local_miss_template_file_name
    fi
    pwd
    if [[ $local_is_download == true ]] && [[ $local_target_is_reachable_before_flash == true ]] && [[ $local_target_is_reachable_after_flash == true ]]; then
        ##### build info
        sed -e "s/BIOSVERSION/$BIOS_VERSION/" -i $local_detail_info
        sed -e "s/aosp_url/$AOSP_URL/g" -i $local_detail_info
        sed -e "s/download_duration/$DOWNLOAD_DURATION/g" -i $local_detail_info
        sed -e "s/flash_duration/$FLASH_DURATION/g" -i $local_detail_info
        sed -e "s/test_duration/$AUTOMATION_DURATION/g" -i $local_detail_info
        sed -e "s/background-color:\ #27AE60/background-color:\ $local_background_color/g" -i $local_detail_info
        cat $local_detail_info | grep -i "http"
        cat $local_detail_info | grep -i "bios" -A 1
        cat $local_detail_info | grep -i "duration" -A 1
        cat $local_detail_info | grep -i "background-color" -A 1
    elif [[ $local_is_download == false ]]; then
        ##### build info
        echo "AOSP_URL=$AOSP_URL"
        sed -e "s/aosp_url/$AOSP_URL/g" -i $local_detail_info
        cat $local_detail_info | grep -i "http"
        ##### Failure info
        sed -e "/html/d" -i  $local_miss_template_file_name
        cat $local_miss_template_file_name | grep -i html
        cp -rf "$local_exception_reason".bak  $local_exception_reason
        #####insert below linenumber, $3= linenumber-1
        merge_style_into_missing_template $local_miss_template_file_name  $local_exception_reason 1
        cat $local_exception_reason | grep -i "Failure reason"
    elif [[ $local_target_is_reachable_before_flash == false ]]; then
        ##### build info
        sed -e "s/aosp_url/$AOSP_URL/g" -i $local_detail_info
        cat $local_detail_info | grep -i "http"
        ##### Failure info
        sed -e "s/Failure reason.*/Failure reason: Target is not reachable before flashing AOSP images/g" -i $local_miss_template_file_name
        cp -rf $local_miss_template_file_name $local_exception_reason
        cat $local_exception_reason | grep -i "Failure reason"
    elif [[ $local_target_is_reachable_after_flash == false ]]; then
        ##### build info
        #cat dmesg_before_flash.txt |grep -i "DMI.*bios"
        #2 1
        #BIOS_VERSION=`cat dmesg_before_flash.txt |grep -i "DMI.*bios" | awk -F "BIOS" '{print $2}' | awk -F " " '{print $1}'`
        #echo -e "BIOS_VERSION=$BIOS_VERSION"
        #if [[ -z $BIOS_VERSION ]];then
        #    BIOS_VERSION=unknown
        #    echo -e "BIOS_VERSION is empty"
        #else
        #    echo -e "BIOS_VERSION=$BIOS_VERSION"
        #fi
        #sed -e "/bios_flag/d" -i $local_detail_info
        #sed -e "s/BIOSVERSION/$BIOS_VERSION/" -i $local_detail_info
        sed -e "s/aosp_url/$AOSP_URL/g" -i $local_detail_info
        cat $local_detail_info | grep -i "http"
        ##### Failure info
        sed -e "s/Failure reason.*/Failure reason: Target is not reachable after flashing AOSP images/g" -i $local_miss_template_file_name
        cp -rf $local_miss_template_file_name  $local_exception_reason
        cat $local_exception_reason | grep -i "Failure reason"
    fi

    endtime=$(date +%s);
    echo -e "##############################"
    time_elapsed $starttime $endtime
    echo -e "##############################\n\n"
}

function stay_awake_set_date_time(){
    #####$1: $target_ip
    echo -e "##############################"
    echo -e "##### stay awake and set date time"
    echo -e "###############################"
    starttime=$(date +%s);
    IP_ADDRESS=$1
    adb devices
    adb shell settings get global stay_on_while_plugged_in
    adb shell settings put global stay_on_while_plugged_in 7
    adb shell settings get global stay_on_while_plugged_in
    adb connect $IP_ADDRESS
    adb root
    adb connect $IP_ADDRESS
    adb shell date -rd `date "+%m%d%H%M%Y"`
    endtime=$(date +%s);
    echo -e "##############################"
    time_elapsed $starttime $endtime
    echo -e "##############################\n\n"
}

function automation_test(){
    #####$1 "$test_framework_path"
    #####$2 "${target_ip}"
    #####$3 "$automation_test_type"
    echo -e "##############################"
    echo -e "##### automation test"
    echo -e "###############################"
    pwd
    starttime=$(date +%s);
    cd "$1"
    ls -l "$1"/test_runner/raven_conf.yaml_bak
    if [[ ! -f "$1"/test_runner/raven_conf.yaml_bak ]]; then
        cp -rf "$1"/test_runner/raven_conf.yaml  "$1"/test_runner/raven_conf.yaml_bak
    fi
    ls -l "$1"/test_runner/raven_conf.yaml_bak

    ls -l "$1"/tests/"$3"_suite.txt_bak
    if [[ ! -f "$1"/tests/"$3"_suite.txt_bak ]]; then
        cp -rf "$1"/tests/"$3"_suite.txt  "$1"/tests/"$3"_suite.txt_bak
    fi
    ls -l "$1"/tests/"$3"_suite.txt_bak

    cp -rf "$1"/tests/"$3"_suite.txt_bak "$1"/tests/"$3"_suite.txt
 
    #if [[ $git_branch == "atg-npi-dev-p" ]]; then
    #        sed -e "/test_dp/d" -i  tests/"$3"_suite.txt
    #        sed -e "/test_usb_mouse/d" -i  tests/"$3"_suite.txt
    #        cat tests/"$3"_suite.txt
    #fi
    #usb_keyboard=`cat "$1"/tests/"$3"_suite.txt | grep -i "test_usb_keyboard"`
    #usb_mouse=`cat "$1"/tests/"$3"_suite.txt | grep -i "test_usb_mouse"`
    usb_keyboard_at_beginning_of_list=`cat "$1"/tests/"$3"_suite.txt | grep "test_ethernet_connection.py" -A 2 | grep -i "test_usb_keyboard"`
    usb_mouse_at_beginning_of_list=`cat "$1"/tests/"$3"_suite.txt | grep "test_ethernet_connection.py" -A 2 | grep -i "test_usb_mouse"`
    if [[ -z $usb_keyboard_at_beginning_of_list ]]; then
        echo "usb_keyboard is not at beginning of $1/tests/${3}_suite.txt"
        usb_keyboard=`cat "$1"/tests/"$3"_suite.txt | grep -i "test_usb_keyboard"`
        if [[ ! -z $usb_keyboard ]]; then
            sed -e "/test_usb_keyboard/d" -i "$1"/tests/"$3"_suite.txt
            sed -e "/test_ethernet_connection/a\ tests\/test_usb_keyboard.py" -i "$1"/tests/"$3"_suite.txt
        fi
    fi
    if [[ -z $usb_mouse_at_beginning_of_list ]]; then
        echo "usb_mouse is not at beginning of $1/tests/${3}_suite.txt"
        usb_mouse=`cat "$1"/tests/"$3"_suite.txt | grep -i "test_usb_mouse"`
        if [[ ! -z $usb_mouse ]]; then
            sed -e "/test_usb_mouse/d" -i "$1"/tests/"$3"_suite.txt
            sed -e "/test_ethernet_connection/a\ tests\/test_usb_mouse.py" -i "$1"/tests/"$3"_suite.txt
        fi
    fi
    cat "$1"/tests/"$3"_suite.txt
    
    ethernet_exist=`cat "$1"/test_runner/runner.py | grep -i ethernet`
    echo "ethernet_exist=$ethernet_exist"
    sleep 120
    if [[ -z $ethernet_exist ]]; then
        cp -f test_runner/raven_conf.yaml_bak test_runner/raven_conf.yaml
        sed -e "s/ethernet_ip.*$/ethernet_ip: $2,/" -i test_runner/raven_conf.yaml
        python3 runner.py test_runner/project_properties.py --$3
    else
        python3 runner.py test_runner/project_properties.py --$3 "$2"
    fi
    adb shell settings get global stay_on_while_plugged_in
    endtime=$(date +%s);
    echo -e "##############################"
    time_elapsed $starttime $endtime
    flash_time_elapsed $starttime $endtime  "automation_duration"
    echo -e "##############################\n\n"
    pwd
    if [[ "$WORKSPACE" != "`pwd`" ]]; then
       cd "$WORKSPACE"
    fi
    pwd
}

function archive_result(){
    #####$1  $WORKSPACE
    #####$2  $test_framework_path
    #####$3  $xml_path
    echo $WORKSPACE
    echo $PATH
    echo -e "##############################"
    echo -e "##### archive result"
    echo -e "###############################"
    starttime=$(date +%s);


    rm -rf "$1/$3"
    rm -rf "$1/${3}_adb_logs"
    rm -rf "$1/${3}_logs"
    echo "\$1=$1"
    echo "\$2=$2"
    echo "\$3=$3"
    cd $2
    pwd
    cp -rf tests/reports/xml_results "$1/$3"
    cp -rf tests/reports/adb_logs   "$1/${3}_adb_logs"
    cp -rf tests/reports/logs   "$1/${3}_logs"
    endtime=$(date +%s);
    echo -e "##############################"
    time_elapsed $starttime $endtime
    echo -e "##############################\n\n"
    enter_directory "$1"
}

function check_test_results(){
   #####$1 ${WORKSPACE}
   #####$2 $xml_path
   echo -e "##############################"
   echo -e "##### check_test_results"
   echo -e "###############################"
   starttime=$(date +%s);
   enter_directory "$1"
   total_count=`ls $2 | wc -l`
   echo -e "total_count=$total_count"
   total_count=$[$total_count-1]
   echo -e "total_count=$total_count"
   total_fail_count=0
   kill_fail_count=0
   for a in `ls $2`;
   do
       failure_exist=
       #echo -e "failure_exist=[$failure_exist]"
       failure_exist=`grep -nr "failures=\"1\"" $2/$a`
       #echo -e "failure_exist=[$failure_exist]"
       if [[ ! -z $failure_exist ]];then
           echo -e "failure_exist=[$failure_exist]"
           let total_fail_count+=1
       fi
   done
   for a in `ls $2/*kill*`;
   do
       kill_failure=`grep -nr "failures=\"1\"" $a`
       echo -e "kill_failure=[$kill_failure]"
       if [[ ! -z $kill_failure ]];then
           let kill_fail_count+=1
       fi
   done
   echo -e "total_fail_count=$total_fail_count, kill_fail_count=$kill_fail_count"
   total_fail_count=$[$total_fail_count-$kill_fail_count];
   echo -e "total_fail_count=[$total_fail_count]"
   if [[ $total_fail_count -eq $total_count ]]; then
      echo -e "Build Failure"
      background_color="#E74C3C"
   elif [[ $total_count -gt $total_fail_count ]] && [[ $total_fail_count -eq 0 ]]; then
      echo -e "Build Success"
      background_color="#27AE60"
   else
      echo -e "Build Unstable"
      background_color="#f4e242"
   fi
   endtime=$(date +%s);
   echo -e "##############################"
   time_elapsed $starttime $endtime
   echo -e "##############################\n\n"
}

function valid_ip()
{
    #####$1 "${target_ip}"
    echo -e "##############################"
    echo -e "##### valid_ip $1"
    echo -e "###############################"
    starttime=$(date +%s);
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    endtime=$(date +%s);
    echo -e "##############################"
    time_elapsed $starttime $endtime
    echo -e "##############################\n\n"
    return $stat
}

function ping_target(){
    #####$1 "${target_ip}"
    echo "################################"
    echo "Looking for target device ip:$target_ip n/w"
    echo "################################"
    starttime=$(date +%s);
    ping -c 4  $target_ip
    if [ "$?" -eq 0 ]; then
        echo "#####################"
        echo "Target detected"
        echo "#####################"
        ping_reachable=true
    else
        echo "###################################"
        echo "Target device not found in network"
        echo "###################################"
        ping_reachable=false
        #endtime=$(date +%s);
        #echo -e "##############################"
        #time_elapsed $starttime $endtime
        #echo -e "##############################\n\n"
        #exit 0
    fi
    echo "ping_reachable=$ping_reachable"
    endtime=$(date +%s);
    echo -e "##############################"
    time_elapsed $starttime $endtime
    echo -e "##############################\n\n"
}


function adb_reboot_bootloader(){
    #####$1 "${target_ip}"
    echo -e "##############################"
    echo -e "##### adb_reboot_bootloader"
    echo -e "###############################"
    starttime=$(date +%s);
    SLEEP_TIME_AFTER_BOOTLOADER=100
    adb connect $1
    adb reboot bootloader
    sleep $SLEEP_TIME_AFTER_BOOTLOADER
    endtime=$(date +%s);
    echo -e "##############################"
    time_elapsed $starttime $endtime
    echo -e "##############################\n\n"
}

function flash_AOSP_images(){
    ##### $1 target ip
    ##### $2 Android version
    ##### $3 slot a/b/all/none
    echo -e "##############################"
    echo -e "##### flash_AOSP_images"
    echo -e "###############################"
    pwd
    if [[ "$WORKSPACE" != "`pwd`" ]]; then
       cd "$WORKSPACE"
    fi
    pwd
    #starttime=$(date +%s);
    IP_ADDRESS=$1
    ANDROID_VER=$2
    SELECTED_SLOT=$3

    if [ -f "$WORKSPACE"/fastboot ]; then
        fastboot_bin="$WORKSPACE"/fastboot
        echo "fastboot bin found at $fastboot_bin"
    else
        fastboot_bin=`which fastboot`
        if [ -z "$fastboot_bin" ]; then
            echo "fastboot bin not found "
            exit -1
        fi
    fi
    echo "fastboot_bin=$fastboot_bin"
    adb_reboot_bootloader $IP_ADDRESS
    ##### check whether board enter fastmode.
    ##### 1, ping $IP
    ##### 2, $fastboot_bin -s tcp:$IP_ADDRESS getvar version
    ##### check_fastmode $IP_ADDRESS $fastboot_bin
    echo "Now flash gpt partition and ip:$IP_ADDRESS"
    "$fastboot_bin" -s tcp:$IP_ADDRESS flash gpt gpt.bin
    "$fastboot_bin" -s tcp:$IP_ADDRESS reboot bootloader
    echo "GPT partition table has been written and rebooting target!"
    echo "Stay put..."
    sleep 30


    starttime=$(date +%s);
    echo "##########################"
    echo "Flashing target partitions"
    echo "##########################"

    if [[ $ANDROID_VER == "Pie" ]]; then
        if [[ ! -z "$SELECTED_SLOT" ]]; then
            "$fastboot_bin" -s tcp:$IP_ADDRESS flash misc misc.img
            if [[ $SELECTED_SLOT == "SLOT_A" ]] || [[ $SELECTED_SLOT == "SLOT_ALL" ]]; then
                echo "Flashing slot suffix _a partitions"
                "$fastboot_bin" -s tcp:$IP_ADDRESS flash boot_a  boot.img
                "$fastboot_bin" -s tcp:$IP_ADDRESS flash vbmeta_a  vbmeta.img
                "$fastboot_bin" -s tcp:$IP_ADDRESS flash vendor_a  vendor.img
                "$fastboot_bin" -s tcp:$IP_ADDRESS flash system_a  system.img
            fi

            if [[ $SELECTED_SLOT == "SLOT_B" ]] || [[ $SELECTED_SLOT == "SLOT_ALL" ]]; then
                echo "Flashing slot suffix _b partitions"
                "$fastboot_bin" -s tcp:$IP_ADDRESS flash boot_b  boot.img
                "$fastboot_bin" -s tcp:$IP_ADDRESS flash vbmeta_b  vbmeta.img
                "$fastboot_bin" -s tcp:$IP_ADDRESS flash vendor_b  vendor.img
                "$fastboot_bin" -s tcp:$IP_ADDRESS flash system_b  system.img
            fi
        else
            echo "Disable AVB,only flash boot/cache/vendor/system/userdata"
            "$fastboot_bin" -s tcp:$IP_ADDRESS flash boot  boot.img
            "$fastboot_bin" -s tcp:$IP_ADDRESS flash cache  cache.img
            "$fastboot_bin" -s tcp:$IP_ADDRESS flash vendor  vendor.img
            "$fastboot_bin" -s tcp:$IP_ADDRESS flash system  system.img
        fi
    elif [[ $ANDROID_VER == "N" ]]; then
        "$fastboot_bin" -s tcp:$IP_ADDRESS flash boot  boot.img
        "$fastboot_bin" -s tcp:$IP_ADDRESS flash cache  cache.img
        "$fastboot_bin" -s tcp:$IP_ADDRESS flash system  system.img
    fi
    "$fastboot_bin" -s tcp:$IP_ADDRESS flash data  userdata.img
    "$fastboot_bin" -s tcp:$IP_ADDRESS reboot

    endtime=$(date +%s);
    echo -e "##############################"
    time_elapsed $starttime $endtime
    flash_time_elapsed $starttime $endtime  "flash_duration"
    echo -e "##############################\n\n"
}

function flash_images(){
    #####$1 "$android_version"
    #####$2 "$target_ip"
    #####$3 "$enable_slot_ab"
    #####$4 "$flash_script" or None
    echo -e "##############################"
    echo -e "##### flash_images"
    echo -e "###############################"
    pwd
    if [[ "$WORKSPACE" != "`pwd`" ]]; then
       cd "$WORKSPACE"
    fi
    pwd
    starttime=$(date +%s);
    if [[ -z $4 ]]; then
    DEFAULT_FLASH_SCRIPT=flash_AOSP_images
    fi
    if [[ $1 == [Nn]* ]]; then
        echo "Android N, only flash boot/cache/userdata/system"
        if [[ $3 == none ]]; then
            adb reboot
        else
            if [[ ! -z $4 ]]; then
                $4 -i "$2" -v N -o "${WORKSPACE}" -f "${WORKSPACE}"
            else
                $DEFAULT_FLASH_SCRIPT  "$2" "N"
            fi
        fi
    fi
    if [[ $1 == [Pp]* ]]; then
        if [[ $3 == false ]]; then
            echo "Android P disable A/B partition, only flash boot/cache/userdata/vendor/system"
            if [[ ! -z $4 ]]; then
                $4 -i "$2" -v Pie -o "${WORKSPACE}" -f "${WORKSPACE}"
            else
                $DEFAULT_FLASH_SCRIPT  "$2" "Pie"
            fi
        fi
        if [[ $3 == true ]]; then
            echo "Android P enable A/B partition, only flash boot/userdata/vendor/misc/vbmeta/system"
            if [[ $slot_ab == a ]]; then
                if [[ ! -z $4 ]]; then
                    $4 -i "$2" -v Pie -o "${WORKSPACE}" -f "${WORKSPACE}" -s a
                else
                    $DEFAULT_FLASH_SCRIPT  "$2" "Pie" "SLOT_A"
                fi
            elif [[ $slot_ab == b ]]; then
                if [[ ! -z $4 ]]; then
                    $4 -i "$2" -v Pie -o "${WORKSPACE}" -f "${WORKSPACE}" -s b
                else
                    $DEFAULT_FLASH_SCRIPT  "$2" "Pie" "SLOT_B"
                fi
            elif [[ $slot_ab == all ]] || [[ -z $slot_ab ]]; then
                if [[ ! -z $4 ]]; then
                    $4 -i "$2" -v Pie -o "${WORKSPACE}" -f "${WORKSPACE}" -s all
                else
                    $DEFAULT_FLASH_SCRIPT  "$2" "Pie" "SLOT_ALL"
                fi
            elif [[ $slot_ab == none ]]; then
                    adb reboot
            fi
        fi
    fi
    endtime=$(date +%s);
    echo -e "##############################"
    time_elapsed $starttime $endtime
    echo -e "##############################\n\n"
}

function make_parameter_not_enough_template(){
    echo -e "##############################"
    echo -e "##### flash_images"
    echo -e "###############################"
    pwd
    if [[ "$WORKSPACE" != "`pwd`" ]]; then
       cd "$WORKSPACE"
    fi
    pwd
    starttime=$(date +%s);

echo "<STYLE>" >  $1
echo "  BODY, TABLE, TD, TH, P {" >>  $1
echo "    font-family: Calibri, Verdana, Helvetica, sans serif;" >>  $1
echo "    font-size: 12px;" >>  $1
echo "    color: black;" >>  $1
echo "  }" >>  $1
echo "  .console {" >>  $1
echo "    font-family: Courier New;" >>  $1
echo "  }" >>  $1
echo "  .filesChanged {" >>  $1
echo "    width: 10%;" >>  $1
echo "    padding-left: 10px;" >>  $1
echo "  }" >>  $1
echo "  .section {" >>  $1
echo "    width: 100%;" >>  $1
echo "    border: thin black dotted;" >>  $1
echo "  }" >>  $1
echo "  .td-title-main {" >>  $1
echo "    color: white;" >>  $1
echo "    font-size: 200%;" >>  $1
echo "    padding-left: 5px;" >>  $1
echo "    font-weight: bold;" >>  $1
echo "  }" >>  $1
echo "  .td-title {" >>  $1
echo "    color: white;" >>  $1
echo "    font-size: 120%;" >>  $1
echo "    font-weight: bold;" >>  $1
echo "    padding-left: 5px;" >>  $1
echo "    text-transform: uppercase;" >>  $1
echo "  }" >>  $1
echo "  .td-title-tests {" >>  $1
echo "    font-weight: bold;" >>  $1
echo "    font-size: 120%;" >>  $1
echo "  }" >>  $1
echo "  .td-header-maven-module {" >>  $1
echo "    font-weight: bold;" >>  $1
echo "    font-size: 120%;    " >>  $1
echo "  }" >>  $1
echo "  .td-maven-artifact {" >>  $1
echo "    padding-left: 5px;" >>  $1
echo "  }" >>  $1
echo "  .tr-title {" >>  $1
echo "    background-color: <%= (build.result == null || build.result.toString() == 'SUCCESS') ? '#27AE60' : build.result.toString() == 'FAILURE' ? '#E74C3C' : '#f4e242' %>;" >>  $1
echo "  }" >>  $1
echo "  .test {" >>  $1
echo "    padding-left: 20px;" >>  $1
echo "  }" >>  $1
echo "  .test-fixed {" >>  $1
echo "    color: #27AE60;" >>  $1
echo "  }" >>  $1
echo "  .test-failed {" >>  $1
echo "    color: #E74C3C;" >>  $1
echo "  }" >>  $1
echo "</STYLE>" >>  $1
echo "<BODY>" >>  $1
echo "  <!-- BUILD RESULT -->" >>  $1
echo "  <table class="section" border="1">" >>  $1
echo "    <tr class="tr-title">" >>  $1
echo "      <td class="td-title-main" colspan=2>" >>  $1
echo "        BUILD \${build.result ?: 'COMPLETED'}" >>  $1
echo "      </td>" >>  $1
echo "    </tr>" >>  $1
echo "    <tr>" >>  $1
echo "      <td>URL:</td>" >>  $1
echo "      <td><A href="\${rooturl}\${build.url}">\${rooturl}\${build.url}</A></td>" >>  $1
echo "    </tr>" >>  $1
echo "    <tr>" >>  $1
echo "      <td>Project:</td>" >>  $1
echo "      <td>\${project.name}</td>" >>  $1
echo "    </tr>" >>  $1
echo "    <tr>" >>  $1
echo "      <td>Date:</td>" >>  $1
echo "      <td>\${it.timestampString}</td>" >>  $1
echo "    </tr>" >>  $1
echo "    <tr>" >>  $1
echo "      <td>Duration:</td>" >>  $1
echo "      <td>\${build.durationString}</td>" >>  $1
echo "    </tr>" >>  $1
echo "    <tr>" >>  $1
echo "      <td>Cause:</td>" >>  $1
echo "      <td><% build.causes.each() { cause -> %> \${cause.shortDescription} <%  } %></td>" >>  $1
echo "    </tr>" >>  $1
echo "  </table>" >>  $1
echo "  <br/>" >>  $1
echo "</BODY>" >>  $1
echo "<BODY>" >>  $1
echo "  <table class="section" border="1">" >>  $1
echo "    <tr class="tr-title">" >>  $1
echo "      <td class="td-title-main" colspan=2>" >>  $1
echo "        Failure reason: Parameter not enough" >>  $1
echo "      </td>" >>  $1
echo "    </tr>" >>  $1
echo "  </table>" >>  $1
echo "  <br/>" >>  $1
echo "</BODY>" >>  $1

    endtime=$(date +%s);
    echo -e "##############################"
    time_elapsed $starttime $endtime
    echo -e "##############################\n\n"
}

function parse_website(){
    #####$1: $myusername
    #####$2: $mypassword
    #####$3: $image_website
    #####$4: ${tmp_date}
    #####$5: integer, such as 1
    local_myusername="$1"
    local_mypassword="$2"
    local_image_website="$3"
    local_tmp_date="$4"
    echo -e "##############################"
    echo -e "##### parse_website $image_website"
    echo -e "###############################"
    starttime=$(date +%s);
    curl -u "$local_myusername":"$local_mypassword" "$local_image_website"  > "${local_tmp_date}_parse_website.txt"
    ls -l "${local_tmp_date}_parse_website.txt"
    #login_error=`cat "${tmp_date}_parse_website.txt" | grep -i "errors"`
    a=0
    count=0
    total_times=$[$[30*$5]/5]
    while [ $a -lt 6 -a $count -lt $total_times ]
    do
        login_error=
        login_error=`cat "${local_tmp_date}_parse_website.txt" | grep -i "errors"`
        echo "login_error=$login_error"
        if [[ ! -z $login_error ]]; then
            echo "login error"
            cat "${local_tmp_date}_parse_website.txt"
            login_error_message=`cat "${local_tmp_date}_parse_website.txt" | grep -i "try.*again.*in.*second" `
            echo "login_error_message=$login_error_message"
            sleep 5
            curl -u "$local_myusername":"$local_mypassword" "$local_image_website"  > "${local_tmp_date}_parse_website.txt"
        else
            echo "login ok"
            a=6
        fi
        let count+=1
        echo     "################"
        echo     "#####count:$count"
        echo -e  "################\n"
    done
    endtime=$(date +%s);
    echo -e "##############################"
    time_elapsed $starttime $endtime
    echo -e "##############################\n\n"
}

function get_fastboot_path(){
    echo -e "##############################"
    echo -e "##### get_fastboot_path"
    echo -e "###############################"
    #check_fastmode $IP_ADDRESS $fastboot_bin
    starttime=$(date +%s);


    if [ -f "$WORKSPACE"/fastboot ]; then
        fastboot_bin="$WORKSPACE"/fastboot
        echo "fastboot bin found at $fastboot_bin"
    else
        fastboot_bin=`which fastboot`
        if [ -z $fastboot_bin ]; then
            echo "fastboot bin not found "
            exit -1
        fi
    fi
    echo "fastboot_bin=$fastboot_bin"

    endtime=$(date +%s);
    echo -e "##############################"
    time_elapsed $starttime $endtime
    echo -e "##############################\n\n"
}

function check_fastmode(){
    #####$1: ip address
    #####$2: fastboot which contain absolute path
    echo -e "##############################"
    echo -e "##### check_fastmode $1 $2"
    echo -e "###############################"
    #check_fastmode $IP_ADDRESS $fastboot_bin
    starttime=$(date +%s);
    local_ip_address="$1"
    local_fastboot_bin="$2"
    ping_exist=`which ping`
    echo "ping_exist=$ping_exist"
    if [[ ! -z $ping_exist ]]; then
        ping_target $local_ip_address

        if [[ $ping_reachable == true ]]; then
            $local_fastboot_bin -s tcp:$local_ip_address getvar version
            if [[ $? -eq 0 ]]; then
                echo "enter fastmode"
                is_fastmode=true
            else
                echo "ping reachable, but not fastmode"
                is_fastmode=false
            fi
        elif [[ $ping_reachable == false ]]; then
            echo "ping not reachable"
            is_fastmode=false
        fi
    fi
    echo "ping_reachable=$ping_reachable"
    echo "is_fastmode==$is_fastmode"
    endtime=$(date +%s);
    echo -e "##############################"
    time_elapsed $starttime $endtime
    echo -e "##############################\n\n"
}

# --- Body --------------------------------------------------------
#set -x

#$1 is username
#$2 is password
#$4 local images path
#$5 ip address
#$6 ping -w deadline

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
arg_count=0
for arg in $@
do
let arg_count+=1
echo arg[$arg_count]=$arg
done
echo "Begin CUSTOMIZED_EMAIL_CONTENT=$CUSTOMIZED_EMAIL_CONTENT"
echo "Begin CUSTOMIZED_TEMPLATE=$CUSTOMIZED_TEMPLATE"
#For download
myusername=
mypassword=
image_website=
key_search=
dailybuild_path=${WORKSPACE}
#Target IP
target_ip=
#ping_deadline=
# For flash
android_version=
enable_slot_ab=
slot_ab=
#local_email_template=
#For automation test
test_framework_path=
automation_test_type=

#For email  template
final_template=
inject_env_txt=
final_subject=
detail_info=
xml_path=
exception_reason=
git_branch=
#input mandotary parameters end

flash_script=
real_download=true
real_flash=true
real_automation=true
sleep_control=true
sleep_time=
#input optional parameters end


bootimgornot=
dailybuild_suffix=
dailybuild_url=
is_download=
target_is_reachable_before_flash=true
target_is_reachable_after_flash=true
parameter_enough=true
background_color=
is_fastmode=true
ping_reachable=true
current_dailybuilt_date=
expected_dailybuild_date=
is_new_dailybuild=true
#Internal defined parameters end
##### end parameter
# --- Body --------------------------------------------------------
#set -e

POSITIONAL=()
MY_DIR=$PWD

if [ "$#" -eq 0 ]; then
    print_help
    exit -1
fi

while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -h|--help)
            print_help
        ;;
        -a|--username)
            myusername=$2
            shift # past argument
            shift # past value
        ;;
        -b|--password)
            mypassword=$2
            shift # past argument
            shift # past value
        ;;
        -c|--http_url)
            image_website=$2
            shift # past argument
            shift # past value
        ;;
        -d|--key_search)
            key_search=$2
            shift # past argument
            shift # past value
        ;;
        -e|--ipaddress)
            target_ip=$2
            shift # past argument
            shift # past value
        ;;
        -f|--android_version)
            android_version=$2
            shift # past argument
            shift # past value
        ;;
        -g|--enable_slot_ab)
            enable_slot_ab=$2
            shift # past argument
            shift # past value
        ;;
        -i|--slot_ab)
            slot_ab=$2
            shift # past argument
            shift # past value
        ;;
        -j|--test_framework)
            test_framework_path=$2
            shift # past argument
            shift # past value
        ;;
        -k|--automation_type)
            automation_test_type=$2
            shift # past argument
            shift # past value
        ;;
        -l|--final_template)
            final_template=$2
            shift # past argument
            shift # past value
        ;;
        -m|--inject_env)
            inject_env_txt=$2
            shift # past argument
            shift # past value
        ;;
        -n|--final_subject)
            final_subject=$2
            shift # past argument
            shift # past value
        ;;
        -o|--detail_info)
            detail_info=$2
            shift # past argument
            shift # past value
        ;;
        -p|--xml_path)
            xml_path=$2
            shift # past argument
            shift # past value
        ;;
        -q|--exception_reason)
            exception_reason=$2
            shift # past argument
            shift # past value
        ;;
        -r|--git_branch)
            git_branch=$2
            shift # past argument
            shift # past value
        ;;
        -v|--sleep_time)
            sleep_time=$2
            shift # past argument
            shift # past value
        ;;
        -w|--sleep_control)
            sleep_control=$2
            shift # past argument
            shift # past value
        ;;
        -x|--flash_script)
            flash_script=$2
            shift # past argument
            shift # past value
        ;;
        -y|--real_download)
            real_download=$2
            shift # past argument
            shift # past value
        ;;
        -z|--real_flash)
            real_flash=$2
            shift # past argument
            shift # past value
        ;;
        *)    # unknown option
            echo "Unknown option"
            print_help
            POSITIONAL+=("$1") # save it in an array for later
            shift # past argument
        ;;
    esac
done


echo -e "\n>>>>>>>>> begin <<<<<<<<<<\n"

#####
#####check the parameters which must be exist.
#####
function check_necessary_parameters(){
     if [[ -z $myusername ]] || [[ -z $mypassword ]] || [[ -z $image_website ]]  || [[ -z $key_search ]] || [[ -z ${git_branch} ]]    \
        || [[ -z $target_ip ]]                                                                                                        \
        || [[ -z $android_version ]] || [[ -z $enable_slot_ab ]] || [[ -z $slot_ab ]]                                                 \
        || [[ -z $test_framework_path ]] || [[ -z $automation_test_type ]]                                                            \
        || [[ -z $inject_env_txt ]] || [[ -z $final_template ]] || [[ -z $final_subject ]] || [[ -z $detail_info ]] || [[ -z $xml_path ]] || [[ -z $exception_reason ]]; then
         parameter_enough=false
     fi
}
check_necessary_parameters

if [[ $parameter_enough == true ]]; then
    #####
    #####check whether $image_website tail contains '/'
    #####
    res=$(check_string_tail $image_website "\/")
    echo "res=$res"

    if [ $res -eq 1 ]; then
        image_website=`echo ${image_website%?}`
        echo "changed URL: $image_website"
    elif [ $res -eq 0 ]; then
        echo "origin URL: $image_website"
    fi

    enter_directory "${WORKSPACE}"
    #####
    #####restore origin
    #####
    echo "Now eneter `pwd`"
    
    restore_origin "${WORKSPACE}"
    delete_last_build_artifacts "${WORKSPACE}" "$xml_path"
    ls -l
    
    #####
    #####record date and sleep 7h
    #####
    date
    if [[ $sleep_control == true ]]; then
        if [[ -z $sleep_time ]]; then
            echo "sleep 7 hours"
            expected_dailybuild_date=`date +%d-%b-%Y`
            sleep 7h
        else
            echo "sleep ${sleep_time} hours"
            expected_dailybuild_date=`date +%d-%b-%Y`
            sleep ${sleep_time}h
        fi
        
    elif [[ $sleep_control == false ]]; then
        echo "Don't sleep 7 hours"
        sleep 30
    fi
    date 

    #####
    ##### get the info of website
    #####
    #curl -u "$myusername":"$mypassword" "$image_website/"  > "${tmp_date}_parse_website.txt"
    parse_website "$myusername" "$mypassword" "$image_website/" "${tmp_date}"  1
    ls -l "${tmp_date}_parse_website.txt"
    bootimgornot=`cat ${tmp_date}_parse_website.txt  | grep "boot\.img" `
    echo -e "bootimgornot=$bootimgornot"

    ##### must
    ##### check whether current dailybuild from max index is new expected.
    #check_new_dailybuilt
    if [[ $sleep_control == true ]]; then
        echo "Check whether dailybuild date is newest." 
        check_dailybuild_is_new "${tmp_date}_parse_website.txt" "$image_website" "false" "$key_search"
    elif [[ $sleep_control == false ]]; then
        echo "Ignore dailybuild date"
        echo "is_new_dailybuild=$is_new_dailybuild"
    fi 
  #####if ture: new dailybuild exist, enter normal process
  if [[ $is_new_dailybuild == true ]]; then
    ##### must
    ##### judge whether contain boot.image
    ##### get newest dailybuilt URL according to build number, this URL for downloading images
    ##### Record the dailybuilt URL for email-template
    if [[ -z $bootimgornot ]]; then
        get_and_save_dailybuilt_url "${tmp_date}_parse_website.txt" "$image_website" "false" "$key_search"
    else
        get_and_save_dailybuilt_url "${tmp_date}_parse_website.txt" "$image_website" "true" "$key_search"
    fi

    ##### must
    ##### get dailybuilt date and number for mail tile
    if [[ -z $bootimgornot ]]; then
        if [[ -z $inject_env_txt ]]; then
            get_dailybuilt_date_number "${tmp_date}_parse_website.txt" "customizedenv.txt" "$dailybuild_suffix" "$automation_test_type" "$key_search"
        else
            get_dailybuilt_date_number "${tmp_date}_parse_website.txt" "$inject_env_txt" "$dailybuild_suffix" "$automation_test_type" "$key_search"
        fi
    fi
 

    ##### must
    ##### check whether current dailybuild from max index is new expected.
    #check_new_dailybuilt


    ##### must
    ##### get dailybuild_URL info
    pwd
    if [[ "$WORKSPACE" != "`pwd`" ]]; then
       cd "$WORKSPACE"
    fi
    pwd
    curl -u "$myusername":"$mypassword"  $dailybuild_url  > "${tmp_date}_images_website.txt"


    ##### must
    ##### check images before download
    check_images_before_download  "$android_version" "$enable_slot_ab" "${tmp_date}_images_website.txt"

    if [[ $is_download == true ]];then
        echo -e "\ndailybuild_url=$dailybuild_url\n"
        if [[ $real_download == true ]]; then
            ##### download all aosp iamges
            download_files "$myusername" "$mypassword" "$dailybuild_url" "${tmp_date}"

            ##### check images according to $android_version
            check_images "$android_version" "$enable_slot_ab"
        else
            echo "Not really download AOSP images, ignore download"
        fi

        ##### check whether target is reachable and adb connect successfully,have timeout
        #check_target_is_reachable_before_flash "$target_ip" "$ping_deadline"
        #check_target_is_reachable_timeout "$target_ip" "$ping_deadline" 1 "before"
        adb disconnect
        check_adb_connect "$target_ip" "before" 1
        #adb_reboot_bootloader "$target_ip"

        if [[ $target_is_reachable_before_flash == true ]]; then
            enter_directory "${WORKSPACE}"
            adb shell dmesg > dmesg_before_flash.txt
            cat dmesg_before_flash.txt | grep -i bios
            if [[ $real_flash == true ]]; then
                ##### flash images if check pass
                if [[ ! -z $flash_script ]]; then
                    flash_images "$android_version" "$target_ip" "$enable_slot_ab" "$flash_script"
                else
                    flash_images "$android_version" "$target_ip" "$enable_slot_ab"
                fi
            else
               echo "Not really flash images, only reboot"
               adb reboot
            fi

            ##### check whether target is reachable and adb connect successfully. and save dmesg
            #check_target_is_reachable_timeout "$target_ip" "$ping_deadline" 2 "after"
            check_adb_connect "$target_ip" "after" 1

            if [[ $target_is_reachable_after_flash == true ]]; then
                enter_directory "${WORKSPACE}"
                adb shell dmesg > dmesg.txt
                cat dmesg.txt | grep -i bios

                ##### keep stay on while plugged in, and set date time
                stay_awake_set_date_time "$target_ip"

                ##### get BIOS version for email content
                #make_email_template "${WORKSPACE}"  $local_email_template

                ##### automation test
                automation_test "$test_framework_path" "${target_ip}" "$automation_test_type"

                ##### collect log
                archive_result "$WORKSPACE" "$test_framework_path" "$xml_path"
                check_test_results "$WORKSPACE" "$xml_path"
            elif [[ $target_is_reachable_after_flash == false ]]; then
                echo "target is not reachable(ip:${target_ip}), please check network and adb connect"
            fi
        elif [[ $target_is_reachable_before_flash == false ]]; then
            echo "target is not reachable(ip:${target_ip}), please check network and adb connect"
        fi

    elif [[ $is_download == false ]];then
        echo "Dailybuild images not enough in $dailybuild_url"
        cat "${tmp_date}_images_website.txt"
        curl -u "$myusername":"$mypassword"  $dailybuild_url  > "$exception_reason".bak

    fi

    ##### email template: BIOS & AOSP INFO / BUILD STATUS / EXCEPTION REASON
    if [[ ! -z $final_template ]] ; then
        make_email_template "${WORKSPACE}" "$final_template" "$is_download" "$target_is_reachable_before_flash" "$target_is_reachable_after_flash"  "missing_style.template" "$detail_info" "$background_color" "$exception_reason"
        echo "CUSTOMIZED_TEMPLATE=$final_template" >> $inject_env_txt
        pwd
        echo 'ls -al'
        ls -al
    fi

    ##### collect log
    #archive_result "$WORKSPACE" "$test_framework_path" "$xml_path"
    #check_test_results "$WORKSPACE" "$xml_path"
  
  #####if false, not new dailybuild, directly make email template
  elif [[ $is_new_dailybuild == false ]]; then
        pwd 
        cp -rf ${tmp_date}_parse_website.txt "$exception_reason".bak
        make_no_new_dailybuild_email_template "${WORKSPACE}" "$final_template"   "missing_style.template" "$detail_info"  "$exception_reason"

  fi
elif [[ $parameter_enough == false ]]; then
    echo "Parameters not enough"
    make_parameter_not_enough_template "customized.template"
    if [[ -z $inject_env_txt ]];then
        echo "DAILYBUILT_NUMBER=" >  customizedenv.txt
        echo "DAILYBUILT_DATE=" >>  customizedenv.txt
        if [[ $automation_test_type == sanity ]] || [[ $automation_test_type == smoke ]]; then
            echo "CUSTOMIZED_EMAIL_CONTENT=AOSP-P-Smoke-Test_result" >  customizedenv.txt
            echo "AOSP-P-Smoke-Test_result" >  "$final_subject"
        elif [[ $automation_test_type == regression ]]; then
            echo "CUSTOMIZED_EMAIL_CONTENT=AOSP-P-Regression-Test_result" >  customizedenv.txt
            echo "AOSP-P-Regression-Test_result" >  "$final_subject"
        else
            echo "CUSTOMIZED_EMAIL_CONTENT=AOSP-P-Test_result" >  customizedenv.txt
            echo "AOSP-P-Test_result" >  "$final_subject"
        fi
        echo "CUSTOMIZED_TEMPLATE=customized.template" >>  customizedenv.txt
    else
        echo "DAILYBUILT_NUMBER=" >  $inject_env_txt
        echo "DAILYBUILT_DATE=" >>  $inject_env_txt
        if [[ $automation_test_type == sanity ]] || [[ $automation_test_type == smoke ]]; then
            echo "CUSTOMIZED_EMAIL_CONTENT=AOSP-P-Smoke-Test_result" >  $inject_env_txt
            echo "AOSP-P-Smoke-Test_result" >  "$final_subject"
        elif [[ $automation_test_type == regression ]]; then
            echo "CUSTOMIZED_EMAIL_CONTENT=AOSP-P-Regression-Test_result" >  $inject_env_txt
            echo "AOSP-P-Regression-Test_result" >  "$final_subject"
        else
            echo "CUSTOMIZED_EMAIL_CONTENT=AOSP-P-Test_result" >  $inject_env_txt
            echo "AOSP-P-Test_result" >  "$final_subject"
        fi
        echo "CUSTOMIZED_TEMPLATE=customized.template" >>  $inject_env_txt
    fi
fi

if [[ $is_download == false ]] || [[ $target_is_reachable_before_flash == false ]] || [[ $parameter_enough == false ]] || [[ $target_is_reachable_after_flash == false ]];then
    delete_last_build_artifacts "${WORKSPACE}" "$xml_path"
fi
echo "END CUSTOMIZED_EMAIL_CONTENT=$CUSTOMIZED_EMAIL_CONTENT"
echo "END CUSTOMIZED_TEMPLATE=$CUSTOMIZED_TEMPLATE"

echo -e "\n>>>>>>>>>> end <<<<<<<<<<\n"
