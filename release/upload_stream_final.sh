#!/bin/bash 

function print_help(){

    echo "Only three condition:"
    echo "1, trcak type: general + video"
    echo "2, trcak type: general + video + audio"
    echo "3, trcak type: general + video + audio1 + audio2"
    echo -e "\n\n"
    echo -e "For example:"
    echo -e "parse_stream.sh $HOME/Origin-Stream/\${directory}"
    echo -e "Note: \${directory} is a directory name and contains some streams in it."

}

function generat_expect_file_about_sshfs_mount(){
    echo -e "##############################"
    echo -e "#####generat_expect_file_about_sshfs_mount"
    echo -e "###############################"

    if [[ ! -f $HOME/bin/$mount_remote_expect_file ]]; then
         echo "$HOME/bin/$mount_remote_expect_file not exist, so create it"
         echo "#!/usr/bin/expect"                        > $HOME/bin/$mount_remote_expect_file
         echo "log_user 1"                               >> $HOME/bin/$mount_remote_expect_file
         echo "set user [lindex \$argv 0]"                >> $HOME/bin/$mount_remote_expect_file
         echo "set host [lindex \$argv 1]"                       >> $HOME/bin/$mount_remote_expect_file
         echo "set remote_dir [lindex \$argv 2]"                  >> $HOME/bin/$mount_remote_expect_file
         echo "set mount_directory_path [lindex \$argv 3]"        >> $HOME/bin/$mount_remote_expect_file
         echo "set option [lindex \$argv 4]"                      >> $HOME/bin/$mount_remote_expect_file
         echo "set option_parameter [lindex \$argv 5]"            >> $HOME/bin/$mount_remote_expect_file
         echo "spawn -ignore HUP sshfs \$user@\$host:\$remote_dir   \$mount_directory_path -\$option \$option_parameter"          >> $HOME/bin/$mount_remote_expect_file
         echo "#spawn -ignore HUP sshfs root@atgasia01:/var/www/html /home/mero/$remote_mounted_direcotry -p 1082"         >> $HOME/bin/$mount_remote_expect_file
         echo "sleep 2"                                         >> $HOME/bin/$mount_remote_expect_file
         echo "expect \"*password:\""                             >> $HOME/bin/$mount_remote_expect_file
         echo "send \"mediapool\\r\""                            >> $HOME/bin/$mount_remote_expect_file
         echo "interact"                                               >> $HOME/bin/$mount_remote_expect_file  
         chmod 0777 $HOME/bin/$mount_remote_expect_file
         if [[ -f $HOME/bin/$mount_remote_expect_file ]]; then
             echo "Successfully create expect file : $HOME/bin/$mount_remote_expect_file, for automatically mount remote server to local"
         else
             echo "Error: Failed to create expect file : $HOME/bin/$mount_remote_expect_file"
	     exit -1
         fi
    else
         echo "$HOME/bin/$mount_remote_expect_file exist"
    fi

    echo -e "##############################"
    echo -e "#####END generat_expect_file_about_sshfs_mount"
    echo -e "###############################\n\n"
}

function check_remote_server_is_mounted_to_local_directory(){
    echo -e "##############################"
    echo -e "#####check_remote_server_is_mounted_to_local_directory"
    echo -e "###############################"
    fusermount -u $HOME/$remote_mounted_direcotry
    if [[ ! -d $HOME/$remote_mounted_direcotry ]]; then
         echo "$HOME/$remote_mounted_direcotry not exist, so create it"
         mkdir $HOME/$remote_mounted_direcotry
	 ls $HOME/$remote_mounted_direcotry
    fi
    if [[ -d $HOME/$remote_mounted_direcotry ]]; then
        echo "$HOME/$remote_mounted_direcotry exist,so first unmount reomote server"
        fusermount -u $HOME/$remote_mounted_direcotry
	$mount_remote_expect_file root atgasia01 "/var/www/html" "$HOME/$remote_mounted_direcotry" p 1082
	if [[ -f $HOME/$remote_mounted_direcotry/_MEDIA_POOL_ ]]; then
            echo "Successfully Mount to local directory $HOME/$remote_mounted_direcotry/"
	    ls -lh $HOME/$remote_mounted_direcotry/
        else
            echo "######################Failure: Failed to mount remote server to local  "
            echo "######################please contact Ming.Dong, let him check why"
            echo -e "\n\n"
	    exit -1
        fi
    fi


    echo -e "##############################"
    echo -e "#####END check_remote_server_is_mounted_to_local_directory"
    echo -e "###############################\n\n"
}

function check_record_xml_exist(){
    echo -e "##############################"
    echo -e "#####check_record_xml_exist"
    echo -e "###############################"

    if [[ ! -f $HOME/$local_saved_directory/$summary_xml_name ]]; then
        cp -rf $HOME/$local_backup_file_directory/Saved-Test_streams_template-modified-ubuntu.xml $HOME/$local_saved_directory/$summary_xml_name 
    fi


    echo -e "##############################"
    echo -e "#####END check_record_xml_exist"
    echo -e "###############################\n\n"
}

function check_record_xml_with_file_size_exist(){
    echo -e "##############################"
    echo -e "#####check_record_xml_with_file_size_exist"
    echo -e "###############################"

    if [[ ! -f $HOME/$local_saved_directory/$summary_xml_name ]]; then
        cp -rf $HOME/$local_backup_file_directory/Backup.xml $HOME/$local_saved_directory/$summary_xml_name 
    fi


    echo -e "##############################"
    echo -e "#####END check_record_xml_with_file_size_exist"
    echo -e "###############################\n\n"
}

function check_remote_space_is_enough(){
    echo -e "##############################"
    echo -e "#####check_remote_space_is_enough"
    echo -e "###############################"
    cat $HOME/$local_backup_file_directory/remote_space.txt
    remote_avail_space=`cat $HOME/$local_backup_file_directory/remote_space.txt `
    echo "remote space: $remote_avail KB"
    local_steam_space=`du $1 | awk -F " " '{print $1}'`
    echo "remain space: $(( $remote_avail_space - $local_steam_space )) KB"
    if [[ $(( $remote_avail_space )) -le 5242880 ]]; then 
        echo "Error: Remote server atgasia01 avail space <= 5G, please check"
        exit -1
    fi
    remain_remote_avail_space=$(( $remote_avail_space - $local_steam_space ))
    echo "$remain_remote_avail_space" > $HOME/$local_backup_file_directory/remote_space.txt
    cat $HOME/$local_backup_file_directory/remote_space.txt
    echo -e "##############################"
    echo -e "#####END check_remote_space_is_enough"
    echo -e "###############################\n\n"

}

function check_file_name_is_valid(){
    echo -e "##############################"
    echo -e "##### check_file_name_is_valid "
    echo -e "###############################"
    pwd 
    ls -lh
    ls > ls.txt
    cat ls.txt
    echo -e "\n>>>>>>>>> begin <<<<<<<<<<\n"
    echo -e  "\n\n[Stream Directory path: "$1" count: $files_count]" >> "$HOME/$local_saved_directory/$step_name_suffix/Step1-Check_name_is_valid.txt" 
    while read line
    do
    echo "#########################################################################"
    echo "$line"
    tmp=`echo $line`
    local_space=`echo $line | grep -i " "`
    echo "local_space=$local_space"
    local_left_bracket=`echo $line | grep -i "("`
    echo "local_left_bracket=$local_left_bracket"
    local_right_bracket=`echo $line | grep -i ")"`
    echo "local_right_bracket=$local_right_bracket"
    local_comment=`echo $line | grep -i "\#"`
    echo "local_comment=$local_comment"
    local_minus=`echo $line | grep -i "^-"`
    echo "local_minus=$local_minus"
    local_open_bracket=`echo $line | grep -i "\["`
    echo "local_open_bracket=$local_open_bracket"
    local_close_bracket=`echo $line | grep -i "]"`
    echo "local_close_bracket=$local_close_bracket"
    if [[ ! -z $local_minus ]]; then
        echo "#############################################"
        echo "Warning: $line file name have a prefix "-", must change name"
        echo "#############################################"
    fi
    
    if [[ ! -z $local_space ]]; then
        echo "contian space"
        s_space="\ "
        line=`echo $line | sed -e "s/$s_space/\_/g"`
    echo $line
    fi
    if [[ ! -z $local_left_bracket ]]; then
        echo "contain left bracket"
        s_left_bracket="("
        line=`echo $line | sed -e "s/$s_left_bracket/\_/g"`
    echo $line
    fi
    if [[ ! -z $local_right_bracket ]]; then
        echo "contain right bracket"
        s_right_bracket=")"
        line=`echo $line | sed -e "s/$s_right_bracket/\_/g"`
    echo $line
    fi
    if [[ ! -z $local_comment ]]; then
        echo "contain comment mark"
        s_comment="\#"
        line=`echo $line | sed -e "s/$s_comment/\_/g"`
    echo $line
    fi
    if [[ ! -z $local_minus ]]; then
        echo "contain minus mark"
        s_minus="\-"
        line=`echo $line | sed -e "s/$s_minus/\_/g"`
    echo $line
    fi
    if [[ ! -z $local_open_bracket ]]; then
        echo "contain open bracket mark"
        s_open_bracket="\["
        line=`echo $line | sed -e "s/$s_open_bracket/\_/g"`
    echo $line
    fi
    if [[ ! -z $local_close_bracket ]]; then
        echo "contain close_bracket  mark"
        s_close_bracket="]"
        line=`echo $line | sed -e "s/$s_close_bracket/\_/g"`
    echo $line
    fi
    echo $tmp
    echo $line
    
    if [[ ! -z $local_space ]] || [[ ! -z $local_left_bracket ]] \
       || [[ ! -z $local_right_bracket ]] || [[ ! -z $local_comment ]] \
       || [[ ! -z $local_minus ]] || [[ ! -z $local_open_bracket ]] || [[ ! -z $local_close_bracket ]];then
        echo $tmp
        echo $line
        if [[ -f $line ]]; then
            echo "There is the same modified name: "$line""
            check_exist=`ls | grep -i "SRDCQA-.*-$line"`
            echo "check_exist=$check_exist"
            if [[ ! -z $check_exist ]]; then
                echo "There is a prefix "SRDCQA-number-$line",so change to "SRDCQA-number+1-$line""
                count=`ls | grep -i "SRDCQA-.*-$line" | awk -F "-" '{print $2}' | sort -n | tail -1  `
                echo "count=$count"
                let count+=1
                echo "count=$count"
                mv ./"$tmp" "SRDCQA-$count-$line" 
                if [[ $? == 0 ]]; then 
                    echo "Modify name successfully,"
                    echo "######################################################################"
                    echo "BEGIN $tmp"
                    echo "END "SRDCQA-$count-$line" "
                    echo -e  "[Invalid][Success] "$tmp" ---> "SRDCQA-$count-$line"" >> "$HOME/$local_saved_directory/$step_name_suffix/Step1-Check_name_is_valid.txt" 
                else 
                    echo "Failed to modify name"
                    echo "######################################################################"
                    echo "BEGIN $tmp"
                    echo "END exit -1"
                    rm -rf ls.txt
                    echo -e  "[Invalid][Failure] "$tmp" ---> "SRDCQA-$count-$line"" >> "$HOME/$local_saved_directory/$step_name_suffix/Step1-Check_name_is_valid.txt" 
                    echo "ERROR: file name is invalid.please check key [Invalid][Failure] in $HOME/$local_saved_directory/$step_name_suffix/Step1-Check_name_is_valid.txt"
                    echo "######################Failure: file_name_is_invalid"
                    echo "######################please contact Ming.Dong, let him change the file name manually"
                    echo "`cat "$HOME/$local_saved_directory/$step_name_suffix/Step1-Check_name_is_valid.txt" | grep -i   "[Invalid][Failure]"`"
                    echo -e "\n\n"
                    exit -1
                fi
            else 
                echo "Not contain SRDCQA, directly change to "SRDCQA-1-$line""
                mv ./"$tmp" "SRDCQA-1-$line" 
                if [[ $? == 0 ]]; then 
                    echo "Modify name successfully,"
                    echo "######################################################################"
                    echo "BEGIN $tmp"
                    echo "END "SRDCQA-1-$line""
                    echo -e  "[Invalid][Success] "$tmp" ---> "SRDCQA-1-$line"" >> "$HOME/$local_saved_directory/$step_name_suffix/Step1-Check_name_is_valid.txt" 
                else 
                    echo "Failed to modify name"
                    echo "######################################################################"
                    echo "BEGIN $tmp"
                    echo "END exit -1"
                    rm -rf ls.txt					
                    echo -e  "[Invalid][Failure] "$tmp" ---> "SRDCQA-1-$line"" >> "$HOME/$local_saved_directory/$step_name_suffix/Step1-Check_name_is_valid.txt" 
                    echo "ERROR: file name is invalid.please check key [Invalid][Failure] in $HOME/$local_saved_directory/$step_name_suffix/Step1-Check_name_is_valid.txt"
                    echo "######################Failure: file_name_is_invalid"
                    echo "######################please contact Ming.Dong, let him change the file name manually"
                    echo "`cat "$HOME/$local_saved_directory/$step_name_suffix/Step1-Check_name_is_valid.txt" | grep -i   "[Invalid][Failure]"`"
                    echo -e "\n\n"
                    exit -1
                fi
            fi
        else
            echo "normal modified name"
            mv ./"$tmp" $line
                if [[ $? == 0 ]]; then 
                    echo "Modify name successfully,"
                    echo "######################################################################"
                    echo "BEGIN $tmp"
                    echo "END $line"
                    echo -e  "[Invalid][Success] "$tmp" ---> "$line"" >> "$HOME/$local_saved_directory/$step_name_suffix/Step1-Check_name_is_valid.txt" 
                else 
                    echo "Failed to modify name"
                    echo "######################################################################"
                    echo "BEGIN $tmp"
                    echo "END exit -1"
                    echo -e  "[Invalid][Failure] "$tmp" ---> "$line"" >> "$HOME/$local_saved_directory/$step_name_suffix/Step1-Check_name_is_valid.txt" 
                    rm -rf ls.txt					
                    echo "ERROR: file name is invalid.please check key [Invalid][Failure] in $HOME/$local_saved_directory/$step_name_suffix/Step1-Check_name_is_valid.txt"
                    echo "######################Failure: file_name_is_invalid"
                    echo "######################please contact Ming.Dong, let him change the file name manually"
                    echo "`cat "$HOME/$local_saved_directory/$step_name_suffix/Step1-Check_name_is_valid.txt" | grep -i   "[Invalid][Failure]"`"
                    echo -e "\n\n"
                    exit -1
                fi
        fi
    else
        echo "There is no space/(/)/^-/# in the file name"
        echo "######################################################################"
        echo "BEGIN $tmp"
        echo "END $line"
        echo -e  "[Vaild] "$tmp" ---> "$line"" >> "$HOME/$local_saved_directory/$step_name_suffix/Step1-Check_name_is_valid.txt" 
    fi 
    echo -e "\n\n"
    done < ls.txt
    
    rm -rf ls.txt
    ls -lh
    file_name_is_valid=true
    echo -e "##############################"
    echo -e "#####END check_file_name_is_valid "
    echo -e "###############################\n\n"
}

