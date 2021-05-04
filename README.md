# Radarr + Sonarr Install and Second Instance
### For Swizzin installs
Radarr/Sonarr Installation on Swizzin based systems

Can install a primary sonarr/radarr and a secondary instance of it as well.

Run install.sh as sudo
```bash
sudo su -
wget "https://raw.githubusercontent.com/ComputerByte/doubleARR/main/doublearrinstall.sh"
chmod +x ~/doublearrinstall.sh
~/doublearrinstall.sh
```
Sometimes **Arr* won't start due to another one existing, use the panel to stop Sonarr/Radarr and Sonarr4k/Radarr4k, enable base and wait a second before starting *Arr4k or

```bash
sudo systemctl stop radarr && sudo systemctl stop radarr4k
sudo systemctl start radarr
sudo systemctl start radarr4k
or
sudo systemctl stop sonarr && sudo systemctl stop sonarr4k
sudo systemctl start sonarr
sudo systemctl start sonarr4k
```

The log file should be located at ``/root/log/swizzin.log``.

# Uninstaller: 

```bash
sudo su -
wget "https://raw.githubusercontent.com/ComputerByte/doubleARR/main/doublearruninstall.sh"
chmod +x ~/doublearruninstall.sh
~/doublearruninstall.sh
## if you want to remove base sonarr/radarr
box remove sonarr
box remove radarr
```
