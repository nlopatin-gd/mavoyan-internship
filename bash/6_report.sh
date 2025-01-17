#!/bin/bash

current_date_and_time=$(date)
username=$USER
internal_ip=$(hostname -I | awk '{print $1}')
hostname=$(hostname)
external_ip_address=$(curl -s https://api.ipify.org)
name_and_version_of_linuxdist=$(uname -rs)
uptime=$(uptime -p)
used_free_space=$(df -h /)
ram_info=$(free -h | grep -E '^Mem:')
total_ram=$(echo "$ram_info" | awk '{print $2}')
free_ram=$(echo "$ram_info" | awk '{print $4}')
cpu_info=$(lscpu | grep -E '^(CPU\(s\):|Model name)')
num_cores=$(echo "$cpu_info" | grep 'CPU(s):' | awk '{print $2}')
freq=$(lscpu | grep "GHz" | awk '{for(i=1;i<=NF;i++) if(tolower($i) ~ /mhz|ghz/) print $i}')


IFS=' ' read -r _ used avail _ <<< "$(echo "$used_free_space" | grep -E '^/dev')"

echo "Current date and time -> $current_date_and_time"
echo "Username -> $username"
echo "Internal IP address and the hostname -> $internal_ip, $hostname"
echo "External IP address -> $external_ip_address"
echo "Name and version of the Linux distribution -> $name_and_version_of_linuxdist"
echo "System uptime -> $uptime"
echo "Information about used and free space in / in GB -> Used: $used Free: $avail"
echo "Information about total and free RAM -> Total: $total_ram Free: $free_ram"
echo "Number and frequency of CPU core $num_cores, $freq"

