#!/bin/bash

function get_env_user(){
    echo -e "##############################"
    echo -e "#####get_env_user"
    echo -e "###############################"
    env_user=`env | grep USER | awk -F "=" '{print $2}'`
    if [[ $env_user != [rR][oO][oO][tT] ]]; then
        echo "current user isnot root, is $env_user"
        sudo_bin=`which sudo`
    else
        echo "current user is root" 
    fi 
    echo -e "##############################"
    echo -e "#####get_env_user -----------END"
    echo -e "###############################\n\n"
}

# prerequisite: install some packages
function install_necessary_packages(){
    echo -e "##############################"
    echo -e "####install_necessary_packages"
    echo -e "###############################"
    expect_package_install=`dpkg -s expect |grep "Status: install ok installed"`
    openssh_server_package_install=`dpkg -s openssh-server  |grep "Status: install ok installed"`
    mediainfo_package_install=`dpkg -s mediainfo  |grep "Status: install ok installed"`
    sshfs_pacakge_install=`dpkg -s sshfs  |grep "Status: install ok installed"`
    samba_pacakge_install=`dpkg -s samba  |grep "Status: install ok installed"`
    samba_common_pacakge_install=`dpkg -s samba-common  |grep "Status: install ok installed"`
    net_tools_pacakge_install=`dpkg -s net-tools  |grep "Status: install ok installed"`
    vim_pacakge_install=`dpkg -s vim |grep "Status: install ok installed"`
    ffmpeg_pacakge_install=`dpkg -s ffmpeg |grep "Status: install ok installed"`
    iputils_ping_pacakge_install=`dpkg -s iputils-ping |grep "Status: install ok installed"`
    echo "Before expect_package_install=${expect_package_install}"
    echo "Before openssh_server_package_install=${openssh_server_package_install}"
    echo "Before mediainfo_package_install=${mediainfo_package_install}"
    echo "Before sshfs_pacakge_install=${sshfs_pacakge_install}"
    echo "Before samba_pacakge_install=${samba_pacakge_install}"
    echo "Before samba_common_pacakge_install=${samba_common_pacakge_install}"
    echo "Before net_tools_pacakge_install=${net_tools_pacakge_install}"
    echo "Before vim_pacakge_install=${vim_pacakge_install}"
    echo "Before ffmpeg_pacakge_install=${ffmpeg_pacakge_install}"
    echo "Before iputils_ping_pacakge_install=${iputils_ping_pacakge_install}"
	
    if [[ ! -z $expect_package_install ]] && [[ ! -z $openssh_server_package_install ]] && [[ ! -z $mediainfo_package_install ]] \
       && [[ ! -z $sshfs_pacakge_install ]] && [[ ! -z $samba_pacakge_install ]] && [[ ! -z $samba_common_pacakge_install ]] \
       && [[ ! -z $net_tools_pacakge_install ]] && [[ ! -z $vim_pacakge_install ]] && [[ ! -z $ffmpeg_pacakge_install ]] \
       && [[ ! -z $iputils_ping_pacakge_install ]]; then
        echo -e "\nAll necessay  packages have been installed: expect/sshfs/net-tools/samba/samba-common/vim/openssh-server/iputils-ping"
    else

        if [[ -z ${expect_package_install} ]] || [[ -z ${openssh_server_package_install} ]] || [[ -z ${mediainfo_package_install} ]] \
            || [[ -z ${sshfs_pacakge_install} ]] || [[ -z ${samba_pacakge_install} ]] || [[ -z ${samba_common_pacakge_install} ]] \
            || [[ -z ${net_tools_pacakge_install} ]] || [[ -z ${vim_pacakge_install} ]] || [[ -z $ffmpeg_pacakge_install ]] \
	    || [[ -z $iputils_ping_pacakge_install ]]; then
            $sudo_bin apt-get update
        fi   

        if [[ -z ${openssh_server_package_install} ]]; then
            echo -e "\ninstall openssh-server"
            echo Y | $sudo_bin apt-get install openssh-server
        fi
        if [[ -z ${vim_pacakge_install} ]]; then
            echo -e "\ninstall vim"
            echo Y | $sudo_bin apt-get install vim
        fi
        if [[ -z ${net_tools_pacakge_install} ]]; then
            echo -e "\ninstall net-tools"
            echo Y | $sudo_bin apt-get install net-tools
        fi
        if [[ -z ${expect_package_install} ]]; then
            echo -e "\ninstall expect"
            echo Y | $sudo_bin apt-get install expect
        fi
        if [[ -z ${mediainfo_package_install} ]]; then
            echo -e "\ninstall mediainfo"
            echo Y | $sudo_bin apt-get install mediainfo
        fi
        #$sudo_bin apt-get install adb
        if [[ -z ${sshfs_pacakge_install} ]]; then
            echo -e "\ninstall sshfs"
            echo Y | $sudo_bin apt-get install sshfs
        fi
        if [[ -z ${samba_pacakge_install} ]] || [[ -z ${samba_common_pacakge_install} ]]; then
            echo -e "\ninstall openssh-server samba"
            echo Y | $sudo_bin apt-get install samba
            echo Y | $sudo_bin apt-get install samba-common
        fi
        if [[ -z ${ffmpeg_pacakge_install} ]]; then
            echo -e "\ninstall ffmpeg"
            echo Y | $sudo_bin apt-get install ffmpeg
        fi
        if [[ -z ${iputils_ping_pacakge_install} ]]; then
            echo -e "\ninstall iputils-ping"
            echo Y | $sudo_bin apt-get install iputils-ping
        fi
        echo "After expect_package_install=${expect_package_install}"
        echo "After openssh_server_package_install=${openssh_server_package_install}"
        echo "After mediainfo_package_install=${mediainfo_package_install}"
        echo "After sshfs_pacakge_install=${sshfs_pacakge_install}"
        echo "After samba_pacakge_install=${samba_pacakge_install}"
        echo "After samba_common_pacakge_install=${samba_common_pacakge_install}"
        echo "After net_tools_pacakge_install=${net_tools_pacakge_install}"
        echo "After vim_pacakge_install=${vim_pacakge_install}"
        echo "After ffmpeg_pacakge_install=${ffmpeg_pacakge_install}"
        echo "After iputils_ping_pacakge_install=${iputils_ping_pacakge_install}"
    fi
    echo -e "##############################"
    echo -e "#####install_necessary_packages -----------END"
    echo -e "###############################\n\n"
}

