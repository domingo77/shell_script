#!/bin/bash -
#title           :flash_images.sh
#description     :This script will create partitions on device and flash android
#                 Images through fastboot utility over network.
#date            :12/09/2019
#version         :1.0
#usage           :flash_images.sh -i 192.168.26.233 -v Pie -q -s A
#==============================================================================
function print_help(){
    echo "Help"
    echo "flash_images.sh -i [IPADDRESS] -v [VERSION] <-q>"
    echo -e "-i|--ipaddress IPADDRESS\tip address of target device"
    echo -e "-v|--version VERSION\t\tAndroid version, P/p/Pie/pie/N/n/Nougat/nougat"
    echo "Optional Argument:"
    echo -e "-h|--help\t\t\tHelp"
    echo -e "-q|--quick\t\t\tSkip flashing GPT partition table to target device"
    echo -e "-b|--bios FILE\t\t\tBIOS file to flash"
    echo -e "-o|--out-dir PATH\t\tDirectory path containing system images"
    echo -e "-f|--fastboot-path PATH\t\tDirectory containing fastboot binary"
    echo -e "-s|--slot Target Slot\t\tAndroid A/B partitions slot selection, A/a/B/b/All"
    echo ""
    echo "Example1: flash_images.sh -i 192.168.26.233 -v N -q"
    echo "Example2: flash_images.sh -i 192.168.26.233 -v Pie -o . -s A"
    echo ""
    exit 0
}

function time_elapsed(){
    difftemp=`expr "$2" - "$1"`
    ss=$(( $difftemp%60 ))
    mm=$(( ($difftemp-$ss)/60 ))
    echo "Total time taken = $mm:$ss(mm:ss)"
}

function update_out_dir(){
    OUT_DIR=$1
    if [ -z "$OUT_DIR" ]; then
        echo "No argument followed by option -o or --out-dir"
        exit -1
    fi
    if [ ! -d $OUT_DIR ]; then
        echo "Directory path $OUT_DIR does not exist"
        exit -1
    fi
}

function get_fastboot_path(){
    FASTBOOT_PATH=$1
    if [ -z "$FASTBOOT_PATH" ]; then
        echo "No argument followed by option -f or --fastboot-path"
        exit -1
    fi
    if [ ! -d $FASTBOOT_PATH ]; then
        echo "Directory path $FASTBOOT_PATH does not exist"
        exit -1
    fi
    if [ -f $FASTBOOT_PATH/fastboot ]; then
        fastboot_bin=$FASTBOOT_PATH/fastboot
        echo "fastboot bin found at $fastboot_bin"
    else
        echo "fastboot bin not found at $FASTBOOT_PATH/fastboot"
        exit -1
    fi
}

function get_ip_address(){
    IP_ADDRESS=$1
    if [ -z "$IP_ADDRESS" ]; then
        echo "No argument followed by option -i or --ipaddress"
        exit -1
    fi
}

function get_bios_file(){
    BIOS_FILE=$1
    if [ -z "$BIOS_FILE" ]; then
        echo "No argument followed by option -b or --bios"
        exit -1
    fi
    if [ -f $BIOS_FILE ]; then
        bios_bin=$BIOS_FILE
        echo "bios file found at $bios_bin"
        BIOS_DETECTED=yes
    else
        echo "bios file not found at $BIOS_FILE"
        exit -1
    fi
}

function get_android_version(){
    GIVEN_VERSION=$1
    if [ -z "$GIVEN_VERSION" ]; then
        echo "No argument followed by option -v or --version"
        echo "Valid arguments are P/p/Pie/pie/N/n/Nougat/nougat"
        exit -1
    fi
    if [[ $GIVEN_VERSION == @(P|p|Pie|pie) ]]; then
        ANDROID_VER="ANDROID_P"
    elif [[ $GIVEN_VERSION == @(N|n|Nougat|nougat) ]]; then
        ANDROID_VER="ANDROID_N"
    else
        echo "Unknown android version supplied"
        echo "Valid arguments are P/p/Pie/pie/N/n/Nougat/nougat"
        exit -1
    fi
}
function get_slot(){
    GIVEN_SLOT=$1
    if [ -z "$GIVEN_SLOT" ]; then
        echo "No argument followed by option -s or --slot"
        echo "Valid arguments are A/a/B/b/All"
        exit -1
    fi
    if [[ $ANDROID_VER == "ANDROID_N" ]]; then
        echo "A/B is not supported in Android Nougat"
        exit -1
    fi
    if [[ $GIVEN_SLOT == @(All|all) ]]; then
        SELECTED_SLOT="SLOT_ALL"
    elif [[ $GIVEN_SLOT == @(A|a) ]]; then
        SELECTED_SLOT="SLOT_A"
    elif [[ $GIVEN_SLOT == @(B|b) ]]; then
        SELECTED_SLOT="SLOT_B"
    else
        echo "Unknown slot supplied"
        echo "Valid arguments are A/a/B/b/All"
        exit -1
    fi
}