function global_variable_configure_default(){
    echo -e "##############################"
    echo -e "#####global_variable_configure_default"
    echo -e "###############################"

    # check whether mediainfo contain  general/video/audio/audio 1/audio 2 track type.
    local_general=
    local_video=
    local_audio=
    local_audio_1=
    local_audio_2=
    local_menu=

    #if corresponding track type exist, calculate the line number of this track type.
    local_general_line=
    local_video_line=
    local_audio_line=
    local_audio1_line=
    local_audio2_line=
    local_menu_line=
    #calculate the arrange between  track type "general"  and track type behind "general"
    general_line_arrange=
    #calculate the arrange between  track type "video"  and track type "audio"
    video_audio_line_arrange=
    audio_menu_line_arrange=
    #calculate the arrange between  track type "video"  and track type "audio1"
    video_audio1_line_arrange=
    #calculate the arrange between  track type "audio1"  and track type "audio2"
    auido1_audio2_line_arrange=

    # 3 conditions of track type
    video_audio=
    video_audio1_audio2=
    only_video=
    menu_exist=
    
    # video parameter unit
    video_bitrate_unit=
    video_framerate_unit=

    ##### Video and Audio parameters
    #General
    name_part1_local_general_format=
    #Video
    name_part2_local_video_format=
    name_part3_local_video_width=
    name_part4_local_video_height=
    name_part3_part4_local_video_width_height=
    name_part5_local_video_framerate=
    name_part6_local_video_bitrate=
    name_part22_local_video_profile=
    name_part23_local_video_level=
    #Audio
    name_part7_local_audio_format=
    name_part8_local_audio_format_profile=
    name_part9_local_audio_samplingrate=
    name_part10_local_audio_bitrate=
    name_part11_local_audio_channel=
    name_part12_local_audio1_format=
    name_part13_local_audio1_format_profile=
    name_part14_local_audio1_samplingrate=
    name_part15_local_audio1_bitrate=
    name_part16_local_audio1_channel=
    name_part17_local_audio2_format=
    name_part18_local_audio2_format_profile=
    name_part19_local_audio2_samplingrate=
    name_part20_local_audio2_bitrate=
    name_part21_local_audio2_channel=
    name_suffix_local_general_FileExtension=

    # create directory
    classification_directory_name=
    display_resolution=
    
    # final name
    final_name_as_per_name_rule=
    final_name_as_per_name_rule_prefix=
    final_name_as_per_name_rule_suffix=
    # flag of continue
    continue_flag=
    # flag of fit file
    fit_file=
    echo -e "##############################"
    echo -e "#####END global_variable_configure_default "
    echo -e "###############################\n\n"
}

function print_track_type(){
    echo -e "##############################"
    echo -e "#####print_track_type"
    echo -e "###############################"

    #  print track type
    echo "local_general=[$local_general]"
    echo "local_video=[$local_video]"
    echo "local_audio=[$local_audio]"
    echo "local_audio_1=[$local_audio_1]"
    echo "local_audio_2=[$local_audio_2]"
    echo "menu_exist=[$menu_exist]"
    

    echo -e "##############################"
    echo -e "#####END print_track_type"
    echo -e "##############################\n\n"
}

function print_track_type_line(){
    echo -e "##############################"
    echo -e "#####print_track_type_line"
    echo -e "###############################"

    # print the line number of track type
    echo "local_general_line=[$local_general_line]" 
    echo "local_video_line=[$local_video_line]" 
    echo "local_audio_line=[$local_audio_line]"
    echo "local_audio1_line=[$local_audio1_line]"
    echo "local_audio2_line=[$local_audio2_line]"
    echo "local_menu_line=[$local_menu_line]"

    echo -e "##############################"
    echo -e "#####END print_track_type_line"
    echo -e "##############################\n\n"
}

function print_track_type_line_arrange(){
    echo -e "##############################"
    echo -e "#####print_track_type_line_arrange"
    echo -e "###############################"

    # print arrange of track type
    echo "general_line_arrange=[$general_line_arrange]" 
    echo "video_audio_line_arrange=[$video_audio_line_arrange]"
    echo "video_audio1_line_arrange=[$video_audio1_line_arrange]"
    echo "auido1_audio2_line_arrange=[$auido1_audio2_line_arrange]"

    echo -e "##############################"
    echo -e "#####END print_track_type_line_arrange"
    echo -e "##############################\n\n"
}

function print_three_conditions_of_track_type(){
    echo -e "##############################"
    echo -e "#####print_three_conditions_of_track_type"
    echo -e "###############################"

    # print 3 conditions of track type
    echo "only_video=[$only_video]" 
    echo "video_audio=[$video_audio]"
    echo "video_audio1_audio2=[$video_audio1_audio2]"

    echo -e "##############################"
    echo -e "#####END print_three_conditions_of_track_type"
    echo -e "##############################\n\n"
}

function check_track_type(){
    echo -e "##############################"
    echo -e "#####check_track_type "
    echo -e "###############################"
    local_general=`mediainfo -f --${lower_upper_output}=XML "$a" | grep -ni "track type.*general"`
    local_video=`mediainfo -f --${lower_upper_output}=XML "$a" | grep -ni "track type.*video"`
    local_audio=`mediainfo -f --${lower_upper_output}=XML "$a" | grep -ni "track type.*audio\">"`
    local_audio_1=`mediainfo -f --${lower_upper_output}=XML "$a" | grep -ni "track type.*audio.*1"`
    local_audio_2=`mediainfo -f --${lower_upper_output}=XML "$a" | grep -ni "track type.*audio.*2"`
    local_menu=`mediainfo -f --${lower_upper_output}=XML "$a" | grep -ni "track type.*Menu"`
    if [[ -z $local_menu ]]; then
        menu_exist=false
    else
        menu_exist=true
    fi
    print_track_type
   
    # First condition: track type general + video
    if [[ ! -z $local_general ]] && [[ ! -z $local_video ]] \
       && [[ -z $local_audio ]]  && [[ -z $local_menu ]]    \
       && [[ -z $local_audio_1 ]] && [[ -z $local_audio_2 ]]; then 
        only_video=true
    fi 
    # Second condition: track type general + video + audio
    if [[ ! -z $local_general ]] && [[ ! -z $local_video ]] \
       && [[ ! -z $local_audio ]] && [[ -z $local_menu ]]  \
       && [[ -z $local_audio_1 ]] && [[ -z $local_audio_2 ]]; then 
        video_audio=true
    fi 
    if [[ ! -z $local_general ]] && [[ ! -z $local_video ]] \
       && [[ ! -z $local_audio ]] && [[ ! -z $local_menu ]] \
       && [[ -z $local_audio_1 ]] && [[ -z $local_audio_2 ]]; then 
        video_audio=true
    fi 
    # Third condition: track type general + video + audio1 + audio2
    if [[ ! -z $local_general ]] && [[ ! -z $local_video ]] \
       && [[ -z $local_audio ]]  && [[ -z $local_menu ]]    \
       && [[ ! -z $local_audio_1 ]] && [[ ! -z $local_audio_2 ]]; then 
        video_audio1_audio2=true
    fi 
    print_three_conditions_of_track_type
     
    echo -e "##############################"
    echo -e "#####END check_track_type"
    echo -e "###############################\n\n"
}

function calculate_track_type_line_arrange(){
    echo -e "##############################"
    echo -e "#####calculate_track_type_line_arrange"
    echo -e "###############################"
    if [[ ! -z $only_video ]]; then
        local_general_line=`mediainfo -f --${lower_upper_output}=XML "$a" | grep -ni "track type.*general" |awk -F ":" '{print $1}'`
        local_video_line=`mediainfo -f --${lower_upper_output}=XML "$a" | grep -ni "track type.*video" |awk -F ":" '{print $1}'`
        general_line_arrange=$(( $local_video_line - $local_general_line ))
    fi 
    if [[ ! -z $video_audio ]]; then
        local_general_line=`mediainfo -f --${lower_upper_output}=XML "$a" | grep -ni "track type.*general" |awk -F ":" '{print $1}'`
        local_video_line=`mediainfo -f --${lower_upper_output}=XML "$a" | grep -ni "track type.*video" |awk -F ":" '{print $1}'`
        local_audio_line=`mediainfo -f --${lower_upper_output}=XML "$a" | grep -ni "track type.*audio\">" |awk -F ":" '{print $1}'`
        general_line_arrange=$(( $local_video_line - $local_general_line ))
        video_audio_line_arrange=$(( $local_audio_line  - $local_video_line  ))
        if [[ $menu_exist == true ]]; then
            local_menu_line=`mediainfo -f --${lower_upper_output}=XML "$a" | grep -ni "track type.*menu\">" |awk -F ":" '{print $1}'`
            audio_menu_line_arrange=$(( $local_menu_line  - $local_audio_line  ))
        fi
    fi 
    if [[ ! -z $video_audio1_audio2 ]]; then
        local_general_line=`mediainfo -f --${lower_upper_output}=XML "$a" | grep -ni "track type.*general" |awk -F ":" '{print $1}'`
        local_video_line=`mediainfo -f --${lower_upper_output}=XML "$a" | grep -ni "track type.*video" |awk -F ":" '{print $1}'`
        local_audio1_line=`mediainfo -f --${lower_upper_output}=XML "$a" | grep -ni "track type.*audio.*1" |awk -F ":" '{print $1}'`
        local_audio2_line=`mediainfo -f --${lower_upper_output}=XML "$a" | grep -ni "track type.*audio.*2" |awk -F ":" '{print $1}'`
        general_line_arrange=$(( $local_video_line - $local_general_line ))
        video_audio1_line_arrange=$(( $local_audio1_line - $local_video_line ))
        auido1_audio2_line_arrange=$(( $local_audio2_line - $local_audio1_line ))
    fi
    print_track_type_line
    print_track_type_line_arrange
    echo -e "##############################"
    echo -e "#####END calculate_track_type_line_arrange"
    echo -e "###############################\n\n"
}

function parse_general(){
    # <track type="General">              <==> local_general
    # <FileExtension>mp4</FileExtension>  <==> name_suffix_local_general_FileExtension
    # <Format>MPEG-4</Format>             <==> name_part1_local_general_format
    echo -e "##############################"
    echo -e "#####parse_general"
    echo -e "###############################"

    name_part1_local_general_format=`mediainfo -f --${lower_upper_output}=XML "$a" |grep -i "track type.*general" -A $general_line_arrange | grep -i "<Format>.*<\/Format>" | awk -F "<" '{print $2}' | awk -F ">" '{print $2}'`
    if [[ ! -z $name_part1_local_general_format ]]; then
        name_part1_local_general_format=`echo "$name_part1_local_general_format" | sed -e "s/\ /-/g"`
    fi
    echo "name_part1_local_general_format=$name_part1_local_general_format"
    
    name_suffix_local_general_FileExtension=`mediainfo -f --${lower_upper_output}=XML "$a" |grep -i "track type.*general" -A $general_line_arrange | grep -i "<FileExtension>.*<\/FileExtension>" | awk -F "<" '{print $2}' | awk -F ">" '{print $2}'`
    echo "name_suffix_local_general_FileExtension=$name_suffix_local_general_FileExtension"

    echo -e "##############################"
    echo -e "#####END parse_general"
    echo -e "###############################\n\n"
}

function print_video_parameter(){
    echo -e "##############################"
    echo -e "#####print_video_parameter"
    echo -e "###############################"
    
    echo "name_part2_local_video_format=$name_part2_local_video_format"
    echo "name_part3_local_video_width=$name_part3_local_video_width"
    echo "name_part4_local_video_height=$name_part4_local_video_height"
    echo "name_part5_local_video_framerate=$name_part5_local_video_framerate"
    echo "name_part6_local_video_bitrate=$name_part6_local_video_bitrate"
    echo "name_part3_part4_local_video_width_height=$name_part3_part4_local_video_width_height"

    echo -e "##############################"
    echo -e "#####END print_video_parameter"
    echo -e "###############################\n\n"

}

function parse_classification_directory_name(){
    echo -e "##############################"
    echo -e "#####parse_classification_directory_name"
    echo -e "###############################"

    #classification_directory_name
    tmp=`echo "$name_part2_local_video_format" | sed -e "s/\ /-/g"`
    if [[ $tmp == [aA][vV][cC] ]]; then
        classification_directory_name=H264
    fi
    if [[ $tmp == [hH][eE][vV][cC] ]]; then
        classification_directory_name=H265
    fi
    if [[ $tmp == [mM][pP][eE][gG]*4*[vV][iI][sS][uU][aA][lL] ]]; then
        classification_directory_name=DIVX
        name_part2_local_video_format=DIVX
    fi
    if [[ $tmp == [mM][pP][eE][gG]*[vV][iI][dD][eE][oO] ]]; then
        classification_directory_name=MPEG
    fi


    echo -e "##############################"
    echo -e "#####END parse_classification_directory_name"
    echo -e "###############################\n\n"
}

function parse_video_display_resolution(){
    echo -e "##############################"
    echo -e "#####parse_video_display_resolution"
    echo -e "###############################"

        # 16K:   15360x  or  16200x or 16384x or 16640x
        # 8K:    7680x  or 8192x
        # 4K:    3840x2160 or 4096x2160 
        # 2K:    2048x1080
        # 1440P: 2560x1440
        # 1080P: 1920x1080 1920x1088
        # 720P:  1280x720
        # 480P:  854x480
        # 360P:  640x360
        if [[ $name_part3_local_video_width == 15360 ]] || [[ $name_part3_local_video_width == 16200 ]] \
           || [[ $name_part3_local_video_width == 16384 ]] || [[ $name_part3_local_video_width == 16640 ]]; then
            display_resolution=16K
        fi
        if [[ $name_part3_local_video_width == 8192 ]] || [[ $name_part3_local_video_width == 7680 ]]; then
            display_resolution=8K
        fi
        #if [[ $name_part3_local_video_width == 7680 ]] && [[ $name_part4_local_video_height == 4320 ]]; then
        #    display_resolution=8K
        #fi
        if [[ $name_part3_local_video_width == 3840 || $name_part3_local_video_width == 4096 || $name_part3_local_video_width == 3996 ]] && [[ $name_part4_local_video_height == 2160 ]]; then
            display_resolution=4K
        fi
        if [[ $name_part3_local_video_width == 2048 ]] && [[ $name_part4_local_video_height == 1080 ]]; then
            display_resolution=2K
        fi
        if [[ $name_part3_local_video_width == 2560 ]] && [[ $name_part4_local_video_height == 1440 ]]; then
            display_resolution=1440P
        fi
        if [[ $name_part3_local_video_width == 1920 || $name_part3_local_video_width == 1440 ]] && [[ $name_part4_local_video_height == 1080 || $name_part4_local_video_height == 1088 ]]; then
            display_resolution=1080P
        fi
        if [[ $name_part3_local_video_width == 1280 ]] && [[ $name_part4_local_video_height == 720 ]]; then
            display_resolution=720P
        fi
        if [[ $name_part4_local_video_height == 576 ]]; then
            display_resolution=576P
        fi
        if [[ $name_part4_local_video_height == 480 ]]; then
            display_resolution=480P
        fi
        if [[ $name_part4_local_video_height == 360 ]]; then
            display_resolution=360P
        fi
        if [[ $name_part4_local_video_height == 288 ]]; then
            display_resolution=288P
        fi
        if [[ $name_part3_local_video_width == 480 ]] && [[ $name_part4_local_video_height == 272 ]]; then
            display_resolution=288P
        fi
        if [[ $name_part4_local_video_height == 240 ]]; then
            display_resolution=240P
        fi
        if [[ $name_part4_local_video_height == 144 ]]; then
            display_resolution=144P
        fi
        if [[ $name_part4_local_video_height == 180 ]]; then
            display_resolution=180P
        fi
        if [[ $name_part4_local_video_height == 120 ]]; then
            display_resolution=120P
        fi
        if [[ $name_part4_local_video_height == 96 ]]; then
            display_resolution=96P
        fi
         

    echo -e "##############################"
    echo -e "#####END parse_video_display_resolution"
    echo -e "###############################\n\n"

}

