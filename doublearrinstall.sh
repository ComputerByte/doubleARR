#!/bin/bash
. /etc/swizzin/sources/globals.sh
. /etc/swizzin/sources/functions/utils
# Script by @ComputerByte
# For Double *Arr Installs

# Log to Swizzin.log
export log=/root/logs/swizzin.log
touch $log
# Set variables
user=$(_get_master_username)

_sonarr4kinstall () {
echo_progress_start "Making data directory and owning it to ${user}"
mkdir -p "/home/$user/.config/sonarr4k"
chown -R "$user":"$user" /home/$user/.config
echo_progress_done "Data Directory created and owned."

echo_progress_start "Installing systemd service file"
cat > /etc/systemd/system/sonarr4k.service <<- SERV
# This file is owned by the sonarr package, DO NOT MODIFY MANUALLY
# Instead use 'dpkg-reconfigure -plow sonarr' to modify User/Group/UMask/-data
# Or use systemd built-in override functionality using 'systemctl edit sonarr'
[Unit]
Description=Sonarr Daemon
After=network.target
[Service]
User=${user}
Group=${user}
UMask=0002
Type=simple
ExecStart=/usr/bin/mono --debug /opt/Sonarr/Sonarr.exe -nobrowser -data=/home/${user}/.config/sonarr4k
TimeoutStopSec=20
KillMode=process
Restart=on-failure
[Install]
WantedBy=multi-user.target
SERV
echo_progress_done "Sonarr 4K service installed"

# This checks if nginx is installed, if it is, then it will install nginx config for sonarr4k
if [[ -f /install/.nginx.lock ]]; then
  echo_progress_start "Installing nginx config"
  cat > /etc/nginx/apps/sonarr4k.conf <<- NGX
  location /sonarr4k {
      proxy_pass        http://127.0.0.1:8882/sonarr4k;
      proxy_set_header Host \$proxy_host;
      proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto \$scheme;
      proxy_redirect off;
      auth_basic "What's the password?";
      auth_basic_user_file /etc/htpasswd.d/htpasswd.${user};
      proxy_http_version 1.1;
      proxy_set_header Upgrade \$http_upgrade;
      proxy_set_header Connection \$http_connection;
  }
NGX
# Reload nginx
systemctl reload nginx
echo_progress_done "Nginx config applied"
fi

echo_progress_start "Generating configuration"
# Start sonarr to config
systemctl stop sonarr.service >> $log 2>&1
systemctl enable --now sonarr4k.service >> $log 2>&1
sleep 20
# Stop to change port and append baseurl
systemctl stop sonarr4k.service  >> $log 2>&1
sleep 20
systemctl start sonarr.service >> $log 2>&1
sed -i "s/8989/8882/g" /home/$user/.config/sonarr4k/config.xml  >> $log 2>&1
sed -i "s/<UrlBase><\/UrlBase>/<UrlBase>\/sonarr4k<\/UrlBase>/g" /home/$user/.config/sonarr4k/config.xml  >> $log 2>&1
echo_progress_done "Done generating config."
sleep 20

echo_progress_start "Patching panel."
systemctl start sonarr4k.service  >> $log 2>&1
#Install Swizzin Panel Profiles
if [[ -f /install/.panel.lock ]]; then
  cat << EOF >> /opt/swizzin/core/custom/profiles.py
class sonarr4k_meta:
  name = "sonarr4k"
  pretty_name = "Sonarr 4K"
  baseurl = "/sonarr4k"
  systemd = "sonarr4k"
  check_theD = True
  img = "sonarr"
class sonarr_meta(sonarr_meta):
  check_theD = True
EOF
fi
touch /install/.sonarr4k.lock   >> $log 2>&1
echo_progress_done "Panel patched."
systemctl restart panel   >> $log 2>&1
echo_progress_done "Done."
}

