# Troubleshooting Script

This script helps troubleshoot network connectivity and VPN connections on a user's VM.

## Usage

```sh
git clone https://github.com/DiabloHTB/Troubleshooting
cd Troubleshooting
```

Run the script without any arguments to perform the standard set of tests:
```sh
sudo ./check.sh 
```


Run the script with a target IP to also ping your target along with the default tests:
```sh
sudo ./check.sh 10.10.10.11
```

This will save the logs to `output.log` in the same working directory.

## Functions

The script performs the following checks:
- User Check: Ensures the script is run as root.
- Date: Displays the current date and time.
- Virtual Machine Check: Detects if the machine is running on VMware or VirtualBox.
- Network Interfaces: Lists all network interfaces.
- Network Routes: Displays the network routing table.
- DNS Information: Shows the DNS resolver configuration.
- Ping Test (External): Pings Google's public DNS server (8.8.8.8) and www.google.com to check internet connectivity.
- VPN Connection Check: Checks if the user is connected to a VPN using OpenVPN and displays the filename of the connected VPN configuration.
- Kernel Version: Displays the kernel version.
- Operating System: Shows the operating system information.
- Ping Specific IP: Pings a specified IP address if provided as an argument.
