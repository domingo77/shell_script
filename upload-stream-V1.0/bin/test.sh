#!/bin/bash







local_path=$1
echo "[directory: "$1"]" > ~/test.txt
cat ~/test.txt |grep -i "$local_path"
