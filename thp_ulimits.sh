#!/bin/bash
echo
echo " _        _____   _        _       __     __      _____   _____    _        _    _   _   _   _  __ "
echo "| |      |_   _| | |      | |      \ \   / /     / ____| |  __ \  | |      | |  | | | \ | | | |/ / "
echo "| |        | |   | |      | |       \ \_/ /     | (___   | |__) | | |      | |  | | |  \| | |   /  "
echo "| |        | |   | |      | |        \   /       \___ \  |  ___/  | |      | |  | | |     | |  \   "
echo "| |____   _| |_  | |____  | |____     | |        ____) | | |      | |____  | |__| | | |\  | |   \  "
echo "|______| |_____| |______| |______|    |_|       |_____/  |_|      |______|  \____/  |_| \_| |_|\_\ "
echo
echo
echo '################################################'
echo '## Welcome to the Splunk Auto-Installer       ##'
echo '## Only for Root User                         ##'
echo '## for CentOS 7 x64.                          ##'
echo '## Last updated 12/21/2020.                   ##'
echo '## Enter the "splunk" linux user account      ##'
echo '## password and press enter to let the magic  ##'
echo '################################################'
echo
echo
echo "This script only perform by root user.If you are not login as root user"
echo "then script will automatically exited"
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


thp_setting_func()
{
# User input for knowing is THP action will be performed or not.
echo "Is you want to setup Transparent Hugepage Pages settting? (YES/NO)"
choice_fun
if [[ "$confirm" == Yes ]];
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
if [[ "$confirm" == Yes ]];
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


root_user_task_func()
{
thp_setting_func
ulimits_setting_func
echo
echo
echo "!!!! HAPPY SPLUNKING !!!! :-D"
}

USER_SPLUNK=$(whoami)
echo "You are currently login as = " "$USER_SPLUNK"
echo
#user_login_func
echo

if [[ "$USER_SPLUNK" == root  ]];
   then
        echo "You currently login as root. Script will performed all task."
        root_user_task_func
else
        echo "You are not login as root user. Please login as root user and run again script"
        exit
fi
