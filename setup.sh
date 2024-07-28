#!/bin/bash

set +e
#exec > >(while read line; do echo "$line"; do read "$line"; done) 2>&1

if [ $(id -u) -ne 0 ]
  then echo "Please run $0 as root"
	exit 1
fi

clear

echo -e "\e[31m"
echo ""
echo "  █████████   █████                         █████████                                                       ";
echo " ███░░░░░███ ░░███                         ███░░░░░███                                                      ";
echo "░███    ░░░  ███████    ██████   ████████ ░███    ░░░   ██████  ████████   ██████   ██████   █████████████  ";
echo "░░█████████ ░░░███░    ░░░░░███ ░░███░░███░░█████████  ███░░███░░███░░███ ███░░███ ░░░░░███ ░░███░░███░░███ ";
echo " ░░░░░░░░███  ░███      ███████  ░███ ░░░  ░░░░░░░░███░███ ░░░  ░███ ░░░ ░███████   ███████  ░███ ░███ ░███ ";
echo " ███    ░███  ░███ ███ ███░░███  ░███      ███    ░███░███  ███ ░███     ░███░░░   ███░░███  ░███ ░███ ░███ ";
echo "░░█████████   ░░█████ ░░████████ █████    ░░█████████ ░░██████  █████    ░░██████ ░░████████ █████░███ █████";
echo " ░░░░░░░░░     ░░░░░   ░░░░░░░░ ░░░░░      ░░░░░░░░░   ░░░░░░  ░░░░░      ░░░░░░   ░░░░░░░░ ░░░░░ ░░░ ░░░░░ ";
echo ""
echo -e "\e[0m"

# ========================================================================================================================================================================
# Settings Aliases for User K4l1m3r0
set_user_aliases() {
	echo
	read -p "Setting aliases for user K4l1m3r0. [Press enter to continue]"
	cat <<EOF > /home/k4l1m3r0/.bash_aliases
alias ..='cd ..'
alias cls='clear'
alias df='df -h'
alias edit='nano'
alias fastping='ping -c 100 -s.2'
alias free='free -h'
alias h='history'
alias halt='sudo /sbin/halt'
alias j='jobs -l'
alias ll='ls -lah --color=auto'
alias meminfo='free -m -l -t'
alias mount='mount | column -t'
alias nan='nano'
alias now='date +"%T"'
alias path='echo -e ${PATH//:/\\n}'
alias ping5='ping -c 5'
alias ports='netstat -tulanp'
alias pscpu='ps auxf | sort -nr -k 3'
alias psmem='ps auxf | sort -nr -k 4'
alias reboot='sudo /sbin/reboot'
alias root='sudo -i'
alias shutdown='sudo /sbin/shutdown -h now'
alias su='sudo -i'
alias wanip='curl -w "\n" http://whatismyip.akamai.com/'
alias wget='wget -c'
EOF
	echo "DONE"
}

# ========================================================================================================================================================================
# Settings Aliases for Root
set_root_aliases() {
	echo
  read -p "Setting aliases for user root. [Press enter to continue]"
  cat <<EOF > /root/.bash_aliases
alias ..='cd ..'
alias cls='clear'
alias df='df -h'
alias edit='nano'
alias fastping='ping -c 100 -s.2'
alias free='free -h'
alias h='history'
alias halt='sudo /sbin/halt'
alias j='jobs -l'
alias ll='ls -lah --color=auto'
alias meminfo='free -m -l -t'
alias mount='mount | column -t'
alias nan='nano'
alias now='date +"%T"'
alias path='echo -e ${PATH//:/\\n}'
alias ping5='ping -c 5'
alias ports='netstat -tulanp'
alias pscpu='ps auxf | sort -nr -k 3'
alias psmem='ps auxf | sort -nr -k 4'
alias reboot='sudo /sbin/reboot'
alias root='sudo -i'
alias shutdown='sudo /sbin/shutdown -h now'
alias su='sudo -i'
alias wanip='curl -w "\n" http://whatismyip.akamai.com/'
alias wget='wget -c'
EOF
	echo "DONE"
}

# ========================================================================================================================================================================
# Setting FQDN host name
set_hostname() {
	echo
	read -p "Setting FQDN host name. [Press enter to continue]"
	read -p "Type the host name: " host_name

	hostnamectl set-hostname $host_name.cybertron.local
	echo $host_name.cybertron.local > /etc/hostname

	sed -i '/#domain-name=local/c\domain-name=cybertron.local' /etc/avahi/avahi-daemon.conf
	sed -i '/publish-domain=yes/s/^#//g' /etc/avahi/avahi-daemon.conf
	sed -i '/use-ipv6=yes/s/^/#/g' /etc/avahi/avahi-daemon.conf

	unset host_name
	echo "DONE"
}

# ========================================================================================================================================================================
# Setting the password for the root user account
set_root_password() {
	read -p "Do you want to set a password for root user? (y/N)" -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		read -p "New password: " -s root_password_1
		echo
		read -p "Retype new password: " -s root_password_2
		echo

		if [ $root_password_1 != $root_password_2 ]; then
			echo "Passwords do not match"
			set_root_password
		fi

		echo -e "$root_password_1\n$root_password_1" | passwd root

		if [ $? -eq 0 ]; then
			echo "Password changed successfully"
		else
			echo "Password change error"
			set_root_password
		fi

		unset root_password_1
		unset root_password_2
		echo "DONE"
	fi
}

