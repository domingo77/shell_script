#!/bin/bash

# prerequisite: install some packages
function install_expect_openssh-server_mediainfo_sshfs_samba_samba-common_net-tools_vim(){
    expect_package_install=`dpkg -s expect |grep "Status: install ok installed"`
    openssh-server_package_install=`dpkg -s openssh-server  |grep "Status: install ok installed"`
    mediainfo_package_install=`dpkg -s mediainfo  |grep "Status: install ok installed"`
    sshfs_pacakge_install=`dpkg -s sshfs  |grep "Status: install ok installed"`
    samba_pacakge_install=`dpkg -s samba  |grep "Status: install ok installed"`
    samba-common_pacakge_install=`dpkg -s samba-common  |grep "Status: install ok installed"`
    net-tools_pacakge_install=`dpkg -s net-tools  |grep "Status: install ok installed"`
    vim_pacakge_install=`dpkg -s vim |grep "Status: install ok installed"`
    echo "expect_package_install=${expect_package_install}"
    echo "openssh-server_package_install=${openssh-server_package_install}"
    echo "mediainfo_package_install=${mediainfo_package_install}"
    echo "sshfs_pacakge_install=${sshfs_pacakge_install}"
    echo "samba_pacakge_install=${samba_pacakge_install}"
    echo "samba-common_pacakge_install=${samba-common_pacakge_install}"
    echo "net-tools_pacakge_install=${net-tools_pacakge_install}"
    echo "vim_pacakge_install=${vim_pacakge_install}"
	

    if [[ -z ${expect_package_install} ]] || [[ -z ${openssh-server_package_install} ]] || [[ -z ${mediainfo_package_install} ]] \
        || [[ -z ${sshfs_pacakge_install} ]] || [[ -z ${samba_pacakge_install} ]] || [[ -z ${samba-common_pacakge_install} ]] \
        || [[ -z ${net-tools_pacakge_install} ]] || [[ -z ${vim_pacakge_install} ]]; then
        /usr/bin/sudo apt-get update
    fi   

    if [[ -z ${openssh-server_package_install} ]]; then
        /usr/bin/sudo apt-get install openssh-server
    fi
    if [[ -z ${vim_pacakge_install} ]]; then
        /usr/bin/sudo apt-get install vim
    fi
    if [[ -z ${net-tools_pacakge_install} ]]; then
        /usr/bin/sudo apt-get install net-tools
    fi
    if [[ -z ${expect_package_install} ]]; then
        /usr/bin/sudo apt-get install expect
    fi
    if [[ -z ${mediainfo_package_install} ]]; then
        /usr/bin/sudo apt-get install mediainfo
    fi
    #/usr/bin/sudo apt-get install adb
    if [[ -z ${sshfs_pacakge_install} ]]; then
        /usr/bin/sudo apt-get install sshfs
    fi
    if [[ -z ${samba_pacakge_install} ]] || [[ -z ${samba-common_pacakge_install} ]]; then
        /usr/bin/sudo apt-get install samba samba-common
    fi
}

#1,create directory
function create_neccesary_directory(){
    echo -e "##############################"
    echo -e "#####create_neccesary_directory"
    echo -e "###############################"
    if [[ ! -d $HOME/bin ]]; then
        mkdir -p $HOME/bin
        chmod -R 0777 $HOME/bin
    fi
    #home_bin_in_env_PATH=`cat $HOME/.bashrc |grep -i "export.*PATH=.*$HOME\/bin.*\$PATH"`
    #if [[ -z $home_bin_in_env_PATH ]]; then
    #    echo "export PATH=$HOME/bin:\$PATH" >> $HOME/.bashrc
    #    echo "#######Notice: Please close terminal, and reopen a terminal to load .bashrc"
    #    exit 0
    #fi
	export PATH=$HOME/bin:$PATH
	env | grep -i path
    
    if [[ ! -d $HOME/1-never-delete ]]; then
        mkdir -p $HOME/1-never-delete
        chmod -R  0777 $HOME/1-never-delete
    fi

    if [[ ! -d $HOME/Videos ]]; then
        mkdir -p $HOME/Videos
        chmod -R 0777 $HOME/Videos
    fi
    ls | grep "bin\|Videos\|1-never-delete"
    echo -e "##############################"
    echo -e "#####create_neccesary_directory -----------END"
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
echo "spawn scp mingdong@\$host:/home/mingdong/1-never-delete/upload-stream-V1.0/bin/parse_stream-update.sh  \$work_directory/bin/parse_stream-update.sh" >>  $HOME/bin/login_scp_necessary_file
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

#prerequisite:
install_expect_openssh-server_mediainfo_sshfs_samba_samba-common_net-tools_vim

#1,create directory
create_neccesary_directory

#scp: download script
if [[ ! -f $HOME/bin/login_scp_necessary_file ]]; then
    generate_login_scp_expect_file	
fi
if [[ ! -f $HOME/bin/parse_stream-update.sh ]] || [[ ! -f $HOME/1-never-delete/Backup.xml ]] || [[ ! -f $HOME/1-never-delete/remote_space.txt ]]; then
    login_scp_necessary_file "10.67.237.128"  "$HOME"
fi

tmp_date=`date +%Y%m%d_%H_%M_%S_%p`
log_name_suffix=`echo "$1" | sed -e "s/\//_/g"| sed -e "s/^_//g"`
#execute the script.
parse_stream-update.sh $1 2>&1 | tee $HOME/$log_name_suffix-$tmp_date.txt