function parse_video(){
    # $1: line_arrange

    # <track type="Video">                    <==> local_video
    # <Format>HEVC</Format>                   <==> name_part2_local_video_format
    # <BitRate>8820599</BitRate>              <==> name_part6_local_video_bitrate 
    # <Width>3840</Width>                     <==> name_part3_local_video_width 
    # <Height>2160</Height>                   <==> name_part4_local_video_height
    # <FrameRate>24.000</FrameRate>           <==> name_part5_local_video_framerate
    # <Format_Profile>High</Format_Profile>   <==> name_part22_local_video_profile
    # <Format_Level>5.1</Format_Level>        <==> name_part23_local_video_level
 
 
    echo -e "##############################"
    echo -e "#####parse_video"
    echo -e "###############################"
  
    name_part2_local_video_format=`mediainfo -f --${lower_upper_output}=XML "$a" |grep -i "track type.*video" -A $1 | grep -i "<Format>.*<\/Format>" | awk -F "<" '{print $2}' | awk -F ">" '{print $2}'`
    if [[ ! -z $name_part2_local_video_format ]]; then
        classification_directory_name=`echo "$name_part2_local_video_format" | sed -e "s/\ /-/g"`
        parse_classification_directory_name 
        name_part2_local_video_format=`echo "$name_part2_local_video_format" | sed -e "s/\ /-/g" | sed -e "s/^/_&/g"`
        
    fi
    name_part3_local_video_width=`mediainfo -f --${lower_upper_output}=XML "$a" |grep -i "track type.*video" -A $1 | grep -i "<Width>.*<\/Width>" | awk -F "<" '{print $2}' | awk -F ">" '{print $2}'`
    name_part4_local_video_height=`mediainfo -f --${lower_upper_output}=XML "$a" |grep -i "track type.*video" -A $1 | grep -i "<Height>.*<\/Height>" | awk -F "<" '{print $2}' | awk -F ">" '{print $2}'`
    if [[ ! -z $name_part3_local_video_width ]] && [[ ! -z $name_part4_local_video_height ]]; then
        name_part3_part4_local_video_width_height=`echo "$name_part3_local_video_width"x"$name_part4_local_video_height" | sed -e "s/\ /-/g" | sed -e "s/^/_&/g"`
        parse_video_display_resolution 
    fi
    name_part5_local_video_framerate=`mediainfo -f --${lower_upper_output}=XML "$a" |grep -i "track type.*video" -A $1 | grep -i "<FrameRate>.*<\/FrameRate>" | awk -F "<" '{print $2}' | awk -F ">" '{print $2}'`
    if [[ ! -z $name_part5_local_video_framerate ]]; then
        name_part5_local_video_framerate=`echo "scale=1;$name_part5_local_video_framerate/1" |bc`
        video_framerate_unit=fps
        name_part5_local_video_framerate=`echo "$name_part5_local_video_framerate" | sed -e "s/\ /-/g" | sed -e "s/^/_&/g"`"$video_framerate_unit"
    fi 
    name_part6_local_video_bitrate=`mediainfo -f --${lower_upper_output}=XML "$a" |grep -i "track type.*video" -A $1 | grep -i "<BitRate>.*<\/BitRate>" | awk -F "<" '{print $2}' | awk -F ">" '{print $2}'`
    print_video_parameter
    if [[ ! -z $name_part6_local_video_bitrate ]]; then 
        temp=`echo "scale=0;$name_part6_local_video_bitrate/1" |bc`
        if [[ $temp -lt 1000 ]]; then
            video_bitrate_unit=bps
            name_part6_local_video_bitrate=`echo "$name_part6_local_video_bitrate" | sed -e "s/\ /-/g" | sed -e "s/^/_&/g"`"$video_bitrate_unit"
            echo "name_part6_local_video_bitrate=$name_part6_local_video_bitrate"
        fi 
         
        if [[ $temp -ge 1000 ]] && [[ $temp -lt 10000000 ]]; then
            #name_part6_local_video_bitrate=`echo "scale=1;$name_part6_local_video_bitrate/1000" |bc `
            name_part6_local_video_bitrate=`echo $name_part6_local_video_bitrate |awk '{printf ("%d",$1/1000+0.5)}'`
            video_bitrate_unit=Kbps     
            name_part6_local_video_bitrate=`echo "$name_part6_local_video_bitrate" | sed -e "s/\ /-/g" | sed -e "s/^/_&/g"`"$video_bitrate_unit"
            echo "name_part6_local_video_bitrate=$name_part6_local_video_bitrate"
        fi 
        if [[  $temp -ge 10000000 ]]; then
            #name_part6_local_video_bitrate=`echo "scale=1;$name_part6_local_video_bitrate/1000000" |bc `
            name_part6_local_video_bitrate=`echo $name_part6_local_video_bitrate |awk '{printf ("%d",$1/1000000+0.5)}'`
            video_bitrate_unit=Mbps
            name_part6_local_video_bitrate=`echo "$name_part6_local_video_bitrate" | sed -e "s/\ /-/g" | sed -e "s/^/_&/g"`"$video_bitrate_unit"
            echo "name_part6_local_video_bitrate=$name_part6_local_video_bitrate"
        fi
    fi
    echo "video_framerate_unit=[$video_framerate_unit]"
    echo "video_bitrate_unit=[$video_bitrate_unit]"
        
    if [[ $classification_directory_name == H264 ]] || [[ $classification_directory_name == H265 ]]; then

        name_part22_local_video_profile=`mediainfo -f --${lower_upper_output}=XML "$a" | grep -i "track type.*video" -A $1 | grep -i "<Format_Profile>.*<\/Format_Profile>" | awk -F "<" '{print $2}' | awk -F ">" '{print $2}'`
        echo "$classification_directory_name: Before name_part22_local_video_profile=[$name_part22_local_video_profile]"
        if [[ ! -z $name_part22_local_video_profile ]]; then
            name_part22_local_video_profile="_Profile"`echo "$name_part22_local_video_profile" | sed -e "s/\ /-/g" | sed -e "s/^/_&/g"`
        fi
        echo "$classification_directory_name: After name_part22_local_video_profile=[$name_part22_local_video_profile]"

        name_part23_local_video_level=`mediainfo -f --${lower_upper_output}=XML "$a" | grep -i "track type.*video" -A $1 | grep -i "<Format_Level>.*<\/Format_Level>" | awk -F "<" '{print $2}' | awk -F ">" '{print $2}'`
        echo "$classification_directory_name: Before name_part23_local_video_level=[$name_part23_local_video_level]"
        if [[ ! -z $name_part23_local_video_level ]]; then
            name_part23_local_video_level="_level"`echo "$name_part23_local_video_level" | sed -e "s/\ /-/g" | sed -e "s/^/_&/g"`
        fi
        echo "$classification_directory_name: After name_part23_local_video_level=[$name_part23_local_video_level]"
    fi
    if [[ $classification_directory_name == [Vv][Pp]9 ]]; then
        pwd
        ffprobe -report $2 
        ls ffprobe*.log
        #name_part22_local_video_profile=`cat ffprobe*.log  | grep "Video: vp9" | awk -F "\(" '{print $3}' | awk -F "\)" '{print $1}' | sed -e "s/\ /_/g" | sed -e "s/^/_&/g"`
        name_part22_local_video_profile=`cat ffprobe*.log  | grep "Video: vp9" | awk -F "Video: vp9 \("  '{print $2}' | awk -F "\)" '{print $1}' | sed -e "s/\ /_/g" | sed -e "s/^/_&/g"`
        rm -rf ffprobe*.log
        echo "$classification_directory_name: name_part22_local_video_profile=[$name_part22_local_video_profile]"

    fi
    
    echo -e "##############################"
    echo -e "#####END parse_video"
    echo -e "###############################\n\n"
}

function parse_audio(){ 
    echo -e "##############################"
    echo -e "#####parse_audio"
    echo -e "###############################"
    # $1: line_arrange from audio line to end
    # <track type="Audio">                 <==> local_audio
    # <Format>AAC</Format>                 <==> name_part7_local_audio_format
    # <Format_Profile>LC</Format_Profile>  <==> name_part8_local_audio_format_profile
    # <BitRate>317375</BitRate>            <==> name_part10_local_audio_bitrate
    # <Channels>2</Channels>               <==> name_part11_local_audio_channel
    # <SamplingRate>48000</SamplingRate>   <==> name_part9_local_audio_samplingrate
 
    name_part7_local_audio_format=`mediainfo -f --${lower_upper_output}=XML "$a" |grep -i "track type.*audio\">" -A $1  | grep -i "<Format>.*<\/Format>" | awk -F "<" '{print $2}' | awk -F ">" '{print $2}'`
    if [[ ! -z $name_part7_local_audio_format ]]; then
        name_part7_local_audio_format=`echo "$name_part7_local_audio_format" | sed -e "s/\ /-/g" | sed -e "s/^/_&/g"`
    fi
    echo "name_part7_local_audio_format=$name_part7_local_audio_format"
    name_part8_local_audio_format_profile=`mediainfo -f --${lower_upper_output}=XML "$a" |grep -i "track type.*audio\">" -A $1 | grep -i "<Format_Profile>.*<\/Format_Profile>" | awk -F "<" '{print $2}' | awk -F ">" '{print $2}'`
    if [[ ! -z $name_part8_local_audio_format_profile ]]; then
        name_part8_local_audio_format_profile=`echo "$name_part8_local_audio_format_profile" | sed -e "s/\ /-/g" | sed -e "s/^/_&/g"`
    fi
    echo "name_part8_local_audio_format_profile=$name_part8_local_audio_format_profile"
    name_part9_local_audio_samplingrate=`mediainfo -f --${lower_upper_output}=XML "$a" |grep -i "track type.*audio\">" -A $1 | grep -i "<SamplingRate>.*<\/SamplingRate>" | awk -F "<" '{print $2}' | awk -F ">" '{print $2}'`
    echo "name_part9_local_audio_samplingrate=$name_part9_local_audio_samplingrate"
    if [[ ! -z name_part9_local_audio_samplingrate ]]; then 
        temp=`echo "scale=0;$name_part9_local_audio_samplingrate/1" |bc`
        if [[ $temp -lt 1000 ]]; then
           audio_SamplingRate_unit=Hz 
           name_part9_local_audio_samplingrate=`echo "$name_part9_local_audio_samplingrate" | sed -e "s/\ /-/g" | sed -e "s/^/_&/g"`"$audio_SamplingRate_unit"
        fi 
        
        if [[ $temp -ge 1000 ]] && [[ $temp -lt 10000000 ]]; then
            name_part9_local_audio_samplingrate=`echo "scale=1;$name_part9_local_audio_samplingrate/1000" |bc `
            audio_SamplingRate_unit=KHz    
            name_part9_local_audio_samplingrate=`echo "$name_part9_local_audio_samplingrate" | sed -e "s/\ /-/g" | sed -e "s/^/_&/g"`"$audio_SamplingRate_unit"
            echo "name_part9_local_audio_samplingrate=$name_part9_local_audio_samplingrate"
        fi 
        if [[  $temp -ge 10000000 ]]; then
            name_part9_local_audio_samplingrate=`echo "scale=1;$name_part9_local_audio_samplingrate/1000000" |bc `
            audio_SamplingRate_unit=MHz
            name_part9_local_audio_samplingrate=`echo "$name_part9_local_audio_samplingrate" | sed -e "s/\ /-/g" | sed -e "s/^/_&/g"`"$audio_SamplingRate_unit"
            echo "name_part9_local_audio_samplingrate=$name_part9_local_audio_samplingrate"
        fi
    fi 
    name_part10_local_audio_bitrate=`mediainfo -f --${lower_upper_output}=XML "$a" |grep -i "track type.*audio\">" -A $1 | grep -i "<BitRate>.*<\/BitRate>" | awk -F "<" '{print $2}' | awk -F ">" '{print $2}'`
    echo "name_part10_local_audio_bitrate=$name_part10_local_audio_bitrate"
    if [[ ! -z $name_part10_local_audio_bitrate ]]; then 
        temp=`echo "scale=0;$name_part10_local_audio_bitrate/1" |bc`
        if [[ $temp -lt 1000 ]]; then
            audio_bitrate_unit=bps     
            name_part10_local_audio_bitrate=`echo "$name_part10_local_audio_bitrate" | sed -e "s/\ /-/g" | sed -e "s/^/_&/g"`"$audio_bitrate_unit"
        fi 
        
        if [[ $temp -ge 1000 ]] && [[ $temp -lt 10000000 ]]; then
            name_part10_local_audio_bitrate=`echo "scale=1;$name_part10_local_audio_bitrate/1000" |bc `
            audio_bitrate_unit=Kbps     
            name_part10_local_audio_bitrate=`echo "$name_part10_local_audio_bitrate" | sed -e "s/\ /-/g" | sed -e "s/^/_&/g"`"$audio_bitrate_unit"
            echo "name_part10_local_audio_bitrate=$name_part10_local_audio_bitrate"
        fi 
        if [[  $temp -ge 10000000 ]]; then
            name_part10_local_audio_bitrate=`echo "scale=1;$name_part10_local_audio_bitrate/1000000" |bc `
            audio_bitrate_unit=Mbps
            name_part10_local_audio_bitrate=`echo "$name_part10_local_audio_bitrate" | sed -e "s/\ /-/g" | sed -e "s/^/_&/g"`"$audio_bitrate_unit"
            echo "name_part10_local_audio_bitrate=$name_part10_local_audio_bitrate"
        fi
    fi 
    name_part11_local_audio_channel=`mediainfo -f --${lower_upper_output}=XML "$a" |grep -i "track type.*audio\">" -A $1  | grep -i "<Channels>.*<\/Channels>" | awk -F "<" '{print $2}' | awk -F ">" '{print $2}'`
    echo "name_part11_local_audio_channel=$name_part11_local_audio_channel"
    if [[ ! -z $name_part11_local_audio_channel ]]; then
        audio_channel_unit=ch
        name_part11_local_audio_channel=`echo "$name_part11_local_audio_channel" | sed -e "s/\ /-/g" | sed -e "s/^/_&/g"`"$audio_channel_unit"
        echo "name_part11_local_audio_channel=$name_part11_local_audio_channel"
    fi
    echo "audio_SamplingRate_unit=[$audio_SamplingRate_unit]"
    echo "audio_bitrate_unit=[$audio_bitrate_unit]"
    echo "audio_channel_unit=[$audio_channel_unit]"

    echo -e "##############################"
    echo -e "#####END parse_audio"
    echo -e "###############################\n\n"
}


