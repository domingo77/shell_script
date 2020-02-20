#!/bin/bash



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


create_row_template_with_file_size $1 
