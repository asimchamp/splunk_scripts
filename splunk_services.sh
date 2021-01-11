#!/bin/bash
echo
echo '#################################################'
echo '## Only for Non-root user                      ##'
echo '## Welcome to the Splunk Linux auto-installer  ##'
echo '## for Redhat 7.x x64.                         ##'
echo '## Last updated 12/21/2020.                    ##'
echo '## Enter the "splunk" linux user account       ##'
echo '## Press Enter and lets the Magic Begins       ##'
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

# Function for choosing splunk type:
splunk_install_func()
{
CH3='Please enter your choice: '
echo "$CH3"
options1=("upgrade" "fresh_install" "Quit")
select splunk_install_type in "${options1[@]}"
do
    case "$splunk_install_type" in
        "upgrade")
            break
            ;;
        "fresh_install")
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
  echo
  echo "Basic splunk configuration successfully update."
  echo
  ## We will add more splunk configuration in future ##

}

splunk_fresh_install_func()
{
echo "Is you want to setup basic splunk configuration?"
choice_fun
if [[ "$confirm" == Yes ]];
   then
        echo "Now Program is doing setup of basic splunk configuration?"
        splunk_configuration_func
   else
        echo "Program now skip the basic splunk configuration task."
fi
}

install_upgrade_checking_func()
{
if [[ -f /opt/"$splunk_type"/bin/splunk ]];
   then
      echo Splunk Enterprise current version
      cat /opt/"$splunk_type"/etc/splunk.version | head -1
      echo
   else
     echo "Splunk not install please choose Fresh_install option."
     splunk_install_func
fi
}

install_fresh_checking_func()
{
if [[ -f /opt/"$splunk_type"/bin/splunk ]];
   then
      echo "Splunk already install, Please choose Upgrade option..."
      echo Splunk Enterprise current version
      cat /opt/"$splunk_type"/etc/splunk.version | head -1
      echo
      splunk_install_func
   else
     echo "Splunk not install please choose Fresh_install option..."
     splunk_install_func
fi
}

splunk_version_func()
{
spl_version=$(cat /opt/"$splunk_type"/etc/splunk.version | head -1 | awk -F"=" '{print $2}' | sed 's/\.//; s/\.//')
splunk_version=$(cat /opt/"$splunk_type"/etc/splunk.version | head -1 | awk -F"=" '{print $2}')
if [[ "$spl_version" == "$spl_num" ]];
   then
     echo
     echo "Splunk version are same in URL list file, Please update latest download URL in splunk_url.txt file."
     echo "Install Version =""$splunk_version"," Download Version =""$version_splunk"
     exit
elif [[ "$spl_version" > "$spl_num" ]];
   then
     echo
     echo "Splunk version are Lower in URL list file, Please update latest download URL in splunk_url.txt file."
     echo "Install Version =""$splunk_version"," Download Version =""$version_splunk"
     exit
   else
     echo
     echo "Splunk version are Higher in URL list file, Please update latest download URL in splunk_url.txt file."
     echo "Install Version =""$splunk_version"," Download Version =""$version_splunk"
fi
}

splunkforwarder_version_func()
{
spl_version=$(cat /opt/"$splunk_type"/etc/splunk.version | head -1 | awk -F"=" '{print $2}' | sed 's/\.//; s/\.//')
splunk_version=$(cat /opt/"$splunk_type"/etc/splunk.version | head -1 | awk -F"=" '{print $2}')
if [[ "$spl_version" == "$spf_num" ]];
   then
     echo
     echo "Splunk version are same in URL list file, Please update latest download URL in splunk_url.txt file."
     echo "Install Version =""$splunk_version"," Download Version =""$version_splunkforwarder"
     exit
elif [[ "$spl_version" > "$spf_num" ]];
   then
     echo
     echo "Splunk version are Lower in URL list file, Please update latest download URL in splunk_url.txt file."
     echo "Install Version =""$splunk_version"," Download Version =""$version_splunkforwarder"
     exit
   else
     echo
     echo "Splunk version are Higher in URL list file, Please update latest download URL in splunk_url.txt file."
     echo "Install Version =""$splunk_version"," Download Version =""$version_splunkforwarder"
fi
}