#1,set env path
function set_env_path(){
    echo -e "##############################"
    echo -e "#####set_env_path"
    echo -e "###############################"

    home_bin_in_env_PATH=$(cat $HOME/.bashrc |grep  "export PATH=$HOME\/bin:\$PATH")
    echo "home_bin_in_env_PATH=$home_bin_in_env_PATH"
    if [[ -z $home_bin_in_env_PATH ]]; then
        echo "export PATH=$HOME/bin:\$PATH" >> $HOME/.bashrc
    fi
    cat $HOME/.bashrc |grep  "export PATH=$HOME\/bin:\$PATH"
    export PATH=$HOME/bin:$PATH
    env | grep -i path

    echo -e "##############################"
    echo -e "#####set_env_path -----------END"
    echo -e "###############################\n\n"
}

function create_necessary_directory(){
    echo -e "##############################"
    echo -e "#####create_necessary_directory"
    echo -e "###############################"

    if [[ ! -d $HOME/bin ]]; then
        mkdir -p $HOME/bin
        chmod -R 0777 $HOME/bin
    fi
    if [[ ! -d $HOME/1-never-delete ]]; then
        mkdir -p $HOME/1-never-delete
        chmod -R  0777 $HOME/1-never-delete
    fi
    if [[ ! -f $HOME/logs ]]; then
        mkdir -p $HOME/logs
        chmod -R 0777 $HOME/logs
    fi

    echo -e "##############################"
    echo -e "#####set_env_path -----------END"
    echo -e "###############################\n\n"
}