function check_android_root(){
    ANDROID_ROOT=$PWD
    if [ ! -f $ANDROID_ROOT/Android.bp ]; then
        return 1
    fi
    OUT_DIR=${ANDROID_ROOT}/out/target/product/raven
    return 0
}

function check_android_binaries(){
    IMAGES_PATH=$1
    if [ ! -d $IMAGES_PATH ]; then
        echo "Directory path $IMAGES_PATH does not exist"
        exit -1
    fi
    if [[ $QUICK != "yes" ]]; then
        if [ -f $IMAGES_PATH/gpt/gpt.bin ]; then
            GPT_BIN=$IMAGES_PATH/gpt/gpt.bin
        elif [ -f $IMAGES_PATH/gpt.bin ]; then
            GPT_BIN=$IMAGES_PATH/gpt.bin
        else
            echo "gpt.bin not found"
            exit -1
        fi
    fi

    if [ ! -f $IMAGES_PATH/boot.img ]; then
        echo "boot.img not found"
        exit -1
    fi
    if [[ $ANDROID_VER == "ANDROID_P" ]]; then
        if [ ! -f $IMAGES_PATH/vendor.img ]; then
            echo "vendor.img not found"
            exit -1
        fi
        if [ ! -f $IMAGES_PATH/misc.img ]; then
            echo "misc.img not found"
            exit -1
        fi
        if [ ! -f $IMAGES_PATH/vbmeta.img ]; then
            echo "vbmeta.img not found"
            exit -1
        fi
    fi
    if [[ $ANDROID_VER == "ANDROID_N" ]]; then
        if [ ! -f $IMAGES_PATH/cache.img ]; then
            echo "cache.img not found"
            exit -1
        fi
    fi

    if [ ! -f $IMAGES_PATH/userdata.img ]; then
        echo "userdata.img not found"
        exit -1
    fi
    if [ ! -f $IMAGES_PATH/system.img ]; then
        echo "system.img not found"
        exit -1
    fi
}

function valid_ip()
{
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
    return $stat
}

function check_adb_connect(){
    #####$1 target ip address
    #####$2 time for timeout, minute
    echo -e "##############################"
    echo -e "##### check target is adb connect successfully"
    echo -e "###############################"
    adb version
    starttime=$(date +%s);
    a=0
    count=0
    total_times=$[$[60*$2]/5]
    echo "Try connect $total_times times, about $2 minute(s)"
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
    if [[ $a != 30 ]]; then
        echo "adb connect failed. exit"
        exit -1	
    fi
    endtime=$(date +%s);
    echo -e "##############################"
    time_elapsed $starttime $endtime
    echo -e "##############################\n\n"

}

# --- Body --------------------------------------------------------

POSITIONAL=()
MY_DIR=$PWD
PINGTIMEOUT=300 #5 Minutes

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
        -b|--bios)
            get_bios_file $2
            shift # past argument
            shift # past value
        ;;
        -i|--ipaddress)
            get_ip_address $2
            shift # past argument
            shift # past value
        ;;
        -q|--quick)
            QUICK=yes
            shift # past argument
        ;;
        -v|--version)
            get_android_version $2
            shift # past argument
            shift # past value
        ;;
        -s|--slot)
            get_slot $2
            shift # past argument
            shift # past value
        ;;
        -o|--out-dir)
            update_out_dir $2
            shift # past argument
            shift # past value
        ;;
        -f|--fastboot-path)
            get_fastboot_path $2
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

if [ -z "$IP_ADDRESS" ]; then
    echo "#############################################################"
    echo "ip address of target device not provided"
    echo "Must provide target ip address with option -i or --ipaddress"
    echo "#############################################################"
    print_help
else
    if ! valid_ip $IP_ADDRESS; then
        echo "Invalid ip address $IP_ADDRESS"
        exit -1
    fi
fi

if [ -z "$ANDROID_VER" ]; then
    echo "#########################################################"
    echo "No android version supplied"
    echo "Must provide android version with option -v or --version"
    echo "#########################################################"
    print_help
fi
if [ -z "$OUT_DIR" ]; then
    if check_android_root; then
        check_android_binaries $OUT_DIR
    else
        echo "############################################################"
        echo "out directory is not supplied and android root not detected"
        echo "############################################################"
        print_help
    fi
else
    check_android_binaries $OUT_DIR
fi
if [ -z "$FASTBOOT_PATH" ]; then
    if [ -f $MY_DIR/fastboot ]; then
        fastboot_bin=$MY_DIR/fastboot
    elif [ -f $MY_DIR/gpt/fastboot ]; then
        fastboot_bin=$MY_DIR/gpt/fastboot
    elif check_android_root; then
        if [ -f $OUT_DIR/gpt/fastboot ]; then
            fastboot_bin=$OUT_DIR/gpt/fastboot
        else
            echo "fastboot binary not found"
            exit -1
        fi
    else
        echo "fastboot binary not found"
        exit -1
    fi
