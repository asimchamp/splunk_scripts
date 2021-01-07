#! /bin/bash

# set number of bucket rebuild in one time

_maxChildProcs=1

# read the index name
echo "Please enter the index name :"
read -r index_name

# set the path where bucket will be copyed
restore_path=(/Isilon-cold/thawedb/)

# index path to restore
echo "bucket will be copy in"
echo "$restore_path"

host=$(hostname)

#full index restore_path

thawed_path=(/Isilon-cold/forzen-temp/"$host"/"$index_name")

echo "orignal path to copy bucket ="
echo "$thawed_path"


echo "Enter the start time (earliest_time) :(mm/dd/yyyy)"
read -r earliest_time

echo "enter the end time (latest_time) :(mm/dd/yyyy)"
read -r latest_time

# epoch Earliest time function #
earliest_epoch=$(date "+%s" -d "$earliest_time"" 00:00:00")

# epoch Latest time function #
latest_epoch=$(date "+%s" -d "$latest_time"" 00:00:00")

echo "Earliest time =""$earliest_epoch"

echo "Latest time =""$latest_epoch"

index_present=$(ls /Isilon-cold/thawedb/ | grep "$index_name" | wc -l )
if [[ "$index_present" == 1 ]];
   then
   echo "Index Folder already created"
   echo "script performing copy process"
   bucket_id=$(ls -d "$thawed_path"/* | grep db | awk -F"_" -v et="$earliest_epoch" -v lt="$latest_epoch", '$4>=et && $4<=lt{print $0"/"}')
   echo "$bucket_id" > bucket.txt
   cat /Isilon-cold/bucket.txt | while read line; do cp -r "$line" "$restore_path""$index_name"/; done
else
   echo "Index folder not present"
   cd "$restore_path" || exit
   mkdir "$index_name"
   echo "script performing copy process"
   bucket_id=$(ls -d "$thawed_path"/* | grep db | awk -F"_" -v et="$earliest_epoch" -v lt="$latest_epoch", '$4>=et && $4<=lt{print $0"/"}')
   echo "$bucket_id" > bucket.txt
   cat /Isilon-cold/bucket.txt | while read line; do cp -r "$line" "$restore_path""$index_name"/; done
fi