#scp: download script
function generate_login_scp_expect_file(){
    echo -e "##############################"
    echo -e "#####generate_login_scp_expect_file"
    echo -e "###############################"


echo "#!/usr/bin/expect" > $HOME/bin/login_scp_necessary_file
echo "log_user 1" >>  $HOME/bin/login_scp_necessary_file
echo "set host [lindex \$argv 0]" >>  $HOME/bin/login_scp_necessary_file
echo "set work_directory [lindex \$argv 1]" >>  $HOME/bin/login_scp_necessary_file
echo "spawn scp mingdong@\$host:/home/mingdong/1-never-delete/release_bin/upload_stream_final.sh \$work_directory/bin/upload_stream_final.sh" >>  $HOME/bin/login_scp_necessary_file
echo "expect \"*password:\"" >>  $HOME/bin/login_scp_necessary_file
echo "send \"123456\\r\"" >>  $HOME/bin/login_scp_necessary_file
echo "expect \"100%\"" >>  $HOME/bin/login_scp_necessary_file

echo "spawn scp mingdong@\$host:/home/mingdong/1-never-delete/upload-stream-V1.0/Backup.xml  \$work_directory/1-never-delete/Backup.xml" >>  $HOME/bin/login_scp_necessary_file
echo "expect \"*password:\"" >>  $HOME/bin/login_scp_necessary_file
echo "send \"123456\\r\"" >>  $HOME/bin/login_scp_necessary_file
echo "expect \"100%\"" >>  $HOME/bin/login_scp_necessary_file

echo "spawn scp mingdong@\$host:/home/mingdong/1-never-delete/upload-stream-V1.0/remote_space.txt  \$work_directory/1-never-delete/remote_space.txt" >>  $HOME/bin/login_scp_necessary_file
echo "expect \"*password:\"" >>  $HOME/bin/login_scp_necessary_file
echo "send \"123456\\r\"" >>  $HOME/bin/login_scp_necessary_file
echo "expect \"100%\"" >>  $HOME/bin/login_scp_necessary_file

    if [[ -f $HOME/bin/login_scp_necessary_file ]]; then
        chmod 0777 $HOME/bin/login_scp_necessary_file
    else
        echo "ERROR: failed to generate $HOME/bin/login_scp_necessary_file, please contact Ming.Dong to check."
        exit -1
    fi

    echo -e "##############################"
    echo -e "#####generate_login_scp_expect_file -----------END"
    echo -e "###############################\n\n"
}
#execute the script.



#----------------------------------Body------------------------
echo "\$#=$#"
echo "\$*=$*"
echo "\$@=$@"

sudo_bin=
tmp_date=`date +%Y%m%d_%H_%M_%S_%p`
log_name_suffix=`echo "$1" | sed -e "s/\//_/g"| sed -e "s/^_//g"`
get_env_user

#create necessary directory
create_necessary_directory

#1,create directory
set_env_path

#prerequisite:
install_necessary_packages

#scp: download script
#if [[ ! -f $HOME/bin/login_scp_necessary_file ]]; then
#    generate_login_scp_expect_file	
#fi
#if [[ ! -f $HOME/bin/upload_stream-for-user.sh ]] || [[ ! -f $HOME/1-never-delete/Backup.xml ]] || [[ ! -f $HOME/1-never-delete/remote_space.txt ]]; then
#    login_scp_necessary_file "10.67.237.128"  "$HOME"
#fi

#upload_stream-for-user.sh $1 2>&1 | tee $HOME/logs/$log_name_suffix-$tmp_date.txt
if [[  ! -f $HOME/bin/pre_install.sh ]]; then
    cp -rf ~/pre_install.sh $HOME/bin/pre_install.sh
    chmod 0777 $HOME/bin/pre_install.sh
    ls $HOME/bin/pre_install.sh
fi