function parse_audio_1(){ 
    echo -e "##############################"
    echo -e "#####parse_audio_1"
    echo -e "###############################"
    # $1: line_arrange from audio line to end
    # <track type="Audio" typeorder="1">       <==> local_audio_1
    # <Format>MPEG Audio</Format>              <==> name_part12_local_audio1_format
    # <Format_Profile>Layer 3</Format_Profile> <==> name_part13_local_audio1_format_profile
    # <BitRate>160000</BitRate>                <==> name_part15_local_audio1_bitrate
    # <Channels>2</Channels>                   <==> name_part16_local_audio1_channel
    # <SamplingRate>48000</SamplingRate>       <==> name_part14_local_audio1_samplingrate
 
    name_part12_local_audio1_format=`mediainfo -f --${lower_upper_output}=XML "$a" |grep -i "track type.*audio.*1" -A $1  | grep -i "<Format>.*<\/Format>" | awk -F "<" '{print $2}' | awk -F ">" '{print $2}'`
    if [[ ! -z $name_part12_local_audio1_format ]]; then
        name_part12_local_audio1_format=`echo "$name_part12_local_audio1_format" | sed -e "s/\ /-/g" | sed -e "s/^/_&/g"`
    fi
    echo "name_part12_local_audio1_format=$name_part12_local_audio1_format"
    name_part13_local_audio1_format_profile=`mediainfo -f --${lower_upper_output}=XML "$a" |grep -i "track type.*audio.*1" -A $1 | grep -i "<Format_Profile>.*<\/Format_Profile>" | awk -F "<" '{print $2}' | awk -F ">" '{print $2}'`
    if [[ ! -z $name_part13_local_audio1_format_profile ]]; then
        name_part13_local_audio1_format_profile=`echo "$name_part13_local_audio1_format_profile" | sed -e "s/\ /-/g" | sed -e "s/^/_&/g"`
    fi
    echo "name_part13_local_audio1_format_profile=$name_part13_local_audio1_format_profile"
    name_part14_local_audio1_samplingrate=`mediainfo -f --${lower_upper_output}=XML "$a" |grep -i "track type.*audio.*1" -A $1 | grep -i "<SamplingRate>.*<\/SamplingRate>" | awk -F "<" '{print $2}' | awk -F ">" '{print $2}'`
    echo "name_part14_local_audio1_samplingrate=$name_part14_local_audio1_samplingrate"
    if [[ ! -z name_part14_local_audio1_samplingrate ]]; then 
        temp=`echo "scale=0;$name_part14_local_audio1_samplingrate/1" |bc`
        if [[ $temp -lt 1000 ]]; then
           audio_SamplingRate_unit=Hz 
           name_part14_local_audio1_samplingrate=`echo "$name_part14_local_audio1_samplingrate" | sed -e "s/\ /-/g" | sed -e "s/^/_&/g"`"$audio_SamplingRate_unit"
        fi 
        
        if [[ $temp -ge 1000 ]] && [[ $temp -lt 10000000 ]]; then
            name_part14_local_audio1_samplingrate=`echo "scale=1;$name_part14_local_audio1_samplingrate/1000" |bc `
            audio_SamplingRate_unit=KHz    
            name_part14_local_audio1_samplingrate=`echo "$name_part14_local_audio1_samplingrate" | sed -e "s/\ /-/g" | sed -e "s/^/_&/g"`"$audio_SamplingRate_unit"
            echo "name_part14_local_audio1_samplingrate=$name_part14_local_audio1_samplingrate"
        fi 
        if [[  $temp -ge 10000000 ]]; then
            name_part14_local_audio1_samplingrate=`echo "scale=1;$name_part14_local_audio1_samplingrate/1000000" |bc `
            audio_SamplingRate_unit=MHz
            name_part14_local_audio1_samplingrate=`echo "$name_part14_local_audio1_samplingrate" | sed -e "s/\ /-/g" | sed -e "s/^/_&/g"`"$audio_SamplingRate_unit"
            echo "name_part14_local_audio1_samplingrate=$name_part14_local_audio1_samplingrate"
        fi
    fi 
    name_part15_local_audio1_bitrate=`mediainfo -f --${lower_upper_output}=XML "$a" |grep -i "track type.*audio.*1" -A $1 | grep -i "<BitRate>.*<\/BitRate>" | awk -F "<" '{print $2}' | awk -F ">" '{print $2}'`
    echo "name_part15_local_audio1_bitrate=$name_part15_local_audio1_bitrate"
    if [[ ! -z $name_part15_local_audio1_bitrate ]]; then 
        temp=`echo "scale=0;$name_part15_local_audio1_bitrate/1" |bc`
        if [[ $temp -lt 1000 ]]; then
            audio_bitrate_unit=bps     
            name_part15_local_audio1_bitrate=`echo "$name_part15_local_audio1_bitrate" | sed -e "s/\ /-/g" | sed -e "s/^/_&/g"`"$audio_bitrate_unit"
        fi 
        
        if [[ $temp -ge 1000 ]] && [[ $temp -lt 10000000 ]]; then
            name_part15_local_audio1_bitrate=`echo "scale=1;$name_part15_local_audio1_bitrate/1000" |bc `
            audio_bitrate_unit=Kbps     
            name_part15_local_audio1_bitrate=`echo "$name_part15_local_audio1_bitrate" | sed -e "s/\ /-/g" | sed -e "s/^/_&/g"`"$audio_bitrate_unit"
            echo "name_part15_local_audio1_bitrate=$name_part15_local_audio1_bitrate"
        fi 
        if [[  $temp -ge 10000000 ]]; then
            name_part15_local_audio1_bitrate=`echo "scale=1;$name_part15_local_audio1_bitrate/1000000" |bc `
            audio_bitrate_unit=Mbps
            name_part15_local_audio1_bitrate=`echo "$name_part15_local_audio1_bitrate" | sed -e "s/\ /-/g" | sed -e "s/^/_&/g"`"$audio_bitrate_unit"
            echo "name_part15_local_audio1_bitrate=$name_part15_local_audio1_bitrate"
        fi
    fi 
    name_part16_local_audio1_channel=`mediainfo -f --${lower_upper_output}=XML "$a" |grep -i "track type.*audio.*1" -A $1  | grep -i "<Channels>.*<\/Channels>" | awk -F "<" '{print $2}' | awk -F ">" '{print $2}'`
    echo "name_part16_local_audio1_channel=$name_part16_local_audio1_channel"
    if [[ ! -z $name_part16_local_audio1_channel ]]; then
        audio_channel_unit=ch
        name_part16_local_audio1_channel=`echo "$name_part16_local_audio1_channel" | sed -e "s/\ /-/g" | sed -e "s/^/_&/g"`"$audio_channel_unit"
        echo "name_part16_local_audio1_channel=$name_part16_local_audio1_channel"
    fi
    echo "audio_SamplingRate_unit=[$audio_SamplingRate_unit]"
    echo "audio_bitrate_unit=[$audio_bitrate_unit]"
    echo "audio_channel_unit=[$audio_channel_unit]"

    echo -e "##############################"
    echo -e "#####END parse_audio_1"
    echo -e "###############################\n\n"
}

function parse_audio_2(){ 
    echo -e "##############################"
    echo -e "#####parse_audio_2"
    echo -e "###############################"
    # $1: line_arrange from audio line to end
    # <track type="Audio" typeorder="2">   <==> local_audio_2
    # <Format>AAC</Format>                 <==> name_part17_local_audio2_format
    # <Format_Profile>LC</Format_Profile>  <==> name_part18_local_audio2_format_profile
    # <BitRate>317375</BitRate>            <==> name_part20_local_audio2_bitrate
    # <Channels>2</Channels>               <==> name_part21_local_audio2_channel
    # <SamplingRate>48000</SamplingRate>   <==> name_part19_local_audio2_samplingrate
 
    name_part17_local_audio2_format=`mediainfo -f --${lower_upper_output}=XML "$a" |grep -i "track type.*audio.*2" -A $1  | grep -i "<Format>.*<\/Format>" | awk -F "<" '{print $2}' | awk -F ">" '{print $2}'`
    if [[ ! -z $name_part17_local_audio2_format ]]; then
        name_part17_local_audio2_format=`echo "$name_part17_local_audio2_format" | sed -e "s/\ /-/g" | sed -e "s/^/_&/g"`
    fi
    echo "name_part17_local_audio2_format=$name_part17_local_audio2_format"
    name_part18_local_audio2_format_profile=`mediainfo -f --${lower_upper_output}=XML "$a" |grep -i "track type.*audio.*2" -A $1 | grep -i "<Format_Profile>.*<\/Format_Profile>" | awk -F "<" '{print $2}' | awk -F ">" '{print $2}'`
    if [[ ! -z $name_part18_local_audio2_format_profile ]]; then
        name_part18_local_audio2_format_profile=`echo "$name_part18_local_audio2_format_profile" | sed -e "s/\ /-/g" | sed -e "s/^/_&/g"`
    fi
    echo "name_part18_local_audio2_format_profile=$name_part18_local_audio2_format_profile"
    name_part19_local_audio2_samplingrate=`mediainfo -f --${lower_upper_output}=XML "$a" |grep -i "track type.*audio.*2" -A $1 | grep -i "<SamplingRate>.*<\/SamplingRate>" | awk -F "<" '{print $2}' | awk -F ">" '{print $2}'`
    echo "name_part19_local_audio2_samplingrate=$name_part19_local_audio2_samplingrate"
    if [[ ! -z name_part19_local_audio2_samplingrate ]]; then 
        temp=`echo "scale=0;$name_part19_local_audio2_samplingrate/1" |bc`
        if [[ $temp -lt 1000 ]]; then
           audio_SamplingRate_unit=Hz 
           name_part19_local_audio2_samplingrate=`echo "$name_part19_local_audio2_samplingrate" | sed -e "s/\ /-/g" | sed -e "s/^/_&/g"`"$audio_SamplingRate_unit"
        fi 
        
        if [[ $temp -ge 1000 ]] && [[ $temp -lt 10000000 ]]; then
            name_part19_local_audio2_samplingrate=`echo "scale=1;$name_part19_local_audio2_samplingrate/1000" |bc `
            audio_SamplingRate_unit=KHz    
            name_part19_local_audio2_samplingrate=`echo "$name_part19_local_audio2_samplingrate" | sed -e "s/\ /-/g" | sed -e "s/^/_&/g"`"$audio_SamplingRate_unit"
            echo "name_part19_local_audio2_samplingrate=$name_part19_local_audio2_samplingrate"
        fi 
        if [[  $temp -ge 10000000 ]]; then
            name_part19_local_audio2_samplingrate=`echo "scale=1;$name_part19_local_audio2_samplingrate/1000000" |bc `
            audio_SamplingRate_unit=MHz
            name_part19_local_audio2_samplingrate=`echo "$name_part19_local_audio2_samplingrate" | sed -e "s/\ /-/g" | sed -e "s/^/_&/g"`"$audio_SamplingRate_unit"
            echo "name_part19_local_audio2_samplingrate=$name_part19_local_audio2_samplingrate"
        fi
    fi 
    name_part20_local_audio2_bitrate=`mediainfo -f --${lower_upper_output}=XML "$a" |grep -i "track type.*audio.*2" -A $1 | grep -i "<BitRate>.*<\/BitRate>" | awk -F "<" '{print $2}' | awk -F ">" '{print $2}'`
    echo "name_part20_local_audio2_bitrate=$name_part20_local_audio2_bitrate"
    if [[ ! -z $name_part20_local_audio2_bitrate ]]; then 
        temp=`echo "scale=0;$name_part20_local_audio2_bitrate/1" |bc`
        if [[ $temp -lt 1000 ]]; then
            audio_bitrate_unit=bps     
            name_part20_local_audio2_bitrate=`echo "$name_part20_local_audio2_bitrate" | sed -e "s/\ /-/g" | sed -e "s/^/_&/g"`"$audio_bitrate_unit"
        fi 
        
        if [[ $temp -ge 1000 ]] && [[ $temp -lt 10000000 ]]; then
            name_part20_local_audio2_bitrate=`echo "scale=1;$name_part20_local_audio2_bitrate/1000" |bc `
            audio_bitrate_unit=Kbps     
            name_part20_local_audio2_bitrate=`echo "$name_part20_local_audio2_bitrate" | sed -e "s/\ /-/g" | sed -e "s/^/_&/g"`"$audio_bitrate_unit"
            echo "name_part20_local_audio2_bitrate=$name_part20_local_audio2_bitrate"
        fi 
        if [[  $temp -ge 10000000 ]]; then
            name_part20_local_audio2_bitrate=`echo "scale=1;$name_part20_local_audio2_bitrate/1000000" |bc `
            audio_bitrate_unit=Mbps
            name_part20_local_audio2_bitrate=`echo "$name_part20_local_audio2_bitrate" | sed -e "s/\ /-/g" | sed -e "s/^/_&/g"`"$audio_bitrate_unit"
            echo "name_part20_local_audio2_bitrate=$name_part20_local_audio2_bitrate"
        fi
    fi 
    name_part21_local_audio2_channel=`mediainfo -f --${lower_upper_output}=XML "$a" |grep -i "track type.*audio.*2" -A $1  | grep -i "<Channels>.*<\/Channels>" | awk -F "<" '{print $2}' | awk -F ">" '{print $2}'`
    echo "name_part21_local_audio2_channel=$name_part21_local_audio2_channel"
    if [[ ! -z $name_part21_local_audio2_channel ]]; then
        audio_channel_unit=ch
        name_part21_local_audio2_channel=`echo "$name_part21_local_audio2_channel" | sed -e "s/\ /-/g" | sed -e "s/^/_&/g"`"$audio_channel_unit"
        echo "name_part21_local_audio2_channel=$name_part21_local_audio2_channel"
    fi
    echo "audio_SamplingRate_unit=[$audio_SamplingRate_unit]"
    echo "audio_bitrate_unit=[$audio_bitrate_unit]"
    echo "audio_channel_unit=[$audio_channel_unit]"

    echo -e "##############################"
    echo -e "#####END parse_audio_2"
    echo -e "###############################\n\n"
}

function generate_final_name_as_per_name_rule(){
    echo -e "##############################"
    echo -e "#####generate_final_name_as_per_name_rule"
    echo -e "###############################"
    # generate final name as per name rule
    # 1, video_part: part1_part2_part3_part4_part5
    # part1: name_part1_local_general_format
    # part2: name_part2_local_video_format
    # part3: name_part3_part4_local_video_width_height
    # part4: name_part5_local_video_framerate
    # part5: name_part6_local_video_bitrate
    # part22: name_part22_local_video_profile
    # part23: name_part23_local_video_level
    # 2, audio_part: part6_part7_part8_part9_part10
    # part6: name_part7_local_audio_format
    # part7: name_part8_local_audio_format_profile
    # part8: name_part9_local_audio_samplingrate
    # part9: name_part10_local_audio_bitrate
    # part10:name_part11_local_audio_channel
    # 3, audio1_part: part11_part12_part13_part14_part15
    # part11: name_part12_local_audio1_format
    # part12: name_part13_local_audio1_format_profile
    # part13: name_part14_local_audio1_samplingrate
    # part14: name_part15_local_audio1_bitrate
    # part15: name_part16_local_audio1_channel
    # 4, audio2_part: part16_part17_part18_part19_part20
    # part16: name_part17_local_audio2_format
    # part17: name_part18_local_audio2_format_profile
    # part18: name_part19_local_audio2_samplingrate
    # part19: name_part20_local_audio2_bitrate
    # part20: name_part21_local_audio2_channel
    # 5, suffix: name_suffix_local_general_FileExtension
    # final_name: video_part_audio_part_audio1_part_audio2_part.suffix
    echo "[$name_part1_local_general_format][$name_part2_local_video_format]"
    if [[ ! -z $name_part1_local_general_format ]] || [[ ! -z $name_part2_local_video_format ]] ;then 
        final_name_as_per_name_rule_prefix="${name_part1_local_general_format}""${name_part2_local_video_format}""$name_part3_part4_local_video_width_height""$name_part5_local_video_framerate""$name_part6_local_video_bitrate""${name_part22_local_video_profile}""${name_part23_local_video_level}""${name_part7_local_audio_format}""${name_part8_local_audio_format_profile}""${name_part9_local_audio_samplingrate}""${name_part10_local_audio_bitrate}""${name_part11_local_audio_channel}""${name_part12_local_audio1_format}""${name_part13_local_audio1_format_profile}""${name_part14_local_audio1_samplingrate}""${name_part15_local_audio1_bitrate}""${name_part16_local_audio1_channel}""${name_part17_local_audio2_format}""${name_part18_local_audio2_format_profile}""${name_part19_local_audio2_samplingrate}""${name_part20_local_audio2_bitrate}""${name_part21_local_audio2_channel}"
        final_name_as_per_name_rule_suffix="${name_suffix_local_general_FileExtension}"
        final_name_as_per_name_rule="$final_name_as_per_name_rule_prefix"."$final_name_as_per_name_rule_suffix"
   fi
   echo "final_name_as_per_name_rule=[$final_name_as_per_name_rule]" 

    echo -e "##############################"
    echo -e "#####END generate_final_name_as_per_name_rule"
    echo -e "###############################\n\n"
}

