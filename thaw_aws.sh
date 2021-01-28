#! /bin/bash

splunk_bucket_type_func()
{
CH2='Please enter Splunk Bucket Type: '
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

# input file location
input_file=(/Isilon-cold/inputs.txt)
no=1
# read the index name
echo "Please Enter the Index Name:"
read -r index_name
echo index_name= "$index_name" > "$input_file"

# Read thr INC No
echo "Please Enuter the INC No:"
read -r inc_no
echo INC_NO= "$inc_no" >> "$input_file"

splunk_bucket_type_func
echo bucket_type= "$bucket_type" >> "$input_file"

echo "Enter the start time (earliest_time) :(mm/dd/yyyy)"
read -r earliest_time
echo earliest_time= "$earliest_time" >> "$input_file"

echo "enter the end time (latest_time) :(mm/dd/yyyy)"
read -r latest_time
echo  latest_time= "$latest_time" >> "$input_file"

scp ansible@centos"$no":"$input_file" ansible@ubuntu"$no":/Isilon-cold/

ssh ansible@ubuntu"$no" /Isilon-cold/thawdb.sh

scp -r ansible@ubuntu"$no":/Isilon-cold/"$inc_no"/ /Isilon-cold/
