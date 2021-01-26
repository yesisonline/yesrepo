#!/bin/bash
########################################################################################
#  Description: To Search and ADD/Remove Ip from File downloaded using URL and compare #                                                                
#  with vhost file.                                                                    #
# Created By : Sameer Deshmukh                                                         #
# Date : 26/01/2021                                                                    #
########################################################################################

########### Variables ##
setup="/opt/whitelist/script/"
bkp_vhost_config="/opt/whitelist/script/vhost_backup/"
vhost_config="/etc/apache2/mods-available/"
log_file="/var/log/whitelist.log"
whitelist="whitelistip.csv"
vhost_file="website.com"
searchprm="Require ip"
whitelisted_ip="whitelisted_ip.lst"
tmp1="tmp1.log"
iURL="https://raw.githubusercontent.com/yesisonline/yesrepo/master/whitelistip.csv"
capt_log_tym=`date "+%Y-%m-%d %H:%M:%S "`
######## Funtions ##
function check_rc {
  if [ "$2" != "0" ];then
                         echo "$capt_log_tym $1" | tee -a $log_file
    #echo "$1" | mail -s "Error: Whitelistscript" root@localhost
  else
                         echo "$capt_log_tym $1" | tee -a $log_file
    #echo "$1" | mail -s "Whitelistscript" root@localhost
  fi

}
function validate_url(){
  if [[ `wget -S --spider $1  2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then
 # wget -q $iURL -P $setup/$whitelist
  echo "true"
  fi
}

################## Prerequisites ##


#Check if required files exisits
if [ ! -d $setup ];      then
                         echo "$capt_log_tym Creating $setup  on $HOSTNAME" >> $log_file
                         mkdir -p $setup

fi
if [ ! -d $vhost_config ] ; then
                        echo "$capt_log_tym Creating $vhost_config  on $HOSTNAME" >> $log_file
                        mkdir -p  $vhost_config
fi

if [ ! -d $bkp_vhost_config ]; then
                        echo "$capt_log_tym Creating $bkp_vhost_config on $HOSTNAME" >> $log_file
                        mkdir -p  $bkp_vhost_config
fi
f [ ! -f $vhost_config$vhost_file ]; then
                         check_rc "$vhost_config$vhost_conf doesent exists." "3"
                         echo "Require ip  82.37.18.53" >> $vhost_config$vhost_file
fi

if [ ! -f $log_file ];   then
                         echo "$capt_log_tym Creating log file at $log_file" >> $log_file
                         touch $log_file
fi

if [ ! -f $setup$whitelisted_ip ]; then
                                 echo "$capt_log_tym Creating whitelisted IP list at $setup$whitelisted_ip" >> $log_file
                         touch $setup$whitelisted_ip
fi


#################### Main ################################################

 # List currently whitelisted IP

                         echo "$capt_log_tym checking $searchprm into  $vhost_config$vhost_file" >> $log_file
                         grep "${searchprm}" $vhost_config$vhost_file | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' > $setup$whitelisted_ip

  # Check if difference whitelisted_ip and whitelist.conf
                         echo "$capt_log_tym Downloading the $iURL" >> $log_file
                        # curl -sS  https://raw.githubusercontent.com/yesisonline/yesrepo/master/whitelistip.csv > $setup$whitelist
                         echo "$capt_log_tym checking for difference in $setup$whitelist and $vhost_config$vhost_file"  >> $log_file
			 #touch $setup$tmp1
                         diff $setup$whitelist  $setup$whitelisted_ip |   grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' > $setup$tmp1



     if [ ! -s $setup$tmp1 ]; then
                         echo "Error while checking difference as $(du -csh $setup$tmp1 |grep -i "tmp1.log" | awk '{print $2 ,"size is", $1}').Input files to diff command is null"
                         echo "Error while checking difference as $(du -csh $setup$tmp1 |grep -i "tmp1.log" | awk '{print $2 ,"size is", $1}').Input files to diff command is null" >> $log_file
                        echo "Status : All Ip's in $setup$whitelist are  already whitelisted in $vhost_config$vhost_file . No new IP found."
                        echo "$capt_log_tym All IPs are already whitelisted. No any new IP found into $setup$whitelist" >> $log_file
			#rm -rf  $setup$whitelist
     else
                        echo "$capt_log_tym Backing up $vhost_config$vhost_file" >> $log_file
                        cp -rp "$vhost_config$vhost_file" "$bkp_vhost_config$vhost_file"_bkp`date "+%Y%m%d_%H%M"`

     if `validate_url $iURL >/dev/null`; then

        for i in `cat $setup$tmp1`
     do

ips="`grep -iw "$i" $vhost_config$vhost_file`"
ips=`echo "$?"`

           if  (test $ips -ne 0); then
                         echo "$capt_log_tym "$i" not present in $vhost_config$vhost_file file" >> $log_file
                         sed -i "/$searchprm/ s/$/ $i/" $vhost_config$vhost_file
                         echo "$capt_log_tym "$i" added into  $vhost_config$vhost_file file" >> $log_file
                         echo "$capt_log_tym "$i" added into  $vhost_config$vhost_file file"

           else
                         echo "$capt_log_tym "$i"  present in $vhost_config$vhost_file file" >> $log_file
                         sed -i  "s/$i//" $vhost_config$vhost_file
                         echo "$capt_log_tym "$i" removed from $vhost_config$vhost_file  file" >> $log_file
                         echo "$capt_log_tym "$i" removed  from  $vhost_config$vhost_file file"

           fi

  done


fi

     fi
  