function check_same_file_in_xml(){
    echo "$1"
    old_name_exist=$(cat "$HOME/$local_saved_directory/$summary_xml_name" | grep ">$1<")
    echo "old_name_exist=$old_name_exist"
    if [[ ! -z $old_name_exist ]]; then
        new_name_exist=`cat "$HOME/$local_saved_directory/$summary_xml_name" | grep ">$1<" -A 18 | grep ">$2<"`
        current_file_size=`ls -l "$1" | awk -F " " '{print $5}'`
        same_size_exist=`cat "$HOME/$local_saved_directory/$summary_xml_name" | grep ">$1<" -A 18 | grep "$current_file_size"`
        echo "new_name_exist=$new_name_exist"
        echo "current_file_size=$current_file_size"
        echo "same_size_exist=$same_size_exist"
	if [[ ! -z $new_name_exist ]] && [[ ! -z $same_size_exist ]]; then
            continue_flag=true
	    echo "WARNING: origin:$1---final:$2---size:$current_file_size already in $HOME/$local_saved_directory/$summary_xml_name"
	    echo -e "Continue\n\n"
	    if [[ ! -d $HOME/$local_saved_directory/Already_exist_in_xml ]]; then
                mkdir -p $HOME/$local_saved_directory/Already_exist_in_xml
            fi
            cp -rf "$a" $HOME/$local_saved_directory/Already_exist_in_xml/"$a"
            echo -e "[$3][Already Exist][origin:$1][final:$2][size:${current_file_size}B]"  >> $HOME/$local_saved_directory/$step_name_suffix/Step4-steam_exist_in_xml.txt
            echo -e "[$3][Error][Already Exist][origin:$1][final:$2][size:${current_file_size}B]"  >> $HOME/$local_saved_directory/$step_name_suffix/Step5-old-new-one-to-one.txt

        fi
    else
        echo "$2"
        new_name_exist=`cat "$HOME/$local_saved_directory/$summary_xml_name" | grep ">$2<"`
        current_file_size=`ls -l "$1" | awk -F " " '{print $5}'`
        same_size_exist=`cat "$HOME/$local_saved_directory/$summary_xml_name" | grep ">$2<" -A 17 | grep ">${current_file_size}B<"`
        echo "new_name_exist=$new_name_exist"
        echo "current_file_size=$current_file_size"
        echo "same_size_exist=$same_size_exist"
	if [[ ! -z $new_name_exist ]] && [[ ! -z $same_size_exist ]]; then
            origin_name_in_xml=`cat "$HOME/$local_saved_directory/$summary_xml_name" | grep ">$2<" -B 1 | head -n 1 | awk -F ">" '{print $3}' | awk -F "<" '{print $1}'`
            continue_flag=true
	    echo "WARNING: final:$2---size:$current_file_size already in $HOME/$local_saved_directory/$summary_xml_name"
	    echo -e "Continue\n\n"
	    if [[ ! -d $HOME/$local_saved_directory/Already_exist_in_xml ]]; then
                mkdir -p $HOME/$local_saved_directory/Already_exist_in_xml
            fi
            cp -rf "$a" $HOME/$local_saved_directory/Already_exist_in_xml/"$a"
            echo -e "[$3][Already Exist][origin_in_xml:$origin_name_in_xml][origin:$1][final:$2][size:${current_file_size}B]"  >> $HOME/$local_saved_directory/$step_name_suffix/Step4-steam_exist_in_xml.txt
            echo -e "[$3][Error][Already Exist][origin_in_xml:$origin_name_in_xml][origin:$1][final:$2][size:${current_file_size}B]"  >> $HOME/$local_saved_directory/$step_name_suffix/Step5-old-new-one-to-one.txt

        fi
    fi
}

function create_local_video_format_directory_and_move(){
    echo -e "##############################"
    echo -e "#####create_local_video_format_directory_and_move"
    echo -e "###############################"

        if [[ ! -z $classification_directory_name ]]; then
           if [[ ! -d $HOME/$local_saved_directory/$classification_directory_name/ ]]; then
             mkdir -p $HOME/$local_saved_directory/$classification_directory_name/
           fi
           #echo "[$1] : "$a" ------> "${final_name_as_per_name_rule}""  >> $HOME/$local_saved_directory/$step_name_suffix/Step5-old-new-one-to-one.txt
           echo "classification_directory_name=[$classification_directory_name]"
           if [[ -d $HOME/$local_saved_directory/$classification_directory_name ]]; then
               if [[ ! -z $display_resolution ]]; then
                   if [[ ! -d $HOME/$local_saved_directory/$classification_directory_name/$display_resolution ]]; then
                       mkdir -p $HOME/$local_saved_directory/$classification_directory_name/$display_resolution
                   fi
                   if [[ -d $HOME/$local_saved_directory/$classification_directory_name/$display_resolution ]]; then
                       echo "check whether the same final name ${final_name_as_per_name_rule} is in diectory $HOME/$local_saved_directory/$classification_directory_name/$display_resolution"
		       if [[ -f $HOME/$local_saved_directory/$classification_directory_name/${display_resolution}/"${final_name_as_per_name_rule}" ]]; then
                           check_final_exist=`ls $HOME/$local_saved_directory/$classification_directory_name/${display_resolution}/${final_name_as_per_name_rule_prefix}* | grep -i "SRDCQA-" `
                           echo "check_final_exist=$check_final_exist"
                           if [[ ! -z $check_final_exist ]]; then
                               echo "There is a suffix "SRDCQA-n",so change to "SRDCQA-n+1""
                               count=`ls $HOME/$local_saved_directory/$classification_directory_name/${display_resolution}/${final_name_as_per_name_rule_prefix}* | grep -i "SRDCQA-" | awk -F "SRDCQA-" '{print $2}' | awk -F "." '{print $1}' | sort -n | tail -1`
                               echo "count=$count"
                               let count+=1
                               echo "count=$count"
                               cp -rf "$a" $HOME/$local_saved_directory/$classification_directory_name/${display_resolution}/"${final_name_as_per_name_rule_prefix}"-SRDCQA-$count."${final_name_as_per_name_rule_suffix}"
                               echo "[$1][Success] : "$local_stream_path"/"$a" ------> $HOME/$local_saved_directory/$classification_directory_name/$display_resolution/"${final_name_as_per_name_rule_prefix}"-SRDCQA-$count."${final_name_as_per_name_rule_suffix}""  >> $HOME/$local_saved_directory/$step_name_suffix/Step5-old-new-one-to-one.txt
			       final_name_as_per_name_rule="${final_name_as_per_name_rule_prefix}"-SRDCQA-$count."${final_name_as_per_name_rule_suffix}"
                           else
                               cp -rf "$a" $HOME/$local_saved_directory/$classification_directory_name/${display_resolution}/"${final_name_as_per_name_rule_prefix}"-SRDCQA-1."${final_name_as_per_name_rule_suffix}"
                               echo "[$1][Success] : "$local_stream_path"/"$a" ------> $HOME/$local_saved_directory/$classification_directory_name/$display_resolution/"${final_name_as_per_name_rule_prefix}"-SRDCQA-1."${final_name_as_per_name_rule_suffix}""  >> $HOME/$local_saved_directory/$step_name_suffix/Step5-old-new-one-to-one.txt
			       final_name_as_per_name_rule="${final_name_as_per_name_rule_prefix}"-SRDCQA-1."${final_name_as_per_name_rule_suffix}"
                           fi
                           
                       else
                           cp -rf "$a" $HOME/$local_saved_directory/$classification_directory_name/${display_resolution}/"${final_name_as_per_name_rule}"
                           echo "[$1][Success] : "$local_stream_path"/"$a" ------> $HOME/$local_saved_directory/$classification_directory_name/$display_resolution/"${final_name_as_per_name_rule}""  >> $HOME/$local_saved_directory/$step_name_suffix/Step5-old-new-one-to-one.txt
                       fi
                   fi
               else # no match display resolution
                   continue_flag=true
                   echo "Not match display resolution, so enter directory: $HOME/$local_saved_directory/$classification_directory_namei/Unidentified_resolution, and copy"
                   if [[ ! -d $HOME/$local_saved_directory/$classification_directory_name/Unidentified_resolution ]]; then
                       mkdir -p $HOME/$local_saved_directory/$classification_directory_namei/Unidentified_resolution
                   fi
                   cp -rf "$a" $HOME/$local_saved_directory/$classification_directory_name/Unidentified_resolution/"$a"
                   width_height_pixel=`echo $name_part3_part4_local_video_width_height | sed -e "s/^_//g"`
                   echo "[$1][Failure][width_height_pixel:$width_height_pixel] : "$local_stream_path"/"$a" ------> $HOME/$local_saved_directory/$classification_directory_name/Unidentified_resolution/"$a"--->final name:"${final_name_as_per_name_rule}""  >> $HOME/$local_saved_directory/$step_name_suffix/Step5-old-new-one-to-one.txt
                   echo "[$1][Failure][width_height_pixel:$width_height_pixel] : "$local_stream_path"/"$a" ------> $HOME/$local_saved_directory/$classification_directory_name/Unidentified_resolution/"$a"--->final name:"${final_name_as_per_name_rule}""  >> $HOME/$local_saved_directory/$step_name_suffix/Step3-Unidentified_resolution.txt
               fi # check $display_resolution
           fi # check $HOME/$local_saved_directory/$classification_directory_name
        fi # check $classification_directory_name

    echo -e "##############################"
    echo -e "#####create_local_video_format_directory_and_move"
    echo -e "###############################\n\n"
}

function create_remote_video_format_directory_and_move(){
    echo -e "##############################"
    echo -e "#####create_remote_video_format_directory_and_move"
    echo -e "###############################"
        fusermount -u $HOME/$remote_mounted_direcotry
	$mount_remote_expect_file root atgasia01 "/var/www/html" "$HOME/$remote_mounted_direcotry" p 1082
	if [[ -f $HOME/$remote_mounted_direcotry/_MEDIA_POOL_ ]]; then
            echo "Successfully Mount to local directory $HOME/$remote_mounted_direcotry/"
	    ls -lh $HOME/$remote_mounted_direcotry/
        else
            echo "######################Failure: Failed to mount remote server to local  "
            echo "######################please contact Ming.Dong, let him check why"
            echo -e "\n\n"
	    exit -1
        fi
    

        if [[ ! -z $classification_directory_name ]]; then
           if [[ ! -d $HOME/$remote_mounted_direcotry/$classification_directory_name/ ]]; then
             mkdir -p $HOME/$remote_mounted_direcotry/$classification_directory_name/
           fi
           #echo "[$1] : "$a" ------> "${final_name_as_per_name_rule}""  >> $HOME/$local_saved_directory/$step_name_suffix/Step5-old-new-one-to-one.txt
           echo "classification_directory_name=[$classification_directory_name]"
           if [[ -d $HOME/$remote_mounted_direcotry/$classification_directory_name ]]; then
               if [[ ! -z $display_resolution ]]; then
                   if [[ ! -d $HOME/$remote_mounted_direcotry/$classification_directory_name/$display_resolution ]]; then
                       mkdir -p $HOME/$remote_mounted_direcotry/$classification_directory_name/$display_resolution
                   fi
                   if [[ -d $HOME/$remote_mounted_direcotry/$classification_directory_name/$display_resolution ]]; then
                       echo "check whether the same final name ${final_name_as_per_name_rule} is in diectory $HOME/$remote_mounted_direcotry/$classification_directory_name/$display_resolution"
		       if [[ -f $HOME/$remote_mounted_direcotry/$classification_directory_name/${display_resolution}/"${final_name_as_per_name_rule}" ]]; then
                           check_final_exist=`ls $HOME/$remote_mounted_direcotry/$classification_directory_name/${display_resolution}/${final_name_as_per_name_rule_prefix}* | grep -i "SRDCQA-" `
                           echo "check_final_exist=$check_final_exist"
                           if [[ ! -z $check_final_exist ]]; then
                               echo "There is a suffix "SRDCQA-n",so change to "SRDCQA-n+1""
                               count=`ls $HOME/$remote_mounted_direcotry/$classification_directory_name/${display_resolution}/${final_name_as_per_name_rule_prefix}* | grep -i "SRDCQA-" | awk -F "SRDCQA-" '{print $2}' | awk -F "." '{print $1}' | sort -n | tail -1`
                               echo "count=$count"
                               let count+=1
                               echo "count=$count"
                               cp -rf "$a" $HOME/$remote_mounted_direcotry/$classification_directory_name/${display_resolution}/"${final_name_as_per_name_rule_prefix}"-SRDCQA-$count."${final_name_as_per_name_rule_suffix}"
                               file_in_remote=`find $HOME/$remote_mounted_direcotry/ -name "${final_name_as_per_name_rule_prefix}"-SRDCQA-$count."${final_name_as_per_name_rule_suffix}"`
                               if [[ ! -z $file_in_remote ]]; then
                                   #echo "[$1][Success] : "$local_stream_path"/"$a" ------> $HOME/$remote_mounted_direcotry/$classification_directory_name/$display_resolution/"${final_name_as_per_name_rule_prefix}"-SRDCQA-$count."${final_name_as_per_name_rule_suffix}""  >> $HOME/$local_saved_directory/$step_name_suffix/Step5-old-new-one-to-one.txt
                                   echo "[$1:file exist in remote]"$local_stream_path"/"$a" ------> $HOME/$remote_mounted_direcotry/$classification_directory_name/$display_resolution/"${final_name_as_per_name_rule_prefix}"-SRDCQA-$count."${final_name_as_per_name_rule_suffix}"" 
                               else
                                   echo "[$1][Failure][not in remote] : "$local_stream_path"/"$a" ------> $HOME/$remote_mounted_direcotry/$classification_directory_name/$display_resolution/"${final_name_as_per_name_rule_prefix}"-SRDCQA-$count."${final_name_as_per_name_rule_suffix}""  >> $HOME/$local_saved_directory/$step_name_suffix/Step5-old-new-one-to-one.txt
                                   continue_flag=true
                                   fit_file=true
                               fi
			       final_name_as_per_name_rule="${final_name_as_per_name_rule_prefix}"-SRDCQA-$count."${final_name_as_per_name_rule_suffix}"
                           else
                               cp -rf "$a" $HOME/$remote_mounted_direcotry/$classification_directory_name/${display_resolution}/"${final_name_as_per_name_rule_prefix}"-SRDCQA-1."${final_name_as_per_name_rule_suffix}"
                               file_in_remote=`find $HOME/$remote_mounted_direcotry/ -name "${final_name_as_per_name_rule_prefix}"-SRDCQA-1."${final_name_as_per_name_rule_suffix}"`
                               if [[ ! -z $file_in_remote ]]; then
                                   #echo "[$1][Success] : "$local_stream_path"/"$a" ------> $HOME/$remote_mounted_direcotry/$classification_directory_name/$display_resolution/"${final_name_as_per_name_rule_prefix}"-SRDCQA-1."${final_name_as_per_name_rule_suffix}""  >> $HOME/$local_saved_directory/$step_name_suffix/Step5-old-new-one-to-one.txt
                                   echo "[$1:file exist in remote] : "$local_stream_path"/"$a" ------> $HOME/$remote_mounted_direcotry/$classification_directory_name/$display_resolution/"${final_name_as_per_name_rule_prefix}"-SRDCQA-1."${final_name_as_per_name_rule_suffix}"" 
                               else
                                   echo "[$1][Failure][not in remote] : "$local_stream_path"/"$a" ------> $HOME/$remote_mounted_direcotry/$classification_directory_name/$display_resolution/"${final_name_as_per_name_rule_prefix}"-SRDCQA-$count."${final_name_as_per_name_rule_suffix}""  >> $HOME/$local_saved_directory/$step_name_suffix/Step5-old-new-one-to-one.txt
                                   continue_flag=true
                                   fit_file=true
                               fi
			       final_name_as_per_name_rule="${final_name_as_per_name_rule_prefix}"-SRDCQA-1."${final_name_as_per_name_rule_suffix}"
                           fi
                           
                       else
                           cp -rf "$a" $HOME/$remote_mounted_direcotry/$classification_directory_name/${display_resolution}/"${final_name_as_per_name_rule}"
                           file_in_remote=`find $HOME/$remote_mounted_direcotry/ -name "${final_name_as_per_name_rule}"`
                           if [[ ! -z $file_in_remote ]]; then
                               #echo "[$1][Success] : "$local_stream_path"/"$a" ------> $HOME/$remote_mounted_direcotry/$classification_directory_name/$display_resolution/"${final_name_as_per_name_rule}""  >> $HOME/$local_saved_directory/$step_name_suffix/Step5-old-new-one-to-one.txt
                               echo "[$1:file exist in remote] : "$local_stream_path"/"$a" ------> $HOME/$remote_mounted_direcotry/$classification_directory_name/$display_resolution/"${final_name_as_per_name_rule}""
                           else
                               echo "[$1][Failure][not in remote] : "$local_stream_path"/"$a" ------> $HOME/$remote_mounted_direcotry/$classification_directory_name/$display_resolution/"${final_name_as_per_name_rule_prefix}"-SRDCQA-$count."${final_name_as_per_name_rule_suffix}""  >> $HOME/$local_saved_directory/$step_name_suffix/Step5-old-new-one-to-one.txt
                               continue_flag=true
                               fit_file=true
                           fi
                       fi
                   fi
               else # no match display resolution
                   continue_flag=true
                   echo "Not match display resolution, so enter directory: $HOME/$local_saved_directory/$classification_directory_namei/Unidentified_resolution, and copy"
                   if [[ ! -d $HOME/$local_saved_directory/Unidentified_resolution ]]; then
                       mkdir -p $HOME/$local_saved_directory/Unidentified_resolution
                   fi
                   cp -rf "$a" $HOME/$local_saved_directory/Unidentified_resolution/"$a"
                   width_height_pixel=`echo $name_part3_part4_local_video_width_height | sed -e "s/^_//g"`
                   echo "[$1][Failure][width_height_pixel:$width_height_pixel] : "$local_stream_path"/"$a" ------> $HOME/$local_saved_directory/Unidentified_resolution/"$a"--->final name:"${final_name_as_per_name_rule}""  >> $HOME/$local_saved_directory/$step_name_suffix/Step5-old-new-one-to-one.txt
                   echo "[$1][Failure][width_height_pixel:$width_height_pixel] : "$local_stream_path"/"$a" ------> $HOME/$local_saved_directory/Unidentified_resolution/"$a"--->final name:"${final_name_as_per_name_rule}""  >> $HOME/$local_saved_directory/$step_name_suffix/Step3-Unidentified_resolution.txt
               fi # check $display_resolution
           fi # check $HOME/$local_saved_directory/$classification_directory_name
        fi # check $classification_directory_name

    echo -e "##############################"
    echo -e "#####END create_remote_video_format_directory_and_move"
    echo -e "###############################\n\n"
}