fi

echo "################################"
echo "check whether device is in Android"
echo "################################"
echo -n "Please make sure target device ($IP_ADDRESS) is in ANdroid mode"
check_adb_connect $IP_ADDRESS 3

adb reboot bootloader

echo "################################"
echo "Looking for target device in n/w"
echo "################################"
echo -n "Please make sure target device ($IP_ADDRESS) is in fastboot mode"
pingstarttime=$(date +%s);
while :; do
    ping -c 1 -q $IP_ADDRESS 1>&-
    if [ "$?" -eq 0 ]; then
        echo ""
        echo "#####################"
        echo -n "Target detected"
        echo -e '\U00002713'
        echo "#####################"
        break
    else
        echo -n " ."
        currtime=$(date +%s);
        pingtimeelapsed=`expr "$currtime" - "$pingstarttime"`
        if [ $pingtimeelapsed -gt $PINGTIMEOUT ]
        then
            echo "Target not found in n/w, Timedout."
            exit -1
        fi
    fi
    sleep 1
done

product_name=$($fastboot_bin -s tcp:$IP_ADDRESS getvar product 2>&1)
#TODO - Do conditional check and flash only if it is Raven product.
if [ `echo $product_name | grep -c "Raven" ` -gt 0 ]
then
  echo "Raven target device found"
else
  echo "Target device is not a Raven product"
fi

$fastboot_bin -s tcp:$IP_ADDRESS getvar version-bootloader 2>&1
#TODO - Check minimum bootloader version

if [[ $BIOS_DETECTED == "yes" ]]; then
    $fastboot_bin -s tcp:$IP_ADDRESS flash spi $bios_bin
    echo "Platform BIOS has been updated."
fi

starttime=$(date +%s);

if [[ $QUICK != "yes" ]]; then
    $fastboot_bin -s tcp:$IP_ADDRESS flash gpt $GPT_BIN
    echo "GPT table created."
fi

echo "##########################"
echo "Flashing target partitions"
echo "##########################"

if [[ $ANDROID_VER == "ANDROID_P" ]]; then

        $fastboot_bin -s tcp:$IP_ADDRESS flash misc $OUT_DIR/misc.img
    if [[ -z "$SELECTED_SLOT" ]] || [[ $SELECTED_SLOT == "SLOT_A" ]] || [[ $SELECTED_SLOT == "SLOT_ALL" ]]; then
        echo "Flashing slot suffix _a partitions"
        $fastboot_bin -s tcp:$IP_ADDRESS flash boot_a $OUT_DIR/boot.img
        $fastboot_bin -s tcp:$IP_ADDRESS flash vbmeta_a $OUT_DIR/vbmeta.img
        $fastboot_bin -s tcp:$IP_ADDRESS flash vendor_a $OUT_DIR/vendor.img
        $fastboot_bin -s tcp:$IP_ADDRESS flash system_a $OUT_DIR/system.img
    fi

    if [[ -z "$SELECTED_SLOT" ]] || [[ $SELECTED_SLOT == "SLOT_B" ]] || [[ $SELECTED_SLOT == "SLOT_ALL" ]]; then
        echo "Flashing slot suffix _b partitions"
        $fastboot_bin -s tcp:$IP_ADDRESS flash boot_b $OUT_DIR/boot.img
        $fastboot_bin -s tcp:$IP_ADDRESS flash vbmeta_b $OUT_DIR/vbmeta.img
        $fastboot_bin -s tcp:$IP_ADDRESS flash vendor_b $OUT_DIR/vendor.img
        $fastboot_bin -s tcp:$IP_ADDRESS flash system_b $OUT_DIR/system.img
    fi

elif [[ $ANDROID_VER == "ANDROID_N" ]]; then
    $fastboot_bin -s tcp:$IP_ADDRESS flash boot $OUT_DIR/boot.img
    $fastboot_bin -s tcp:$IP_ADDRESS flash cache $OUT_DIR/cache.img
    $fastboot_bin -s tcp:$IP_ADDRESS flash system $OUT_DIR/system.img
fi
$fastboot_bin -s tcp:$IP_ADDRESS flash data $OUT_DIR/userdata.img

$fastboot_bin -s tcp:$IP_ADDRESS reboot
endtime=$(date +%s);
echo "##########################"
time_elapsed $starttime $endtime
echo "##########################"
echo "Flashing is complete!!!"
echo "##########################"


echo "################################"
echo "check whether device is in Android"
echo "################################"
echo -n "Please make sure target device ($IP_ADDRESS) is in ANdroid mode"
check_adb_connect $IP_ADDRESS 3

echo "################################"
echo "Enable stay_awake for no sleep"
echo "################################"
echo -n "Please make sure target device ($IP_ADDRESS) is in ANdroid mode"
adb shell settings get global stay_on_while_plugged_in
adb shell settings put global stay_on_while_plugged_in 7
adb shell settings get global stay_on_while_plugged_in


exit 0
