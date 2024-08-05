#!/bin/bash

# Colors for output
LIGHT_GREEN='\033[1;32m'
GREEN='\033[0;32m'
SILVER='\033[0;37m'
RED='\033[0;31m'
BOLD='\033[1m'
RESET='\033[0m'
ORANGE='\033[38;5;208m'

LOGFILE="output.log"

# Function to log and echo messages
log() {
  echo -e "$1" | tee -a "$LOGFILE"
}

PING_EXTERNAL="failure"  # Default value, change to "success" if ping test succeeds
ConnectVPN="failure"  # Default value, set to filename if VPN file is detected
tun_count=0  # Default value, set to actual number of tun0 interfaces


usage() {
  echo -e "${LIGHT_GREEN}Usage:${RESET}"
  echo -e "  ./check.sh                Run all tests"
  echo -e "  ./check.sh <IP>           Run all tests and ping the specified IP address"
  echo -e ""
  echo -e "${LIGHT_GREEN}Tests performed:${RESET}"
  echo -e "  - Check user ID and ensure script is run as root"
  echo -e "  - Check for virtual machine environment (VMware or VirtualBox)"
  echo -e "  - List network interfaces"
  echo -e "  - Display network routes"
  echo -e "  - Perform ping tests to external addresses (Google DNS and Google website)"
  echo -e "  - Check for active OpenVPN connections and display configuration file"
  echo -e "  - Display kernel version and check for PAE kernel"
  echo -e "  - Show OS version information"
  echo -e "  - Check the Number of tun0 interfaces"
  echo -e "  - Check the System uptime"
  echo -e "  - Check for Firewall rules"
  echo -e "  - Check for Disk usage"
  echo -e "  - Check for CPU and Memory usage"
  echo -e "  - Optional: Ping the specified IP address if provided"
  echo -e ""
  echo -e "${LIGHT_GREEN}Options:${RESET}"
  echo -e "  -h, --help  Display this help message"
  exit 0
}

if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
  usage
fi


display_banner() {
  echo -e "${GREEN}"
  echo -e "██╗  ██╗ █████╗  ██████╗██╗  ██╗    ████████╗██╗  ██╗███████╗    ██████╗  ██████╗ ██╗  ██╗"
  echo -e "██║  ██║██╔══██╗██╔════╝██║ ██╔╝    ╚══██╔══╝██║  ██║██╔════╝    ██╔══██╗██╔═══██╗╚██╗██╔╝"
  echo -e "███████║███████║██║     █████╔╝        ██║   ███████║█████╗      ██████╔╝██║   ██║ ╚███╔╝ "
  echo -e "██╔══██║██╔══██║██║     ██╔═██╗        ██║   ██╔══██║██╔══╝      ██╔══██╗██║   ██║ ██╔██╗ "
  echo -e "██║  ██║██║  ██║╚██████╗██║  ██╗       ██║   ██║  ██║███████╗    ██████╔╝╚██████╔╝██╔╝ ██╗"
  echo -e "╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝       ╚═╝   ╚═╝  ╚═╝╚══════╝    ╚═════╝  ╚═════╝ ╚═╝  ╚═╝"
  echo -e "------------------------------------------------------------------Made by Diablo with love"
  echo -e "${RESET}"
}

display_banner

echo -e "${RED}PREPARING TO HACK YOUR MACHINE, IT WILL BE FAST DON'T WORRY.${RESET}"
sleep 3s




# Checking User
log "\n\n${LIGHT_GREEN}➔ Are you ROOT${RESET}"
if [[ "${EUID}" -ne 0 ]]; then
  log "${RED}❌ This script must be run as root${RESET}"
  sleep 2s
  exit 1
fi
id | tee -a "$LOGFILE"
sleep 3s



# Date
log "\n\n${LIGHT_GREEN}-----Date-----${RESET}"
date | tee -a "$LOGFILE"
sleep 3s

# Virtual Machine Check
log "\n\n${LIGHT_GREEN}➔ Virtual Machine Check${RESET}"
if (dmidecode | grep -iq vmware); then
  log "VMware Detected"
elif (dmidecode | grep -iq virtualbox); then
  log "VirtualBox Detected"
  sleep 2s
else
  log "${RED}❌ VM not detected${RESET}!"
  sleep 2s
fi
sleep 3s

# Network Interfaces
log "\n\n${LIGHT_GREEN}➔ Network Interfaces${RESET}"
ifconfig -a | tee -a "$LOGFILE"
sleep 3s

# Checking tun0 Interfaces
log "\n\n${LIGHT_GREEN}➔ Checking tun0 Interfaces${RESET}"
tun_count=$(ifconfig -a | grep -c "tun")
log "Number of tun0 interfaces: $tun_count"

# Network Routes
log "\n\n${LIGHT_GREEN}➔ Network Routes${RESET}"
route -n | tee -a "$LOGFILE"
sleep 3s



# Ping Test (External: www.Google.com)
log "\n\n${LIGHT_GREEN}➔ Ping Test (External: www.Google.com)${RESET}"
ping -c 4 8.8.8.8 | tee -a "$LOGFILE"
if [[ $? != 0 ]]; then
  log "${RED}❌ Ping test failed (8.8.8.8). Please make sure you have Internet access.${RESET}"
  sleep 2s