function create_row_template(){
    echo -e "##############################"
    echo -e "#####create_row_template"
    echo -e "###############################"
    origin_row_count=`cat "$1" | grep -i ExpandedRowCount | awk -F "ExpandedRowCount" '{print $2}' |  awk -F "\"" '{print $2}'`
    let new_row_count=origin_row_count+1
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ <\!--Row_${new_row_count}_end-->" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ <\/Row>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s72\"\/>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s71\"><Data\ ss:Type=\"String\">AUDIO_2_CHANNEL<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s71\"><Data\ ss:Type=\"String\">AUDIO_2_BITRATE<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s71\"><Data\ ss:Type=\"String\">AUDIO_2_SAMPLINGRATE<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s71\"><Data\ ss:Type=\"String\">AUDIO_2_FORMAT_PROFILE<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s71\"><Data\ ss:Type=\"String\">AUDIO_2_FORMAT<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s71\"><Data\ ss:Type=\"String\">AUDIO_OR_AUDIO_1_CHANNEL<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s71\"><Data\ ss:Type=\"String\">AUDIO_OR_AUDIO_1_BITRATE<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s71\"><Data\ ss:Type=\"String\">AUDIO_OR_AUDIO_1_SAMPLINGRATE<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s71\"><Data\ ss:Type=\"String\">AUDIO_OR_AUDIO_1_FORMAT_PROFILE<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s71\"><Data\ ss:Type=\"String\">AUDIO_OR_AUDIO_1_FORMAT<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s71\"><Data\ ss:Type=\"String\">VIDEO_BITRATE<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s71\"><Data\ ss:Type=\"String\">VIDEO_FRAMERATE<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s71\"><Data\ ss:Type=\"String\">VIDEO_RESOLUTION<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s71\"><Data\ ss:Type=\"String\">VIDEO_FORMAT<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s71\"><Data\ ss:Type=\"String\">GENERAL_FORMAT<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s69\"><Data\ ss:Type=\"String\">NEW_NAME<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s70\"><Data\ ss:Type=\"String\">OLD_NAME<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s69\"><Data\ ss:Type=\"Number\">FILE_NUMBER<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ <Row\ ss:AutoFitHeight=\"0\"\ ss:Height=\"34.25\"\ ss:StyleID=\"Default\">" "$1"
    sed -i "s/ExpandedRowCount=\"${origin_row_count}\"/ExpandedRowCount=\"${new_row_count}\"/g" "$1"

    echo -e "##############################"
    echo -e "#####END create_row_template"
    echo -e "###############################\n\n"

}

function create_row_template_with_file_size(){
    echo -e "##############################"
    echo -e "#####create_row_template"
    echo -e "###############################"
    origin_row_count=`cat "$1" | grep -i ExpandedRowCount | awk -F "ExpandedRowCount" '{print $2}' |  awk -F "\"" '{print $2}'`
    let new_row_count=origin_row_count+1
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ <\!--Row_${new_row_count}_end-->" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ <\/Row>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s21\"><Data\ ss:Type=\"String\">FILE_SIZE<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s25\"><Data\ ss:Type=\"String\">AUDIO_2_CHANNEL<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s25\"><Data\ ss:Type=\"String\">AUDIO_2_BITRATE<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s25\"><Data\ ss:Type=\"String\">AUDIO_2_SAMPLINGRATE<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s25\"><Data\ ss:Type=\"String\">AUDIO_2_FORMAT_PROFILE<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s25\"><Data\ ss:Type=\"String\">AUDIO_2_FORMAT<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s25\"><Data\ ss:Type=\"String\">AUDIO_OR_AUDIO_1_CHANNEL<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s25\"><Data\ ss:Type=\"String\">AUDIO_OR_AUDIO_1_BITRATE<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s25\"><Data\ ss:Type=\"String\">AUDIO_OR_AUDIO_1_SAMPLINGRATE<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s25\"><Data\ ss:Type=\"String\">AUDIO_OR_AUDIO_1_FORMAT_PROFILE<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s25\"><Data\ ss:Type=\"String\">AUDIO_OR_AUDIO_1_FORMAT<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s25\"><Data\ ss:Type=\"String\">VIDEO_BITRATE<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s25\"><Data\ ss:Type=\"String\">VIDEO_FRAMERATE<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s25\"><Data\ ss:Type=\"String\">VIDEO_RESOLUTION<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s25\"><Data\ ss:Type=\"String\">VIDEO_FORMAT<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s25\"><Data\ ss:Type=\"String\">GENERAL_FORMAT<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s19\"><Data\ ss:Type=\"String\">NEW_NAME<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s20\"><Data\ ss:Type=\"String\">OLD_NAME<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s19\"><Data\ ss:Type=\"Number\">FILE_NUMBER<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ <Row\ ss:AutoFitHeight=\"0\"\ ss:Height=\"34.25\">" "$1"
    sed -i "s/ExpandedRowCount=\"${origin_row_count}\"/ExpandedRowCount=\"${new_row_count}\"/g" "$1"

    echo -e "##############################"
    echo -e "#####END create_row_template"
    echo -e "###############################\n\n"

}

function create_row_template_with_file_size_profile_level(){
    echo -e "##############################"
    echo -e "#####create_row_template"
    echo -e "###############################"
    origin_row_count=`cat "$1" | grep -i ExpandedRowCount | awk -F "ExpandedRowCount" '{print $2}' |  awk -F "\"" '{print $2}'`
    let new_row_count=origin_row_count+1
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ <\!--Row_${new_row_count}_end-->" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ <\/Row>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s70\"><Data\ ss:Type=\"String\">FILE_SIZE<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s70\"><Data\ ss:Type=\"String\">AUDIO_2_CHANNEL<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s70\"><Data\ ss:Type=\"String\">AUDIO_2_BITRATE<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s70\"><Data\ ss:Type=\"String\">AUDIO_2_SAMPLINGRATE<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s70\"><Data\ ss:Type=\"String\">AUDIO_2_FORMAT_PROFILE<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s70\"><Data\ ss:Type=\"String\">AUDIO_2_FORMAT<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s70\"><Data\ ss:Type=\"String\">AUDIO_OR_AUDIO_1_CHANNEL<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s70\"><Data\ ss:Type=\"String\">AUDIO_OR_AUDIO_1_BITRATE<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s70\"><Data\ ss:Type=\"String\">AUDIO_OR_AUDIO_1_SAMPLINGRATE<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s70\"><Data\ ss:Type=\"String\">AUDIO_OR_AUDIO_1_FORMAT_PROFILE<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s70\"><Data\ ss:Type=\"String\">AUDIO_OR_AUDIO_1_FORMAT<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s70\"><Data\ ss:Type=\"String\">VIDEO_FORMAT_LEVEL<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s70\"><Data\ ss:Type=\"String\">VIDEO_FORMAT_PROFILE<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s70\"><Data\ ss:Type=\"String\">VIDEO_BITRATE<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s70\"><Data\ ss:Type=\"String\">VIDEO_FRAMERATE<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s70\"><Data\ ss:Type=\"String\">VIDEO_RESOLUTION<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s70\"><Data\ ss:Type=\"String\">VIDEO_FORMAT<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s70\"><Data\ ss:Type=\"String\">GENERAL_FORMAT<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s68\"><Data\ ss:Type=\"String\">NEW_NAME<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s69\"><Data\ ss:Type=\"String\">OLD_NAME<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ \ <Cell\ ss:StyleID=\"s68\"><Data\ ss:Type=\"Number\">FILE_NUMBER<\/Data><\/Cell>" "$1"
    sed -i "/<\!--Row_${origin_row_count}_end-->/a  \ \ \ <Row\ ss:AutoFitHeight=\"0\"\ ss:Height=\"34.25\" ss:StyleID=\"Default\">" "$1"
    sed -i "s/ExpandedRowCount=\"${origin_row_count}\"/ExpandedRowCount=\"${new_row_count}\"/g" "$1"

    echo -e "##############################"
    echo -e "#####END create_row_template"
    echo -e "###############################\n\n"

}


function add_parsed_parameters_into_row_template_for_only_video(){
    echo -e "##############################"
    echo -e "#####add_parsed_parameters_into_row_template_for_only_video"
    echo -e "###############################"
    total_row_count=`cat "$1" | grep -i ExpandedRowCount | awk -F "ExpandedRowCount" '{print $2}' |  awk -F "\"" '{print $2}'`
    let current_row_count=total_row_count-1
          tmp_video_file_size=`ls -l "$2" | awk -F " " '{print $5}'`B
          echo "tmp_video_file_size=$tmp_video_file_size"         
          sed -i "s/FILE_SIZE/$tmp_video_file_size/g" "$1"

          sed -i "s/AUDIO_2_CHANNEL//g" "$1"
          sed -i "s/AUDIO_2_BITRATE//g" "$1"
          sed -i "s/AUDIO_2_SAMPLINGRATE//g" "$1"
          sed -i "s/AUDIO_2_FORMAT_PROFILE//g" "$1"
          sed -i "s/AUDIO_2_FORMAT//g" "$1"
          sed -i "s/AUDIO_OR_AUDIO_1_CHANNEL//g" "$1"
          sed -i "s/AUDIO_OR_AUDIO_1_BITRATE//g" "$1"
          sed -i "s/AUDIO_OR_AUDIO_1_SAMPLINGRATE//g" "$1"
          sed -i "s/AUDIO_OR_AUDIO_1_FORMAT_PROFILE//g" "$1"
          sed -i "s/AUDIO_OR_AUDIO_1_FORMAT//g" "$1"
   # name_part22_local_video_profile
   # name_part23_local_video_level
          if [[ ! -z ${name_part23_local_video_level} ]]; then
              tmp_video_format_level=`echo $name_part23_local_video_level | sed -e "s/^_level_//g"`
              echo "tmp_video_format_level=${tmp_video_format_level}"
              sed -i "s/VIDEO_FORMAT_LEVEL/${tmp_video_format_level}/g" "$1"
          else
              sed -i "s/VIDEO_FORMAT_LEVEL//g" "$1"
          fi 
          if [[ ! -z ${name_part22_local_video_profile} ]]; then
              tmp_video_format_profile=`echo $name_part22_local_video_profile | sed -e "s/^_Profile_//g"`
              echo "tmp_video_format_profile=${tmp_video_format_level}"
              sed -i "s/VIDEO_FORMAT_PROFILE/${tmp_video_format_profile}/g" "$1"
          else
              sed -i "s/VIDEO_FORMAT_PROFILE//g" "$1"
          fi 

          tmp_video_bitrate=`echo $name_part6_local_video_bitrate | sed -e "s/^_//g"`
          echo "tmp_video_bitrate=${tmp_video_bitrate}"
          sed -i "s/VIDEO_BITRATE/${tmp_video_bitrate}/g" "$1"
          tmp_video_framerate=`echo $name_part5_local_video_framerate | sed -e "s/^_//g"`
          echo "tmp_video_framerate=${tmp_video_framerate}"
          sed -i "s/VIDEO_FRAMERATE/${tmp_video_framerate}/g" "$1"
          tmp_video_resolution=`echo $name_part3_part4_local_video_width_height | sed -e "s/^_//g"`
          echo "tmp_video_resolution=${tmp_video_resolution}"
          sed -i "s/VIDEO_RESOLUTION/${tmp_video_resolution}/g" "$1"
          tmp_video_format=`echo $name_part2_local_video_format | sed -e "s/^_//g"`
          echo "tmp_video_format=${tmp_video_format}"
          sed -i "s/VIDEO_FORMAT/${tmp_video_format}/g" "$1"
          tmp_general_format=`echo $name_part1_local_general_format | sed -e "s/^_//g"`
          echo "tmp_general_format=${tmp_general_format}"
          sed -i "s/GENERAL_FORMAT/${tmp_general_format}/g" "$1"
          sed -i "s/NEW_NAME/${final_name_as_per_name_rule}/g" "$1"
          sed -i "s/OLD_NAME/$a/g" "$1"
          sed -i "s/FILE_NUMBER/$current_row_count/g" "$1"

    echo -e "##############################"
    echo -e "#####END add_parsed_parameters_into_row_template_for_only_video"
    echo -e "###############################\n\n"

}

