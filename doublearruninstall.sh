#!/bin/bash

# Script by @ComputerByte 
# For DoubleARR Uninstalls

# Log to Swizzin.log
export log=/root/logs/swizzin.log
touch $log

_sonarr4kuninstall () {
systemctl disable --now -q sonarr4k
rm /etc/systemd/system/sonarr4k.service
systemctl daemon-reload -q

if [[ -f /install/.nginx.lock ]]; then
    rm /etc/nginx/apps/sonarr4k.conf
    systemctl reload nginx
fi

rm /install/.sonarr4k.lock

sed -e "s/class sonarr4k_meta://g" -i /opt/swizzin/core/custom/profiles.py
sed -e "s/  name = \"sonarr4k\"//g" -i /opt/swizzin/core/custom/profiles.py
sed -e "s/  pretty_name = \"Sonarr 4K\"//g" -i /opt/swizzin/core/custom/profiles.py
sed -e "s/  baseurl = \"\/sonarr4k\"//g" -i /opt/swizzin/core/custom/profiles.py
sed -e "s/  systemd = \"sonarr4k\"//g" -i /opt/swizzin/core/custom/profiles.py
sed -e "s/  check_theD = True//g" -i /opt/swizzin/core/custom/profiles.py
sed -e "s/  img = \"sonarr\"//g" -i /opt/swizzin/core/custom/profiles.py
sed -e "s/class sonarr_meta(sonarr_meta)://g" -i /opt/swizzin/core/custom/profiles.py
}

_radarr4kuninstall () {
systemctl disable --now -q radarr4k
rm /etc/systemd/system/radarr4k.service
systemctl daemon-reload -q

if [[ -f /install/.nginx.lock ]]; then
    rm /etc/nginx/apps/radarr4k.conf
    systemctl reload nginx
fi

rm /install/.radarr4k.lock

sed -e "s/class radarr4k_meta://g" -i /opt/swizzin/core/custom/profiles.py
sed -e "s/  name = \"radarr4k\"//g" -i /opt/swizzin/core/custom/profiles.py
sed -e "s/  pretty_name = \"Radarr 4K\"//g" -i /opt/swizzin/core/custom/profiles.py
sed -e "s/  baseurl = \"\/radarr4k\"//g" -i /opt/swizzin/core/custom/profiles.py
sed -e "s/  systemd = \"radarr4k\"//g" -i /opt/swizzin/core/custom/profiles.py
sed -e "s/  check_theD = True//g" -i /opt/swizzin/core/custom/profiles.py
sed -e "s/  img = \"radarr\"//g" -i /opt/swizzin/core/custom/profiles.py
sed -e "s/class radarr_meta(radarr_meta)://g" -i /opt/swizzin/core/custom/profiles.py
}

#Asks if they'd like to uninstall sonarr4k.
if [[ -f /install/.sonarr4k.lock ]]; then
echo -n "Would you like to uninstall sonarr4k?(y/n) "
read -r VAR
if [[ $VAR == 'y' ]];
then
  _sonarr4kuninstall
  if [[ $VAR == 'n' ]];
then
  echo -n We wont touch sonarr4k.
fi
fi
fi

#Asks if they'd like to uninstall radarr4k.
if [[ -f /install/.radarr4k.lock ]]; then
echo -n "Would you like to uninstall radarr4k?(y/n) "
read -r VAR
if [[ $VAR == 'y' ]];
then
  _radarr4kuninstall
  if [[ $VAR == 'n' ]];
then
  echo -n We wont touch radarr4k.
fi
fi
fi
