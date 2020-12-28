#!/bin/bash
echo
echo '###############################################'
echo '##                                            ##'
echo '## Welcome to the Splunk 7.0.2 auto-installer ##'
echo '## for CentOS 7 x64.                          ##'
echo '## Last updated 12/21/2020.                   ##'
echo '## Enter the "splunk" linux user account      ##'
echo '## password and press enter to let the magic  ##'
echo '################################################'
echo
echo

### need to devolop later
yum_function()
{
echo "Program is cheking YUM package is Install?"
}

### need to devolop later
wget_function()
{
echo "Program is cheking Wget package is Install?"
yum install wget -y
}

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

#Host user login function.
user_login_func()
{
PS1='Please enter your choice: '
echo "$PS1"
options1=("splunk" "root" "Quit")
select splunk_user_type in "${options1[@]}"
do
    case "$splunk_user_type" in
        "splunk")
            break
            ;;
        "root")
            break
            ;;
        "Quit")
            exit
            ;;
        *) ;;
    esac
done
}


thp_setting_func()
{
# User input for knowing is THP action will be performed or not.
echo "Is you want to setup Transparent Hugepage Pages settting? (YES/NO)"
choice_fun
if [[ "$confirm" == YES ]];
  then
    thp_fun
else
       echo "Continue without changing THP seeting"
fi

}

# This function is for Transparent Hugepage Pages.
thp_fun() {

echo "never" > /sys/kernel/mm/transparent_hugepage/enabled
echo "never" > /sys/kernel/mm/transparent_hugepage/defrag
echo "[Unit]" > /etc/systemd/system/disable-thp.service
echo "Description=Disable Transparent Huge Pages" >> /etc/systemd/system/disable-thp.service
echo "" >> /etc/systemd/system/disable-thp.service
echo "[Service]" >> /etc/systemd/system/disable-thp.service
echo "Type=simple" >> /etc/systemd/system/disable-thp.service
echo 'ExecStart=/bin/sh -c "echo never > /sys/kernel/mm/transparent_hugepage/enabled && echo never > /sys/kernel/mm/transparent_hugepage/defrag"' >> /etc/systemd/system/disable-thp.service
echo "Type=simple" >> /etc/systemd/system/disable-thp.service
echo "" >> /etc/systemd/system/disable-thp.service
echo "[Install]" >> /etc/systemd/system/disable-thp.service
echo "WantedBy=multi-user.target" >> /etc/systemd/system/disable-thp.service
systemctl daemon-reload
systemctl start disable-thp
systemctl enable disable-thp

echo "Transparent Huge Pages (THP) Disabled."

}

ulimits_setting_func()
{
# User input for knowing is Ulimits action will be performed or not.
echo "Is you want to setup Ulimit?"
choice_fun
if [[ "$confirm" == YES ]];
  then
    thp_fun
else
       echo "Continue without changing ulimit seeting"
fi
}

#this function is for changing the ulimit
ulimit_fun()
{
ulimit -n 64000
ulimit -u 20480
echo "DefaultLimitFSIZE=-1" >> /etc/systemd/system.conf
echo "DefaultLimitNOFILE=64000" >> /etc/systemd/system.conf
echo "DefaultLimitNPROC=20480" >> /etc/systemd/system.conf
echo
echo "ulimit Increased."
echo
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
elif [[ "$confirm" == No ]];
   then
        echo "Program now skip the basic splunk configuration task."
fi

if [[ "$splunk_user_type" == root ]];
  then
    echo
    chown -R "$SPLUNK_USERNAME":"$SPLUNK_USERNAME" /opt/"$splunk_type"/*
  else
    echo "You already install splunk as splunk user"
fi

if [[ "$splunk_user_type" == root ]]
  then
    echo "Root user start splunk as splunk User ""$SPLUNK_USERNAME"
    chown -R "$SPLUNK_USERNAME":"$SPLUNK_USERNAME" /opt/"$splunk_type"/*
    chown -R "$SPLUNK_USERNAME":"$SPLUNK_USERNAME" /opt/"$splunk_type"/
    su "$SPLUNK_USERNAME"
    /opt/"$splunk_type"/bin/splunk start --accept-license
  else
    echo "Splunk start as splunk User ""$SPLUNK_USERNAME"
    /opt/"$splunk_type"/bin/splunk start --accept-license
fi
}

splunk_user_func()
{
echo
if [[ "$USER_SPLUNK" == root ]];
    then
      echo "Changing to splunk user"
      runuser -l "$SPLUNK_USERNAME"
      comman_task_function
    else
      echo "Program will perform Splunk User Task"
      comman_task_function
fi
}

root_user_func()
{

if [[ "$USER_SPLUNK" == root ]];
    then
      echo "Performing the root task"
      root_user_task_func
else
    echo "You are not login as root. We are switching as root"
    su root
    root_user_task_func
fi
}

root_user_task_func()
{
thp_setting_func
ulimits_setting_func
comman_task_function
}


printf "Please Enter splunk username that you want to install Splunk (splunk_p, splunk_q or splunk_d): \n"
read -r SPLUNK_USERNAME
USER_SPLUNK=$(whoami)
echo "You are currently login as = " "$USER_SPLUNK"
echo
echo
user_login_func
echo

if [[ "$splunk_user_type" == splunk  ]];
   then
        echo "Program will perform task as splunk user."
        splunk_user_func
else
        echo "Program will perform task as root user."
        root_user_func
fi


echo
to_do_func()
{
## To do for enable boot start
echo "Splunk test start and stop complete. Enabled Splunk to start at boot."
echo
USER_SPLUNK2=$(whoami)
if [[ "$USER_SPLUNK2" == root  ]];
  then
    runuser -l "$SPLUNK_USERNAME" -c "/opt/""$splunk_type""/bin/splunk start"
  else
      "$(/opt/""$splunk_type""/bin/splunk start)"
fi
}

if [[ -f /opt/"$splunk_type"/bin/splunk ]]
        then
                echo Splunk Enterprise
                cat /opt/"$splunk_type"/etc/splunk.version | head -1
                echo "has been installed, configured, and started!"
                echo "Visit the Splunk server using https://hostNameORip:8000 as mentioned above."
                echo
                echo
                echo "           HAPPY SPLUNKING!!!"
                echo
                echo
                echo
        else
                echo Splunk Enterprise has FAILED install!
fi


#rm -f /tmp/splunk-7.0.2-03bbabbd5c0f-Linux-x86_64.tgz
#useradd splunk
#echo splunk:$splunkPassword > /tmp/pwdfile
#cat /tmp/pwdfile | chpasswd
#rm -f /tmp/pwdfile



#/opt/splunk/bin/splunk enable boot-start -user splunk
#runuser -l splunk -c '/opt/splunk/bin/splunk stop'
#chown root:splunk /opt/splunk/etc/splunk-launch.conf
#chmod 644 /opt/splunk/etc/splunk-launch.conf
#End of File
firewall_fun()
{
  afz=`firewall-cmd --get-active-zone | head -1`
  firewall-cmd --zone=$afz --add-port=8000/tcp --permanent
  firewall-cmd --zone=$afz --add-port=8065/tcp --permanent
  firewall-cmd --zone=$afz --add-port=8089/tcp --permanent
  firewall-cmd --zone=$afz --add-port=8191/tcp --permanent
  firewall-cmd --zone=$afz --add-port=9997/tcp --permanent
  firewall-cmd --zone=$afz --add-port=8080/tcp --permanent
  firewall-cmd --zone=$afz --add-port=10514/udp --permanent
  firewall-cmd --reload
  echo
  echo "Firewall ports used by Splunk opened."
}