function add_parsed_parameters_into_row_template_for_video_audio(){
    echo -e "##############################"
    echo -e "#####add_parsed_parameters_into_row_template_for_video_audio"
    echo -e "###############################"
    total_row_count=`cat "$1" | grep -i ExpandedRowCount | awk -F "ExpandedRowCount" '{print $2}' |  awk -F "\"" '{print $2}'`
    let current_row_count=total_row_count-1
          tmp_video_file_size=`ls -l "$2" | awk -F " " '{print $5}'`B
          echo "tmp_video_file_size=$tmp_video_file_size"         
          sed -i "s/FILE_SIZE/$tmp_video_file_size/g" "$1"

          sed -i "s/AUDIO_2_CHANNEL//g" "$1"
          sed -i "s/AUDIO_2_BITRATE//g" "$1"
          sed -i "s/AUDIO_2_SAMPLINGRATE//g" "$1"
          sed -i "s/AUDIO_2_FORMAT_PROFILE//g" "$1"
          sed -i "s/AUDIO_2_FORMAT//g" "$1"
          tmp_audio_channel=`echo $name_part11_local_audio_channel | sed -e "s/^_//g"`
          echo "tmp_audio_channel=${tmp_audio_channel}"
          sed -i "s/AUDIO_OR_AUDIO_1_CHANNEL/$tmp_audio_channel/g" "$1"
          tmp_audio_bitrate=`echo $name_part10_local_audio_bitrate | sed -e "s/^_//g"`
          echo "tmp_audio_bitrate=${tmp_audio_bitrate}"
          sed -i "s/AUDIO_OR_AUDIO_1_BITRATE/$tmp_audio_bitrate/g" "$1"
          tmp_audio_samplingrate=`echo $name_part9_local_audio_samplingrate | sed -e "s/^_//g"`
          echo "tmp_audio_samplingrate=${tmp_audio_samplingrate}"
          sed -i "s/AUDIO_OR_AUDIO_1_SAMPLINGRATE/$tmp_audio_samplingrate/g" "$1"
          tmp_audio_format_profile=`echo $name_part8_local_audio_format_profile | sed -e "s/^_//g"`
          echo "tmp_audio_format_profile=${tmp_audio_format_profile}"
          sed -i "s/AUDIO_OR_AUDIO_1_FORMAT_PROFILE/$tmp_audio_format_profile/g" "$1"
          tmp_audio_fromat=`echo $name_part7_local_audio_format | sed -e "s/^_//g"`
          echo "tmp_audio_fromat=${tmp_audio_fromat}"
          sed -i "s/AUDIO_OR_AUDIO_1_FORMAT/$tmp_audio_fromat/g" "$1"
          if [[ ! -z ${name_part23_local_video_level} ]]; then
              tmp_video_format_level=`echo $name_part23_local_video_level | sed -e "s/^_level_//g"`
              echo "tmp_video_format_level=${tmp_video_format_level}"
              sed -i "s/VIDEO_FORMAT_LEVEL/${tmp_video_format_level}/g" "$1"
          else
              sed -i "s/VIDEO_FORMAT_LEVEL//g" "$1"
          fi 
          if [[ ! -z ${name_part22_local_video_profile} ]]; then
              tmp_video_format_profile=`echo $name_part22_local_video_profile | sed -e "s/^_Profile_//g"`
              echo "tmp_video_format_profile=${tmp_video_format_level}"
              sed -i "s/VIDEO_FORMAT_PROFILE/${tmp_video_format_profile}/g" "$1"
          else
              sed -i "s/VIDEO_FORMAT_PROFILE//g" "$1"
          fi 
          tmp_video_bitrate=`echo $name_part6_local_video_bitrate | sed -e "s/^_//g"`
          echo "tmp_video_bitrate=${tmp_video_bitrate}"
          sed -i "s/VIDEO_BITRATE/${tmp_video_bitrate}/g" "$1"
          tmp_video_framerate=`echo $name_part5_local_video_framerate | sed -e "s/^_//g"`
          echo "tmp_video_framerate=${tmp_video_framerate}"
          sed -i "s/VIDEO_FRAMERATE/${tmp_video_framerate}/g" "$1"
          tmp_video_resolution=`echo $name_part3_part4_local_video_width_height | sed -e "s/^_//g"`
          echo "tmp_video_resolution=${tmp_video_resolution}"
          sed -i "s/VIDEO_RESOLUTION/${tmp_video_resolution}/g" "$1"
          tmp_video_format=`echo $name_part2_local_video_format | sed -e "s/^_//g"`
          echo "tmp_video_format=${tmp_video_format}"
          sed -i "s/VIDEO_FORMAT/${tmp_video_format}/g" "$1"
          tmp_general_format=`echo $name_part1_local_general_format | sed -e "s/^_//g"`
          echo "tmp_general_format=${tmp_general_format}"
          sed -i "s/GENERAL_FORMAT/${tmp_general_format}/g" "$1"
          sed -i "s/NEW_NAME/${final_name_as_per_name_rule}/g" "$1"
          sed -i "s/OLD_NAME/$a/g" "$1"
          sed -i "s/FILE_NUMBER/$current_row_count/g" "$1"

    echo -e "##############################"
    echo -e "#####END add_parsed_parameters_into_row_template_for_video_audio"
    echo -e "###############################\n\n"

}
# part11: name_part12_local_audio1_format

function add_parsed_parameters_into_row_template_for_video_audio1_audio2(){
    echo -e "##############################"
    echo -e "#####add_parsed_parameters_into_row_template_for_video_audio1_audio2"
    echo -e "###############################"
    total_row_count=`cat "$1" | grep -i ExpandedRowCount | awk -F "ExpandedRowCount" '{print $2}' |  awk -F "\"" '{print $2}'`
    let current_row_count=total_row_count-1
          tmp_video_file_size=`ls -l "$2" | awk -F " " '{print $5}'`B
          echo "tmp_video_file_size=$tmp_video_file_size"         
          sed -i "s/FILE_SIZE/$tmp_video_file_size/g" "$1"

          tmp_audio_2_channel=`echo $name_part21_local_audio2_channel | sed -e "s/^_//g"`
          echo "tmp_audio_2_channel=${tmp_audio_2_channel}"
          sed -i "s/AUDIO_2_CHANNEL/$tmp_audio_2_channel/g" "$1"
          tmp_audio_2_bitrate=`echo $name_part20_local_audio2_bitrate | sed -e "s/^_//g"`
          echo "tmp_audio_2_bitrate=${tmp_audio_2_bitrate}"
          sed -i "s/AUDIO_2_BITRATE/$tmp_audio_2_bitrate/g" "$1"
          tmp_audio_2_samplingrate=`echo $name_part19_local_audio2_samplingrate | sed -e "s/^_//g"`
          echo "tmp_audio_2_samplingrate=${tmp_audio_2_samplingrate}"
          sed -i "s/AUDIO_2_SAMPLINGRATE/$tmp_audio_2_samplingrate/g" "$1"
          tmp_audio_2_format_profile=`echo $name_part18_local_audio2_format_profile | sed -e "s/^_//g"`
          echo "tmp_audio_2_format_profile=${tmp_audio_2_format_profile}"
          sed -i "s/AUDIO_2_FORMAT_PROFILE/$tmp_audio_2_format_profile/g" "$1"
          tmp_audio_2_fromat=`echo $name_part17_local_audio2_format | sed -e "s/^_//g"`
          echo "tmp_audio_2_fromat=${tmp_audio_2_fromat}"
          sed -i "s/AUDIO_2_FORMAT/$tmp_audio_2_fromat/g" "$1"
          tmp_audio_1_channel=`echo $name_part16_local_audio1_channel | sed -e "s/^_//g"`
          echo "tmp_audio_1_channel=${tmp_audio_1_channel}"
          sed -i "s/AUDIO_OR_AUDIO_1_CHANNEL/$tmp_audio_1_channel/g" "$1"
          tmp_audio_1_bitrate=`echo $name_part15_local_audio1_bitrate | sed -e "s/^_//g"`
          echo "tmp_audio_1_bitrate=${tmp_audio_1_bitrate}"
          sed -i "s/AUDIO_OR_AUDIO_1_BITRATE/$tmp_audio_1_bitrate/g" "$1"
          tmp_audio_1_samplingrate=`echo $name_part14_local_audio1_samplingrate | sed -e "s/^_//g"`
          echo "tmp_audio_1_samplingrate=${tmp_audio_1_samplingrate}"
          sed -i "s/AUDIO_OR_AUDIO_1_SAMPLINGRATE/$tmp_audio_1_samplingrate/g" "$1"
          tmp_audio_1_format_profile=`echo $name_part13_local_audio1_format_profile | sed -e "s/^_//g"`
          echo "tmp_audio_1_format_profile=${tmp_audio_1_format_profile}"
          sed -i "s/AUDIO_OR_AUDIO_1_FORMAT_PROFILE/$tmp_audio_1_format_profile/g" "$1"
          tmp_audio_1_fromat=`echo $name_part12_local_audio1_format | sed -e "s/^_//g"`
          echo "tmp_audio_1_fromat=${tmp_audio_1_fromat}"
          sed -i "s/AUDIO_OR_AUDIO_1_FORMAT/$tmp_audio_1_fromat/g" "$1"
          if [[ ! -z ${name_part23_local_video_level} ]]; then
              tmp_video_format_level=`echo $name_part23_local_video_level | sed -e "s/^_level_//g"`
              echo "tmp_video_format_level=${tmp_video_format_level}"
              sed -i "s/VIDEO_FORMAT_LEVEL/${tmp_video_format_level}/g" "$1"
          else
              sed -i "s/VIDEO_FORMAT_LEVEL//g" "$1"
          fi 
          if [[ ! -z ${name_part22_local_video_profile} ]]; then
              tmp_video_format_profile=`echo $name_part22_local_video_profile | sed -e "s/^_Profile_//g"`
              echo "tmp_video_format_profile=${tmp_video_format_level}"
              sed -i "s/VIDEO_FORMAT_PROFILE/${tmp_video_format_profile}/g" "$1"
          else
              sed -i "s/VIDEO_FORMAT_PROFILE//g" "$1"
          fi 
          tmp_video_bitrate=`echo $name_part6_local_video_bitrate | sed -e "s/^_//g"`
          echo "tmp_video_bitrate=${tmp_video_bitrate}"
          sed -i "s/VIDEO_BITRATE/${tmp_video_bitrate}/g" "$1"
          tmp_video_framerate=`echo $name_part5_local_video_framerate | sed -e "s/^_//g"`
          echo "tmp_video_framerate=${tmp_video_framerate}"
          sed -i "s/VIDEO_FRAMERATE/${tmp_video_framerate}/g" "$1"
          tmp_video_resolution=`echo $name_part3_part4_local_video_width_height | sed -e "s/^_//g"`
          echo "tmp_video_resolution=${tmp_video_resolution}"
          sed -i "s/VIDEO_RESOLUTION/${tmp_video_resolution}/g" "$1"
          tmp_video_format=`echo $name_part2_local_video_format | sed -e "s/^_//g"`
          echo "tmp_video_format=${tmp_video_format}"
          sed -i "s/VIDEO_FORMAT/${tmp_video_format}/g" "$1"
          tmp_general_format=`echo $name_part1_local_general_format | sed -e "s/^_//g"`
          echo "tmp_general_format=${tmp_general_format}"
          sed -i "s/GENERAL_FORMAT/${tmp_general_format}/g" "$1"
          sed -i "s/NEW_NAME/${final_name_as_per_name_rule}/g" "$1"
          sed -i "s/OLD_NAME/$a/g" "$1"
          sed -i "s/FILE_NUMBER/$current_row_count/g" "$1"

    echo -e "##############################"
    echo -e "#####END add_parsed_parameters_into_row_template_for_video_audio1_audio2"
    echo -e "###############################\n\n"

}

function check_xml_and_remote_number_is_the_same(){
    echo -e "##############################"
    echo -e "#####check_xml_and_remote_number_is_the_same"
    echo -e "###############################"
    # 1, compare the number 
    number_in_xml=`cat $HOME/$local_saved_directory/$summary_xml_name  | grep "ss:Type=\"Number\">" | awk -F ">" '{print $3}' | awk -F "<" '{print $1}' | sort -n | tail -1`
    echo "$number_in_xml in $HOME/$local_saved_directory/$summary_xml_name"
    numer_in_remote=`find $HOME/$remote_mounted_direcotry -name "*.*" | wc -l`
    echo "$numer_in_remote in $HOME/$remote_mounted_direcotry"
    if [[ $number_in_xml -eq $numer_in_remote ]] && [[ $numer_in_remote -eq $fit_file_number ]] ; then
        echo "equivent to $fit_file_number"
        for remote_file_name in `find $HOME/$remote_mounted_direcotry -name "*.*"`
        do 
            echo $remote_file_name
            remote_file_name_exist=
            remote_file_name_exist=`cat $HOME/$local_saved_directory/$summary_xml_name |  grep "$remote_file_name"`
            if [[ -z $remote_file_name_exist ]]; then
                echo "[inconsistence][miss in xml] $remote_file_name in $HOME/$remote_mounted_direcotry but not in $HOME/$local_saved_directory/$summary_xml_name " >> $HOME/$local_saved_directory/$step_name_suffix/Step6-xml_remote_consistence.txt    
            fi
        done
    fi
    if [[ $number_in_xml -lt $numer_in_remote ]] && [[ $numer_in_remote -eq $fit_file_number ]] ; then
        echo "number_in_xml lt numer_in_remote, numer_in_remote equivent to fit_file_number"
        for remote_file_name in `find $HOME/$remote_mounted_direcotry -name "*.*"`
        do 
            echo $remote_file_name
            remote_file_name_exist=
            remote_file_name_exist=`cat $HOME/$local_saved_directory/$summary_xml_name |  grep "$remote_file_name"`
            if [[ -z $remote_file_name_exist ]]; then
                echo "[inconsistence][miss in xml] $remote_file_name in $HOME/$remote_mounted_direcotry but not in $HOME/$local_saved_directory/$summary_xml_name " >> $HOME/$local_saved_directory/$step_name_suffix/Step6-xml_remote_consistence.txt    
            fi
        done

    fi
# 2, check remote is in the xml.
    echo -e "##############################"
    echo -e "#####END check_xml_and_remote_number_is_the_same"
    echo -e "###############################\n\n"
}
#------------------------function end----------------------------


#------------------------Body-------------------------------------

echo "\$#=$#"
echo "\$@=$@"
echo "\$*=$*"
echo "\$?=$?"

tmp_date=`date +%Y%m%d_%H_%M_%S_%p`

echo "$tmp_date"


echo -e "\n>>>>>>>>> begin <<<<<<<<<<\n"