# ========================================================================================================================================================================
# Setting the current date & time
change_current_datetime() {
	echo
	read -p "Setting the current date and time. [Press enter to continue]"
	date
	read -p "Is the current date and time correct? (y/n): " correct_date

	if [ $correct_date == "n" ] || [ $correct_date == "N" ]; then
		read -p "Enter date and time (YYYY-MM-DD HH:MM:SS): " current_date
		timedatectl set-ntp false
		timedatectl set-time "$current_date"

		if [ $? -eq 0 ]; then
			timedatectl set-ntp true
			date
		else
			change_current_datetime
		fi
	fi

	unset correct_date
	unset current_date
	echo "DONE"
}

# ========================================================================================================================================================================
# System update
system_update() {
	echo
	read -p "Starting system update. [Press enter to continue]"

	UPDATENUM=$(apt-get -q -y --ignore-hold --allow-change-held-packages --allow-unauthenticated -s dist-upgrade | /bin/grep  ^Inst | wc -l)

	echo "Package to update: $UPDATENUM"

	if [[ $UPDATENUM > 0 ]]; then
		apt-get update
		apt-get -y full-upgrade
	fi

	unset UPDATENUM
	echo "DONE"
}

# ========================================================================================================================================================================
# Cleaning up system
system_cleanup() {
	echo
	read -p "Cleaning up system. [Press enter to continue]"

	if systemctl -all list-unit-files systemd-networkd-wait-online.service | grep "systemd-networkd-wait-online.service enabled" ;then
		echo "Disabling systemd-networkd-wait-online.service"
		systemctl disable systemd-networkd-wait-online.service
		systemctl stop systemd-networkd-wait-online.service
	fi

	if systemctl -all list-unit-files triggerhappy.service | grep "triggerhappy.service enabled" ;then
		echo "Disabling triggerhappy.service"
		systemctl disable triggerhappy.service
		systemctl stop triggerhappy.service

		systemctl disable triggerhappy.socket
		systemctl stop triggerhappy.socket
	fi

	if systemctl -all list-unit-files ModemManager | grep "ModemManager enabled" ;then
		echo "Uninstalling ModemManager and old GCC versions"
		apt-get remove --purge -y modemmanager
		apt-get remove --purge -y gcc-7-base gcc-8-base gcc-9-base
	fi

	echo "Removing unused packages"
	apt-get autoremove --purge -y

	echo "DONE"
}

# ========================================================================================================================================================================
# Installing Base Packages
install_base_packages() {
	echo
	read -p "Installing base component. [Press enter to continue]"

	apt-get install -y build-essential git curl xsltproc rsync tmux

	echo "DONE"
}

# ========================================================================================================================================================================
# Installing Network Packages
install_network_packages() {
	echo
	read -p "Installing network packages. [Press enter to continue]"

	apt-get install -y i2c-tools ufw
	sudo apt install -y python3-pip python3-venv python3-smbus
	sudo apt install -y python3-netifaces python3-requests python3-nmap python3-scapy
	sudo apt install -y nmap tcpdump doscan nast ettercap-text-only ncat
	sudo apt install -y arping arpon arp-scan arpwatch
	sudo apt install -y dhcpdump dhcp-probe dhcping dhcpig dns2tcp dhcpstarv
	sudo apt install -y dnsenum dnsmap dnsrecon dnswalk dnsutils dnstracer
	sudo apt install -y backdoor-factory masscan netdiscover macchanger

	echo "DONE"
}

# ========================================================================================================================================================================
# Configuring UFW firewall
configure_firewall() {
	echo
	read -p "Configuring UFW firewall. [Press enter to continue]"

	rfkill unblock wifi

	ufw default deny incoming
	ufw default allow outgoing
	ufw allow ssh
	yes | ufw enable

	echo "DONE"
}

# ========================================================================================================================================================================
# Setting the current date & time
change_system_locale() {
	echo
	read -p "Configuring the System Locale. [Press enter to continue]"

	rm -f /etc/localtime
	echo "Europe/Rome" >/etc/timezone
	dpkg-reconfigure -f noninteractive tzdata
	dpkg-reconfigure -f noninteractive keyboard-configuration

	echo "DONE"
}

# ========================================================================================================================================================================
# Enable USB-C Ethernet
enable_usbc_ethernet() {
	echo ""
	read -p "Configuring USB-C Ethernet. [Press enter to continue]"

	cmdline=$(</boot/firmware/cmdline.txt)
	cmdline="$cmdline modules-load=dwc2,g_ether"
	echo $cmdline > /boot/firmware/cmdline.txt

	echo "dtoverlay=dwc2" >> /boot/firmware/config.txt

	nmcli con add type ethernet con-name usb0
	cat <<EOF > /etc/NetworkManager/system-connections/usb0.nmconnection
[connection]
id=usb0
uuid=<random group of characters here>
type=ethernet
autoconnect=true
interface-name=usb0

[ethernet]

[ipv4]
method=shared

[ipv6]
method=disabled

[proxy]
EOF

 	cat <<EOF > /usr/local/sbin/usb-gadget.sh
#!/bin/bash
nmcli con up usb0
EOF

	chmod a+rx /usr/local/sbin/usb-gadget.sh

	cat <<EOF > /usr/local/sbin/usb-gadget.sh
[Unit]
Description=Ethernet USB gadget
After=NetworkManager.service
Wants=NetworkManager.service
  
[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/local/sbin/usb-gadget.sh
  
[Install]
WantedBy=sysinit.target
EOF

	systemctl enable usbgadget.service
}

# ========================================================================================================================================================================
# Setup Completed
setup_complete() {
	echo
	read -p "StarScream Setup completed. [Press enter to reboot]"
	reboot
}

# ========================================================================================================================================================================
# Script Functions

set_user_aliases
set_root_aliases
set_hostname
set_root_password
change_current_datetime
system_update
system_cleanup
install_base_packages
install_network_packages
configure_firewall
change_system_locale
enable_usbc_ethernet
setup_complete
