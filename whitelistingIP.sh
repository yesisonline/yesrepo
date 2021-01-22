#!/bin/bash
########### Variables ##
setup="/opt/whitelist/script/"
whitelist="/opt/whitelist/script/whitelistip.csv"
vhost_conf="/etc/apache2/mods-available/website.com"
backup_vhost="/opt/whitelist/script/backupVhost"
log_file="/var/log/script/whitelist.log"
searchprm="Require ip"
whitelisted_ip="/etc/whitelist/script/whitelisted_ip.lst"
tmp1=/tmp/tmp1.log
iURL="https://drive.google.com/file/d/1dxQzHgXSqYuL0gc0uks6VHImLl3ePl6t/view?usp=sharing"

######## Funtions ##
function check_rc {
  if [ "$2" != "0" ];then
                         echo "`date "+%Y-%m-%d %H:%M:%S "` $1" | tee -a $log_file
                         #echo "$1" | mail -s "Error: Whitelistscript" root@localhost
  else
                         echo "`date "+%Y-%m-%d %H:%M:%S "` $1" | tee -a $log_file
                         #echo "$1" | mail -s "Whitelistscript" root@localhost i
  fi

}

function validate_url(){
  if [[ `wget -S --spider $1  2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then
                         echo "true"
  fi
}

################## Prerequisites ##

#Check if required files exisits
if [ ! -d $setup ];    then
                         echo "`date "+%Y-%m-%d %H:%M:%S "` Creating log file at $setup" >> $log_file
                         mkdirc -P /opt/whitelistIp/script/
fi

if [ ! -f $whitelist ];  then
                         check_rc "$whitelist doesent exists" "2"
fi

if [ ! -f $vhost_conf ]; then
                         check_rc "$vhost_conf doesent exists." "3"
fi

if [ ! -f $log_file ];   then
                         echo "`date "+%Y-%m-%d %H:%M:%S "` Creating log file at $log_file" >> $log_file
                         touch $log_file
fi

if [ ! -f $whitelisted_ip ]; then
                         echo "`date "+%Y-%m-%d %H:%M:%S "` Creating whitelisted IP list at $whitelisted_ip" >> $log_file
                         touch $whitelisted_ip
fi



#################### Main ##

### List currently whitelisted IP

                         echo "`date "+%Y-%m-%d %H:%M:%S "`  checking $searchprm into  $vhost_conf" >> $log_file
                         grep "${searchprm}" $vhost_conf | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' > $whitelisted_ip

### Check if difference whitelisted_ip and whitelist.conf
                         echo "`date "+%Y-%m-%d %H:%M:%S "` Downloading the $whitelist from $iURL" >> $log_file
                         wget -qP $iURL  /opt/script/
    # if [ $? -eq 0 ]; then

                         echo "`date "+%Y-%m-%d %H:%M:%S "` checking for difference in $whitelist and $vhost_conf"  >> $log_file
                         diff $whitelist  $whitelisted_ip |   grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' > $tmp1
    # fi


  if [ ! -s $tmp1 ]; then
                         check_rc "Error while checking difference" "$?" 
                         check_rc "Error while checking difference" "$?" >> $log_file
                         echo " All IPs are already whitelisted. No any new IP found into $whitelist for  Whitelisting"
                         echo "`date "+%Y-%m-%d %H:%M:%S "` All IPs are already whitelisted. No any new IP found into  $whitelist" >> $log_file
  else
                         echo "`date "+%Y-%m-%d %H:%M:%S "` Backing up $vhost_conf" >> $log_file
                         cp -rp "$vhost_conf" "$backup_vhost$vhost_conf_bkp"_`date "+%Y%m%d_%H%M"`




if `validate_url $iURL >/dev/null`; then

        for i in `cat $tmp1`
    do

cmdv="`grep -iw "$i"  $vhost_conf`"
ips=`echo "$?"`
cmdw="`grep -iw    "$i"  $whitelist`"
whs=`echo "$?"`


           if  (test $ips -ne 0); then
                         echo "`date "+%Y-%m-%d %H:%M:%S "` "$i"  not present in $vhost_conf file" >> $log_file
                         sed -i "/$searchprm/ s/$/ $i/" $vhost_conf
                         echo "`date "+%Y-%m-%d %H:%M:%S "` "$i" added into  vhost file" >> $log_file

           else
                         echo "`date "+%Y-%m-%d %H:%M:%S "` "$i" present in vhost file" >> $log_file
                         sed -i  "s/$i//" $vhost_conf
                         echo "`date "+%Y-%m-%d %H:%M:%S "`"$i"removed from vhost  file" >> $log_file
           fi

  done
fi

fi
      