if [[ $# -ne 1 ]]; then
   echo -e "parameter number not match. only need one parematers: directory absolute path"
   print_help
   exit -1
fi

if [[ ! -d "$1" ]]; then
    echo "Directory "$1", not found"
   print_help
    exit -1
fi

# global variable  

    # check whether mediainfo contain  general/video/audio/audio 1/audio 2 track type.
    local_general=
    local_video=
    local_audio=
    local_audio_1=
    local_audio_2=
    local_menu=

    #if corresponding track type exist, calculate the line number of this track type.
    local_general_line=
    local_video_line=
    local_audio_line=
    local_audio1_line=
    local_audio2_line=
    local_menu_line=
    #calculate the arrange between  track type "general"  and track type behind "general"
    general_line_arrange=
    #calculate the arrange between  track type "video"  and track type "audio"
    video_audio_line_arrange=
    audio_menu_line_arrange=
    #calculate the arrange between  track type "video"  and track type "audio1"
    video_audio1_line_arrange=
    #calculate the arrange between  track type "audio1"  and track type "audio2"
    auido1_audio2_line_arrange=

    # 3 conditions of track type
    video_audio=
    video_audio1_audio2=
    only_video=
    menu_exist=
    
    # video parameter unit
    video_bitrate_unit=
    video_framerate_unit=
    

    ##### Video and Audio parameters
      #general
    name_part1_local_general_format=
      #Video
    name_part2_local_video_format=
    name_part3_local_video_width=
    name_part4_local_video_height=
    name_part3_part4_local_video_width_height=
    name_part5_local_video_framerate=
    name_part6_local_video_bitrate=
    name_part22_local_video_profile=
    name_part23_local_video_level=
    
      #Audio
    name_part7_local_audio_format=
    name_part8_local_audio_format_profile=
    name_part9_local_audio_samplingrate=
    name_part10_local_audio_bitrate=
    name_part11_local_audio_channel=
    name_part12_local_audio1_format=
    name_part13_local_audio1_format_profile=
    name_part14_local_audio1_samplingrate=
    name_part15_local_audio1_bitrate=
    name_part16_local_audio1_channel=
    name_part17_local_audio2_format=
    name_part18_local_audio2_format_profile=
    name_part19_local_audio2_samplingrate=
    name_part20_local_audio2_bitrate=
    name_part21_local_audio2_channel=
    name_suffix_local_general_FileExtension=
 
    # create directory
    classification_directory_name=
    display_resolution=

    # final name
    final_name_as_per_name_rule=
    final_name_as_per_name_rule_prefix=
    final_name_as_per_name_rule_suffix=
    # flag of continue
    continue_flag=
    # flag of fit file
    fit_file=

 # not need to restore
    # check whether resolution is identified
    Unidentified_resolution= 
    # check whether track type is identified
    Unidentified_track_type=
    # check whether steam already exist
    Already_exist_in_xml=

    remote_avail_space=
    local_steam_space=
    remain_remote_avail_space=
    local_steam_backup=
    # record number of file which fit to change name.
    fit_file_number=
    # number in xml
    number_in_xml=
    last_number_in_xml=
    total_number_in_xml=
    # number in remote
    numer_in_remote=
    last_numer_in_remote=
    total_numer_in_remote=
    # mediainfo parameter lower or upper
    lower_upper_output=
  # specify the concrete, you can change it.
    summary_xml_name=Test_stream_summary.xml
    local_saved_directory=Videos
    remote_mounted_direcotry=remote-root-atgasia01-1082
    local_backup_file_directory=1-never-delete
    mount_remote_expect_file=mount_remote_server_to_local
# END //global variable

lower_upper_output=`mediainfo --help | grep "output=XML"`
if [[ -z $lower_upper_output ]]; then
    lower_upper_output=`mediainfo --help | grep "Output=XML"`
    if [[ -z $lower_upper_output ]]; then
        echo -e "\nFatal Error: mediainfo  have no options: --output=XML or --Output=XML\n"
        exit -1
    else
        lower_upper_output=Output
    fi
else
    lower_upper_output=output
fi
echo "lower_upper_output=$lower_upper_output"

# prerequisit: check whether  $mount_remote_expect_file exist.
generat_expect_file_about_sshfs_mount

# prerequisite 1: whether remote server is mounted to local directory $remote_mounted_direcotry\
check_remote_server_is_mounted_to_local_directory
last_numer_in_remote=`find $HOME/$remote_mounted_direcotry -name "*.*" | wc -l`
if [[ -z $last_numer_in_remote ]]; then
    last_numer_in_remote=0
fi
echo "Last: $last_numer_in_remote in $HOME/$remote_mounted_direcotry"

# prerequisite 2: check whether record xml exist:
#check_record_xml_exist
check_record_xml_with_file_size_exist
last_number_in_xml=`cat $HOME/$local_saved_directory/$summary_xml_name  | grep "ss:Type=\"Number\">" | awk -F ">" '{print $3}' | awk -F "<" '{print $1}' | sort -n | tail -1`
if [[ -z $last_number_in_xml ]]; then
    last_number_in_xml=0
fi
echo -e  "Last: $last_number_in_xml in $HOME/$local_saved_directory/$summary_xml_name"

# check whetehr enough space
local_stream_path="$1"
check_remote_space_is_enough "$local_stream_path"

# generate directory, according to steam direcotry name
step_name_suffix=`echo "$local_stream_path" | sed -e "s/\//_/g"| sed -e "s/^_//g"`
echo "$step_name_suffix"
if [[ ! -d $HOME/$local_saved_directory/$step_name_suffix ]]; then
    mkdir $HOME/$local_saved_directory/$step_name_suffix
fi


# enter directory $1
cd "$1"

# generate record file
files_count=`ls |wc -l`
echo -e "\n\n[Stream Directory path: "$1" count: $files_count]" >> "$HOME/$local_saved_directory/$step_name_suffix/Step5-old-new-one-to-one.txt" 
echo -e "\n\n[Stream Directory path: "$1" count: $files_count]"  >> $HOME/$local_saved_directory/$step_name_suffix/Step2-Unidentified_track_type.txt
echo -e "\n\n[Stream Directory path: "$1" count: $files_count]"  >> $HOME/$local_saved_directory/$step_name_suffix/Step3-Unidentified_resolution.txt
echo -e "\n\n[Stream Directory path: "$1" count: $files_count]"  >> $HOME/$local_saved_directory/$step_name_suffix/Step4-steam_exist_in_xml.txt


# check whether file name is valid.
# if not, modify name.
check_file_name_is_valid "$local_stream_path"

# as per name rule, modify name.
count=0
fit_file_number=0
for a in `ls`
do
 
    let count+=1
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>loop: $count begin"
    echo "$a"
    #set all global variable to empty
    global_variable_configure_default
    
    # check whether mediainfo contain  general/video/audio/audio 1/audio 2 track type.
    # <track type="General">
    # <track type="Video">
    # <track type="Audio">
    # <track type="Audio" typeorder="1">
    # <track type="Audio" typeorder="2">
    check_track_type

    # Now only handle 3 conditions below, skip others:
    # 1, track type: general + video                     => only_video=true
    # 2, track type: general + video + audio             => video_audio=true
    # 3, track type: general + video + audio1 + audio2   => video_audio1_audio2=true
    if [[ -z $only_video ]] && [[ -z $video_audio ]] && [[ -z $video_audio1_audio2 ]]; then
        echo "[$count][Erorr] : "$a"  Error: track type mismatch, please check  "  >> $HOME/$local_saved_directory/$step_name_suffix/Step5-old-new-one-to-one.txt
        echo "[$count][Erorr] : "$a"  Error: track type mismatch, please check  "  >> $HOME/$local_saved_directory/$step_name_suffix/Step2-Unidentified_track_type.txt
        mediainfo -f --${lower_upper_output}=XML "$a" | grep -i "track type" >> $HOME/$local_saved_directory/$step_name_suffix/Step2-Unidentified_track_type.txt
	if [[ ! -d $HOME/$local_saved_directory/Unidentified_track_type ]]; then
            mkdir $HOME/$local_saved_directory/Unidentified_track_type
        fi
	cp -rf "$a" $HOME/$local_saved_directory/Unidentified_track_type/"$a"
        mediainfo -f --${lower_upper_output}=XML "$a" 
        echo "Error: track type mismatch, please check $a"
        print_help
        echo -e "Continue\n\n"
        echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>loop: $count end"
        echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>loop: fit number: $fit_file_number  end"
        echo -e "\n\n\n"
        continue
    fi
 
    # calculate track type line arrange for getting the attribute of corresponding track type 
    calculate_track_type_line_arrange 


    # According to 3 conditions, parse the corresponding parameter
    if [[ ! -z $only_video ]]; then
        parse_general
        parse_video 100 $a
    fi
     
    if [[ ! -z $video_audio ]]; then
        parse_general
        parse_video $video_audio_line_arrange $a
        if [[ ! -z $audio_menu_line_arrange ]]; then
            parse_audio $audio_menu_line_arrange
        else
            parse_audio 100
        fi 
        
    fi
  
    if [[ ! -z $video_audio1_audio2 ]]; then
        parse_general
        parse_video $video_audio1_line_arrange $a
        parse_audio_1 $auido1_audio2_line_arrange
        parse_audio_2 100
    fi
   
    # generate final name as per name rule 
    generate_final_name_as_per_name_rule

    # check whether the same file exist, if exist, not move, copy to maybe_same_file directory
    # how to judge:
    # oldname + file_size +  new_name are the same.
    check_same_file_in_xml "$a" "${final_name_as_per_name_rule}" "$count"
    if [[ $continue_flag == true ]]; then
        echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>loop: $count end"
        echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>loop: fit number: $fit_file_number  end"
        echo -e "\n\n\n"
	continue
    fi
    # create video_format directory if not exist
    # copy to the according directory,and change name.
    if [[ ! -z $local_steam_backup ]]; then
        create_local_video_format_directory_and_move $count
        if [[ $continue_flag == true ]]; then
            echo  "ERROR: width_height_pixel is not identified: `echo $name_part3_part4_local_video_width_height | sed -e "s/^_//g"`"
	    echo -e "Continue\n\n"
            echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>loop: $count end"
            echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>loop: fit number: $fit_file_number  end"
            echo -e "\n\n\n"
            continue
        fi
    fi 
    # create video_format directory at remte server if not exist
    # copy to the according directory,and change name.

        create_remote_video_format_directory_and_move $count
        if [[ $continue_flag == true ]]; then
            echo  "ERROR: width_height_pixel is not identified: `echo $name_part3_part4_local_video_width_height | sed -e "s/^_//g"`"
	    echo  "or"
	    echo  "ERROR: ${final_name_as_per_name_rule} not in $HOME/$remote_mounted_direcotry"
            echo -e "Continue\n\n"
	    if [[ $fit_file == true ]]; then
                let fit_file_number+=1 
            fi
            echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>loop: $count end"
            echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>loop: fit number: $fit_file_number  end"
            echo -e "\n\n\n"
            continue
        fi
    # archive to xml as per  oldname newname video_part audio_part/audio1_part audio2_part
    if [[ ! -z $only_video ]]; then
        #create_row_template "$HOME/$local_saved_directory/$summary_xml_name"
	create_row_template_with_file_size_profile_level "$HOME/$local_saved_directory/$summary_xml_name"
        add_parsed_parameters_into_row_template_for_only_video "$HOME/$local_saved_directory/$summary_xml_name" "$a"
    fi
     
    if [[ ! -z $video_audio ]]; then
        #create_row_template "$HOME/$local_saved_directory/$summary_xml_name"
	create_row_template_with_file_size_profile_level "$HOME/$local_saved_directory/$summary_xml_name"
        add_parsed_parameters_into_row_template_for_video_audio "$HOME/$local_saved_directory/$summary_xml_name"   "$a"
        
    fi
  
    if [[ ! -z $video_audio1_audio2 ]]; then
        #create_row_template "$HOME/$local_saved_directory/$summary_xml_name"
	create_row_template_with_file_size_profile_level "$HOME/$local_saved_directory/$summary_xml_name" 
        add_parsed_parameters_into_row_template_for_video_audio1_audio2 "$HOME/$local_saved_directory/$summary_xml_name" "$a" 
    
    fi
    
    file_in_remote_is_in_xml=`cat $HOME/$local_saved_directory/$summary_xml_name  | grep  "${final_name_as_per_name_rule}"`
    if [[ ! -z $file_in_remote_is_in_xml ]]; then
        echo "[$count][Success] : "$local_stream_path"/"$a" ------> $HOME/$remote_mounted_direcotry/$classification_directory_name/$display_resolution/"${final_name_as_per_name_rule}""  >> $HOME/$local_saved_directory/$step_name_suffix/Step5-old-new-one-to-one.txt
    else
	rm -rf $HOME/$remote_mounted_direcotry/$classification_directory_name/$display_resolution/"${final_name_as_per_name_rule}"
        echo "[$1][Failure][not in xml] : "$local_stream_path"/"$a" ------> $HOME/$remote_mounted_direcotry/$classification_directory_name/$display_resolution/"${final_name_as_per_name_rule}""  >> $HOME/$local_saved_directory/$step_name_suffix/Step5-old-new-one-to-one.txt
    fi
    let fit_file_number+=1 


    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>$a"
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"${final_name_as_per_name_rule}""
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>loop: $count end"
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>loop: fit number: $fit_file_number  end"
    echo -e "\n\n\n"
done

Unidentified_track_type=`cat $HOME/$local_saved_directory/$step_name_suffix/Step2-Unidentified_track_type.txt  | grep -i   "Error: track type mismatch, please check"`
if [[ ! -z $Unidentified_track_type ]]; then
    echo "######################Unidentified_track_type "
    echo "######################please contact Ming.Dong, let him check"
    echo "`cat $HOME/$local_saved_directory/$step_name_suffix/Step2-Unidentified_track_type.txt  | grep -i   "Error: track type mismatch, please check"`"
    echo -e "\n\n"
fi

Unidentified_resolution=`cat $HOME/$local_saved_directory/$step_name_suffix/Step3-Unidentified_resolution.txt  | grep -i   "\[Failure\]\[width_height_pixel:"`
if [[ ! -z $Unidentified_resolution ]]; then
    echo "######################Unidentified_resolution "
    echo "######################please contact Ming.Dong, let him add the corresponding width_height_pixel"
    echo "`cat $HOME/$local_saved_directory/$step_name_suffix/Step3-Unidentified_resolution.txt  | grep -i   "[Failure][width_height_pixel:"`"
    echo -e "\n\n"
fi

Already_exist_in_xml=`cat $HOME/$local_saved_directory/$step_name_suffix/Step4-steam_exist_in_xml.txt  | grep -i   "Already Exist"`
if [[ ! -z $Already_exist_in_xml ]]; then
    echo "######################WARNING: Already_exist_in_xml "
    echo "######################please contact Ming.Dong, let him check"
    echo "`cat $HOME/$local_saved_directory/$step_name_suffix/Step4-steam_exist_in_xml.txt  | grep -i   "Already Exist"`"
    echo -e "\n\n"
fi

echo "origin remote avail space: [$remote_avail_space]"
echo "local steam space: [$local_steam_space]"
echo "remain remote avail space: [$remain_remote_avail_space]"
if [[ `cat $HOME/$local_backup_file_directory/remote_space.txt` -le 5242880 ]]; then 
    echo "######################Failure: please contact Ming.Dong, let them check remote server space"
    echo "Error: Remote server atgasia01 avail space <= 5G, please check"
    echo -e "\n\n"
fi

total_number_in_xml=`cat $HOME/$local_saved_directory/$summary_xml_name  | grep "ss:Type=\"Number\">" | awk -F ">" '{print $3}' | awk -F "<" '{print $1}' | sort -n | tail -1`
echo -e "\ntotal_number_in_xml=$total_number_in_xml, last_number_in_xml=$last_number_in_xml"
number_in_xml=$(( $total_number_in_xml - $last_number_in_xml ))
echo -e  "New: $number_in_xml in $HOME/$local_saved_directory/$summary_xml_name"
total_numer_in_remote=`find $HOME/$remote_mounted_direcotry -name "*.*" | wc -l`
echo "total_numer_in_remote=$total_numer_in_remote, last_numer_in_remote=$last_numer_in_remote"
numer_in_remote=$(( $total_numer_in_remote - $last_numer_in_remote ))
echo "New: $numer_in_remote in $HOME/$remote_mounted_direcotry"
echo -e "\n\n[Stream Directory path: "$1" total_count: $files_count fit_count:$fit_file_number number_in_xml:$number_in_xml  numer_in_remote:$numer_in_remote]"  >> $HOME/$local_saved_directory/$step_name_suffix/Step6-xml_remote_consistence.txt
if [[ $number_in_xml == $numer_in_remote ]] && [[ $numer_in_remote == $fit_file_number ]]; then
   echo "Success: remote files number: $numer_in_remote in $HOME/$remote_mounted_direcotry/"
   echo "Success:    xml files number: $number_in_xml in $HOME/$local_saved_directory/$summary_xml_name"
   echo "Success: $fit_file_number fit files which be  moved to $HOME/$remote_mounted_direcotry/ and record in $HOME/$local_saved_directory/$summary_xml_name"
   echo "Success: xml and remote Consistence check PASS!"
fi

if [[ $number_in_xml -lt  $fit_file_number ]] || [[ $numer_in_remote -lt $fit_file_number ]]; then
   echo "######################please contact Ming.Dong, let him check"
   echo "Warning: all fit files is $fit_file_number, but actually not all fit files which be  moved to $HOME/$remote_mounted_direcotry/ and record in $HOME/$local_saved_directory/$summary_xml_name"
   echo "Warning: remote files number: $numer_in_remote in $HOME/$remote_mounted_direcotry/"
   echo "Warning:    xml files number: $number_in_xml in $HOME/$local_saved_directory/$summary_xml_name"
   if [[ $number_in_xml == $numer_in_remote ]]; then
       echo "Success: xml and remote Consistence check PASS!"
   else
       echo "FATAL ERROR: xml and remote Consistence check Failed!"
       cat $HOME/$local_saved_directory/$step_name_suffix/Step5-old-new-one-to-one.txt | grep "\[Failure\]\[not in xml\]"
       cat $HOME/$local_saved_directory/$step_name_suffix/Step5-old-new-one-to-one.txt | grep "\[Failure\]\[not in remote\]" 
   fi
fi

echo -e "\n>>>>>>>>>> end <<<<<<<<<<\n"
