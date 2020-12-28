#!/bin/bash
echo
echo '#################################################'
echo '## Only for Non-root user                      ##'
echo '## Welcome to the Splunk Linux auto-installer  ##'
echo '## for Redhat 7.x x64.                         ##'
echo '## Last updated 12/21/2020.                    ##'
echo '## Enter the "splunk" linux user account       ##'
echo '## Press enter to let the Magic                ##'
echo '#################################################'
echo
echo
echo " _        _____   _        _       __     __      _____   _____    _        _    _   _   _   _  __ "
echo "| |      |_   _| | |      | |      \ \   / /     / ____| |  __ \  | |      | |  | | | \ | | | |/ / "
echo "| |        | |   | |      | |       \ \_/ /     | (___   | |__) | | |      | |  | | |  \| | |   /  "
echo "| |        | |   | |      | |        \   /       \___ \  |  ___/  | |      | |  | | |     | |  \   "
echo "| |____   _| |_  | |____  | |____     | |        ____) | | |      | |____  | |__| | | |\  | |   \  "
echo "|______| |_____| |______| |______|    |_|       |_____/  |_|      |______|  \____/  |_| \_| |_|\_\ "
echo

# This function is use for user confirmation menu
choice_fun()
{
CH1='Please confirm your choice: '
echo "$CH1"
options2=("Yes" "No" "Quit")
select confirm in "${options2[@]}"
do
    case "$confirm" in
        "Yes")
            break
            ;;
        "No")
            break
            ;;
        "Quit")
            exit
            ;;
        *) ;;
    esac
done
}

# Function for choosing splunk type:
splunk_type_func()
{
CH2='Please enter your choice: '
echo "$CH2"
options1=("splunk" "splunkforwarder" "Quit")
select splunk_type in "${options1[@]}"
do
    case "$splunk_type" in
        "splunk")
            break
            ;;
        "splunkforwarder")
            break
            ;;
        "Quit")
            exit
            ;;
        *) ;;
    esac
done
}


splunk_configuration_func()
{
  echo "[settings]" > /opt/"$splunk_type"/etc/system/local/web.conf
  echo "enableSplunkWebSSL = true" >> /opt/"$splunk_type"/etc/system/local/web.conf
  echo
  echo "HTTPS enabled for Splunk Web using self-signed certificate."
  echo "[splunktcp]" > /opt/"$splunk_type"/etc/system/local/inputs.conf
  echo "[splunktcp://9997]" >> /opt/"$splunk_type"/etc/system/local/inputs.conf
  echo "index = main" >> /opt/"$splunk_type"/etc/system/local/inputs.conf
  echo "disabled = 0" >> /opt/"$splunk_type"/etc/system/local/inputs.conf
  echo "" >> /opt/"$splunk_type"/etc/system/local/inputs.conf
  echo "[udp://10514]" >> /opt/"$splunk_type"/etc/system/local/inputs.conf
  echo "index = main" >> /opt/"$splunk_type"/etc/system/local/inputs.conf
  echo "disabled = 0" >> /opt/"$splunk_type"/etc/system/local/inputs.conf
  echo
  echo "Enabled Splunk TCP input over 9997 and UDP traffic input over 10514."
  echo
}

comman_task_function()
{
echo "Enter Splunk Type that you want to install. (splunk/splunkforwarder)"
echo
splunk_type_func
echo
echo "Your Choice is = ""$splunk_type"
echo

# Confirmation for splunk type:
choice_fun
if [[ "$confirm" == Yes ]];
   then
        echo "continue"
elif [[ "$confirm" == No ]];
   then
        echo "Please Re-Enter Splunk Type that you want to install."
        splunk_type_func
fi

cd /opt/
sed -i -e "s/[']$//; s/[']//g" /opt/splunk_downloader/splunk_url.txt
download_pkg=$(cat /opt/splunk_downloader/splunk_url.txt | grep "$splunk_type"- | awk '{print $3}')
download_url=$(cat /opt/splunk_downloader/splunk_url.txt | grep "$splunk_type"- | awk '{print $4}')
## Downloading for splunk File
echo "$download_url" > /opt/splunk_downloader/url.txt
wget -i /opt/splunk_downloader/url.txt -O "$download_pkg"
echo
echo "Splunk Downloaded in /opt location."
echo
SPLUNK_PKG=$(ls /opt/ | grep "$splunk_type"- | awk '{print $1}' )
tar -xzvf "$SPLUNK_PKG" -C /opt
echo
echo "Splunk installed at /opt location."
echo
echo "Is you want to setup basic splunk configuration?"
choice_fun
if [[ "$confirm" == Yes ]];
   then
        echo "Now Program is doing setup of basic splunk configuration?"
        splunk_configuration_func
   else
        echo "Program now skip the basic splunk configuration task."
fi
echo
echo "Basic splunk configuration successfully update."
echo
echo "Splunk start by splunk User ""$SPLUNK_USERNAME"
/opt/"$splunk_type"/bin/splunk start --accept-license
echo
}



printf "Please Enter splunk username that you want to install Splunk (splunk_p, splunk_q or splunk_d): \n"
read -r SPLUNK_USERNAME
USER_SPLUNK=$(whoami)
echo "You are currently login as = " "$USER_SPLUNK"
echo
echo
echo

if [[ "$SPLUNK_USERNAME" == splunk_*  ]];
   then
        echo "Program will perform task as splunk user."
        comman_task_function
else
        echo "You are not login as splunk user. Please login as splunk user and re-run script."
        exit
fi
echo


if [[ -f /opt/"$splunk_type"/bin/splunk ]]
        then
            echo Splunk Enterprise
            cat /opt/"$splunk_type"/etc/splunk.version | head -1
            echo "has been installed, configured, and started!"
            echo "Visit the Splunk server using https://hostNameORip:8000 as mentioned above."
            echo
            echo
            echo "     !!!HAPPY SPLUNKING!!! :-D"
            echo
            echo
            echo
        else
                echo "Splunk Enterprise has FAILED install!"
fi
