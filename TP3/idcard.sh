nom_machine=$(hostname)
os_nom=$(cat /etc/os-release | head -1 | cut -d '"' -f2)
os_nom2=$(cat /etc/os-release | cut -d '"' -f2 | head -2 | tail -1)
version_noyaux=$(cat /proc/version | cut -d " " -f3)
ip=$(hostname -I | cut -d " " -f2)
ram_dispo=$(free -mh | grep Mem | cut -d " " -f46)
ram_total=$(free -mh | grep Mem | cut -d " " -f11)
disk_dispo=$(df -h | grep /dev/sda5 | cut -d " " -f12)
process1=$(ps -o %mem,command ax | sort -r -b | head -2 | tail -1)
process2=$(ps -o %mem,command ax | sort -r -b | head -3 | tail -1)
process3=$(ps -o %mem,command ax | sort -r -b | head -4 | tail -1)
process4=$(ps -o %mem,command ax | sort -r -b | head -5 | tail -1)
process5=$(ps -o %mem,command ax | sort -r -b | head -6 | tail -1)
listen_port1=$(sudo ss -tulnp | grep LISTEN | cut -c52-58,74,80-149| head -1)
listen_port2=$(sudo ss -tulnp | grep LISTEN | cut -c52-58,74,80-149| head -2 | tail -1)
listen_port3=$(sudo ss -tulnp | grep LISTEN | cut -c52-58,74,80-149| head -3 | tail -1)
listen_port4=$(sudo ss -tulnp | grep LISTEN | cut -c52-58,74,80-149| head -4 | tail -1)
listen_port5=$(sudo ss -tulnp | grep LISTEN | cut -c52-58,74,80-149| head -5 | tail -1)
image_chat=$(curl https://api.thecatapi.com/v1/images/search | cut -d '"' -f10)

echo "Machine name : $nom_machine"
echo "OS $os_nom $os_nom2 and kernel version is $version_noyaux"
echo "IP : $ip"
echo "RAM : $ram_dispo RAM restant sur $ram_total RAM totale"
echo "Disque : $disk_dispo space left"
echo "Top 5 processes by RAM usage : "
echo "  - $process1"
echo "  - $process2"
echo "  - $process3"
echo "  - $process4"
echo "  - $process5"
echo "Listening ports : "
echo "  - $listen_port1"
echo "  - $listen_port2"
echo "  - $listen_port3"
echo "  - $listen_port4"
echo "  - $listen_port5"
echo "Here's your random cat : $image_chat"