_radarr4kinstall () {
echo_progress_start "Making data directory and owning it to ${user}"
mkdir -p "/home/$user/.config/radarr4k"
chown -R "$user":"$user" /home/$user/.config
echo_progress_done "Data Directory created and owned."

echo_progress_start "Installing systemd service file"
cat > /etc/systemd/system/radarr4k.service <<- SERV
[Unit]
Description=Radarr 4K
After=syslog.target network.target

[Service]
# Change the user and group variables here.
User=${user}
Group=${user}

Type=simple

# Change the path to Radarr or mono here if it is in a different location for you.
ExecStart=/opt/Radarr/Radarr -nobrowser --data=/home/${user}/.config/radarr4k
TimeoutStopSec=20
KillMode=process
Restart=on-failure

# These lines optionally isolate (sandbox) Radarr from the rest of the system.
# Make sure to add any paths it might use to the list below (space-separated).
#ReadWritePaths=/opt/Radarr /path/to/movies/folder
#ProtectSystem=strict
#PrivateDevices=true
#ProtectHome=true

[Install]
WantedBy=multi-user.target
SERV
echo_progress_done "Radarr 4K service installed"

# This checks if nginx is installed, if it is, then it will install nginx config for radarr4k
if [[ -f /install/.nginx.lock ]]; then
  echo_progress_start "Installing nginx config"
  cat > /etc/nginx/apps/radarr4k.conf <<- NGX
location /radarr4k {
  proxy_pass        http://127.0.0.1:9000/radarr4k;
  proxy_set_header Host \$proxy_host;
  proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
  proxy_set_header X-Forwarded-Proto \$scheme;
  proxy_redirect off;
  auth_basic "What's the password?";
  auth_basic_user_file /etc/htpasswd.d/htpasswd.${user};

  proxy_http_version 1.1;
  proxy_set_header Upgrade \$http_upgrade;
  proxy_set_header Connection \$http_connection;
}
NGX
# Reload nginx
systemctl reload nginx
echo_progress_done "Nginx config applied"
fi

echo_progress_start "Generating configuration"
# Start radarr to config
systemctl stop radarr.service >> $log 2>&1
systemctl enable --now radarr4k.service >> $log 2>&1
sleep 20
# Stop to change port and append baseurl
systemctl stop radarr4k.service  >> $log 2>&1
sleep 20
systemctl start radarr.service >> $log 2>&1
sed -i "s/7878/9000/g" /home/$user/.config/radarr4k/config.xml  >> $log 2>&1
sed -i "s/<UrlBase><\/UrlBase>/<UrlBase>\/radarr4k<\/UrlBase>/g" /home/$user/.config/radarr4k/config.xml  >> $log 2>&1
echo_progress_done "Done generating config."
sleep 20

echo_progress_start "Patching panel."
systemctl start radarr4k.service  >> $log 2>&1
#Install Swizzin Panel Profiles
if [[ -f /install/.panel.lock ]]; then
  cat << EOF >> /opt/swizzin/core/custom/profiles.py
class radarr4k_meta:
  name = "radarr4k"
  pretty_name = "Radarr 4K"
  baseurl = "/radarr4k"
  systemd = "radarr4k"
  check_theD = True
  img = "radarr"
class radarr_meta(radarr_meta):
  check_theD = True
EOF
fi
touch /install/.radarr4k.lock   >> $log 2>&1
echo_progress_done "Panel patched."
systemctl restart panel   >> $log 2>&1
echo_progress_done "Done."
}

#Asks if they'd like to install sonarr.
if [[ ! -f /install/.sonarrv3.lock ]]; then
echo -n "We see you dont have sonarr installed, would you like to install?(y/n) "
read -r VAR
if [[ $VAR == 'y' ]];
then
  box install sonarr
  if [[ $VAR == 'n' ]];
then
  echo -n We wont install sonarr.
fi
fi
fi
#After confirming sonarr1, asks if theyd like another instance.
if [[ -f /install/.sonarrv3.lock ]]; then
echo -n "Would you like to install another instance of sonarr?(y/n) "
read -r VAR
if [[ $VAR == 'y' ]];
then
  _sonarr4kinstall
fi
fi

#Asks if they'd like to install radarr.
if [[ ! -f /install/.radarr.lock ]]; then
echo -n "We see you dont have radarr installed, would you like to install?(y/n) "
read -r VAR
if [[ $VAR == 'y' ]];
then
  box install radarr
  if [[ $VAR == 'n' ]];
then
  echo -n We wont install radarr.
fi
fi
fi
#After confirming radarr1, asks if theyd like another instance.
if [[ -f /install/.radarr.lock ]]; then
echo -n "Would you like to install another instance of radarr?(y/n) "
read -r VAR
if [[ $VAR == 'y' ]];
then
  _radarr4kinstall
fi
fi