fi
echo -e "" | tee -a "$LOGFILE"
ping -c 4 www.google.com | tee -a "$LOGFILE"
PING_EXTERNAL="success"
if [[ $? != 0 ]]; then
  log "${RED}❌ Ping test failed (www.google.com). Please make sure you have Internet access.${RESET}"
  sleep 2s
fi
sleep 3s

# Checking VPN Connection
log "\n\n${LIGHT_GREEN}➔ Checking VPN Connection${RESET}"
vpn_process=$(pgrep -a openvpn)
if [[ -z "$vpn_process" ]]; then
  log "${RED}❌ No active OpenVPN connection found${RESET}"
else
  log "${GREEN}✔️ Active OpenVPN connection found${RESET}"
  vpn_pid=$(echo "$vpn_process" | awk '{print $1}')
  vpn_working_dir=$(pwdx "$vpn_pid" | awk '{print $2}')
  ConnectVPN="success"
   

  vpn_config="${vpn_working_dir}/$(echo "$vpn_process" | cut -d ' ' -f 3- | sed 's/^[ \t]*//')"
  log "${GREEN}✔️ VPN Configuration File: $vpn_config${RESET}"
   remote_server=$(grep -i "^remote" "$vpn_config" | awk '{print $2}')
  protocol=$(grep -i "^proto" "$vpn_config" | awk '{print $2}')

  if [[ -n "$remote_server" && -n "$protocol" ]]; then
    log "${GREEN}[+] Remote Server: $remote_server${RESET}"
    log "${GREEN}[+] Protocol: $protocol${RESET}"
  else
    log "${RED}[-] Could not extract remote server or protocol${RESET}"
  fi

fi
sleep 3s

# Checking Kernel Version
log "\n\n${LIGHT_GREEN}➔ Checking Kernel Version${RESET}"
uname -a | tee -a "$LOGFILE"
sleep 3s

# Checking OS
log "\n\n${LIGHT_GREEN}➔ Checking OS${RESET}"
cat /etc/issue | tee -a "$LOGFILE"
cat /etc/*-release | tee -a "$LOGFILE"
sleep 3s

# Hostname
log "\n\n${LIGHT_GREEN}➔ Hostname${RESET}"
hostname | tee -a "$LOGFILE"
sleep 2s

# System Uptime
log "\n\n${LIGHT_GREEN}➔ System Uptime${RESET}"
uptime | tee -a "$LOGFILE"
sleep 2s

# CPU and Memory Usage
log "\n\n${LIGHT_GREEN}➔ CPU and Memory Usage${RESET}"
top -bn1 | grep "Cpu(s)" | tee -a "$LOGFILE"
free -m | tee -a "$LOGFILE"
sleep 2s

# Firewall Rules
log "\n\n${LIGHT_GREEN}➔ Firewall Rules${RESET}"
iptables -L -n | tee -a "$LOGFILE"
sleep 2s


# Disk Usage
log "\n\n${LIGHT_GREEN}➔ Disk Usage${RESET}"
df -h | tee -a "$LOGFILE"
sleep 2s

# User's Home Directory
log "\n\n${LIGHT_GREEN}➔ User's Home Directory${RESET}"
echo $HOME | tee -a "$LOGFILE"
sleep 2s


ping_target() {
  local target_ip=$1
  log "\n\n${LIGHT_GREEN}[i] Ping Test (Target: $target_ip)${RESET}"
  ping -c 4 "$target_ip" | tee -a "$LOGFILE"
  if [[ $? != 0 ]]; then
    log "${RED}[-] Ping test failed ($target_ip). Please check the network connectivity.${RESET}"
  fi
  sleep 3s
}

if [[ $# -eq 1 ]]; then
  ping_target "$1"
fi



# Internet Access
if [[ $PING_EXTERNAL == "success" ]]; then
  echo -e "${LIGHT_GREEN}Internet Access${RESET}: ${LIGHT_GREEN} Connected to the Internet ✔️${RESET}"
else
  echo -e "${LIGHT_GREEN}Internet Access${RESET}: ${RED}✘ Not Connected ✘${RESET}"
fi

# VPN Connection
if [[ $ConnectVPN == "success" ]]; then
  echo -e "${LIGHT_GREEN}VPN Connection${RESET}: ${LIGHT_GREEN} Connected to VPN ✔️${RESET}"
else
  echo -e "${LIGHT_GREEN}VPN Connection${RESET}: ${RED}✘ Not Connected to VPN ✘${RESET}"
fi

# tun0 Interface
if [[ $tun_count -eq 1 ]]; then
  echo -e "${LIGHT_GREEN}Tun Interfaces${RESET}: ${LIGHT_GREEN} One Tun0 interface detected ✔️${RESET}"
else
  echo -e "${LIGHT_GREEN}Tun Interfaces${RESET}: ${RED}✘ Number of Tun interfaces: ${tun_count}${RESET}"
fi

# Notice
log "\n\n${ORANGE}✔️ Troubleshooting completed, please check the 'output.log' file created and send it to HTB support ✔️${RESET}"
sleep 3s

