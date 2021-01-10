#! /bin/bash

splunk_bucket_type_func()
{
CH2='Please enter your choice: '
echo "$CH2"
options1=("db" "rb" "All" "Quit")
select bucket_type in "${options1[@]}"
do
    case "$bucket_type" in
        "db")
            break
            ;;
        "rb")
            break
            ;;
        "All") 
            break
            ;;
        "Quit")
            exit
            ;;
        *) ;;
    esac
done
}


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

thawed_path=(/Isilon-cold/forzen-temp/"$host"/"$index_name"/)

echo "orignal path to copy bucket ="
echo "$thawed_path"
echo
echo "Please Enter the Splunk Bucket Type :"
splunk_bucket_type_func


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

list_func()
{

if [[ "$bucket_type" == All ]];
   then
      bucket_id1=$(ls -d "$thawed_path"* | awk -F"/" '{print $6}' | awk -F"_" -v et="$earliest_epoch" -v lt="$latest_epoch", '$2>=et && $2<=lt{print $0"/"}')
      bucket_id2=$(ls -d "$thawed_path"* | awk -F"/" '{print $6}' | awk -F"_" -v et="$earliest_epoch" -v lt="$latest_epoch", '$3>=et && $3<=lt{print $0"/"}')
   else
      bucket_id1=$(ls -d "$thawed_path"* | grep "$bucket_type" | awk -F"/" '{print $6}' | awk -F"_" -v et="$earliest_epoch" -v lt="$latest_epoch", '$2>=et && $2<=lt{print $0"/"}')
      bucket_id2=$(ls -d "$thawed_path"* | grep "$bucket_type" | awk -F"/" '{print $6}' | awk -F"_" -v et="$earliest_epoch" -v lt="$latest_epoch", '$3>=et && $3<=lt{print $0"/"}')
fi

echo "$bucket_id1" > /Isilon-cold/thawedb/bucket.txt
echo "$bucket_id2" >> /Isilon-cold/thawedb/bucket.txt
sort /Isilon-cold/thawedb/bucket.txt | uniq > /Isilon-cold/thawedb/db_bucket.txt
bucket_id3=$(cat /Isilon-cold/thawedb/db_bucket.txt | awk -v th="$thawed_path", '{print th$0}')
echo "$bucket_id3" > /Isilon-cold/thawedb/db_bucket.txt
sed -i -e 's/,//' /Isilon-cold/thawedb/db_bucket.txt
}

index_present=$(ls /Isilon-cold/thawedb/ | grep "$index_name" | wc -l )
if [[ "$index_present" == 1 ]];
   then
   echo "Index Folder already created"
   echo "script performing copy process"
   list_func
   cat /Isilon-cold/thawedb/db_bucket.txt | while read line; do cp -r "$line" "$restore_path""$index_name"/; done
else
   echo "Index folder not present"
   cd "$restore_path" || exit
   mkdir "$index_name"
   echo "script performing copy process"
   list_func
   cat /Isilon-cold/thawedb/db_bucket.txt | while read line; do cp -r "$line" "$restore_path""$index_name"/; done
fi