splunk_upgrade_func()
{
if [[ "$splunk_type" == splunk ]];
   then
      echo "Checking splunk version Higher or not..."
      splunk_version_func
   else
     echo "Checking splunkforwarder version Higher or not..."
     splunkforwarder_version_func
fi
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
echo
echo "Enter splunk upgrade type:"
echo
splunk_install_func
echo
if [[ "$splunk_install_type" == upgrade ]];
   then
     echo
     echo "For upgrade, Checking Splunk Already Install or not..."
     install_upgrade_checking_func
     echo
   else
     echo "For fresh_install, Checking Splunk Already Install or not..."
     install_fresh_checking_func
fi
echo

cd /opt/
sed -i -e "s/[']$//; s/[']//g" /opt/splunk_downloader/splunk_url.txt
download_pkg=$(cat /opt/splunk_downloader/splunk_url.txt | grep "$splunk_type"- | awk '{print $3}')
download_url=$(cat /opt/splunk_downloader/splunk_url.txt | grep "$splunk_type"- | awk '{print $4}')
## Downloading for splunk File
echo "$download_url" > /opt/splunk_downloader/url.txt
version_splunk=$(cat /opt/splunk_downloader/splunk_url.txt | grep "$splunk_type"-  | cut -c16-20)
version_splunkforwarder=$(cat /opt/splunk_downloader/splunk_url.txt | grep "$splunk_type"-  | cut -c25-29)
spl_num=$(cat /opt/splunk_downloader/splunk_url.txt | grep "$splunk_type"-  | cut -c16-20 | sed 's/\.//; s/\.//')
spf_num=$(cat /opt/splunk_downloader/splunk_url.txt | grep "$splunk_type"-  | cut -c25-29 | sed 's/\.//; s/\.//')
echo

if [[ "$splunk_install_type" == upgrade ]];
   then
      echo "Perform Splunk version checking task..."
      splunk_upgrade_func
   else
      echo "Skiping Splunk version task for fresh_install.."
fi

wget -i /opt/splunk_downloader/url.txt -O "$download_pkg"
echo
echo "Splunk Downloaded in /opt location."
echo
if [[ "$splunk_type" == splunk ]];
   then
       curl https://download.splunk.com/products/"$splunk_type"/releases/"$version_splunk"/linux/"$download_pkg".md5 --output "$download_pkg".md5
   else
       curl https://download.splunk.com/products/universalforwarder/releases/"$version_splunkforwarder"/linux/"$download_pkg".md5 --output "$download_pkg".md5
fi

md_file=$(md5sum /opt/"$download_pkg" | awk '{print $1}')
main_md=$(cat /opt/"$download_pkg".md5 | awk '{print $4}')
echo
if [[ "$main_md" == "$md_file" ]];
   then
       echo "md5 value is Match and correct."
       echo "$main_md"
else
    echo "md5 is not Match."
    exit
fi
echo
SPLUNK_PKG=$(ls /opt/ | grep "$splunk_type"- | grep -v md5 | awk '{print $1}' )
tar -xzvf "$SPLUNK_PKG" -C /opt
echo
echo "Splunk installed at /opt location."
echo
if [[ "$splunk_install_type" == fresh_install ]];
   then
      splunk_fresh_install_func
   else
      echo "Skipiking the Splunk Basic configuration beacuse of upgrading the splunk..."
fi
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


if [[ -f /opt/"$splunk_type"/bin/splunk ]];
        then
            echo Splunk Enterprise
            cat /opt/"$splunk_type"/etc/splunk.version | head -1
            echo "has been installed, configured, and started!"
            echo
            echo
            echo "     !!!HAPPY SPLUNKING!!! :-D"
            echo
            echo
            echo
        else
                echo "Splunk Enterprise has FAILED install!"
fi
