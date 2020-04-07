clear
function einfo {
local array=($(df -P))
local MEM=();
local NAME=();
local count=0
local count2=0
local work="false"
local dev="/dev"
local bdev=$(echo -ne "$dev" | base64);
local bdev=$(echo ${bdev//\=/});
for (( i=0; i<${#array[@]}; i++ )); do
if [[ "$i" -gt 6 ]]; then
if [[ "$count" -eq 5 ]]; then
((count2++))
count=0
work="false"
else
VAL=${array[$i]}
BVAL=$(echo -ne "$VAL" | base64);
BVAL=$(echo ${BVAL//\=/});
if [[ "$count" -eq "0" ]]; then
if [[ $BVAL = "L2Rld"* ]]; then
NAME+=("$VAL")
work="true"
fi
elif [[ "$count" -eq "1" ]]; then
if [[ "$work" = "true" ]]; then
MEM+=("$VAL")
work="false"
fi
fi
((count++))
fi
fi
done
local sum=0
for i in "${MEM[@]}"
do
sum=$(($sum + $i))
done
for i in "${NAME[@]}"
do
:
done
local RAMTOT=$(grep MemTotal /proc/meminfo | awk '{print $2}')
local RAMFREE=$(grep MemFree /proc/meminfo | awk '{print $2}')
local RAMOCC=$(expr $RAMTOT - $RAMFREE)
local RAMTOT=$(bc -l <<< "scale=1 ; $RAMTOT / 1024000")
local RAMOCC=$(echo "scale=3; $RAMOCC / 1024000" | bc -l | awk '{printf "%.3f
", $0}')
local RAMFREE=$(echo "scale=3; $RAMFREE / 1024000" | bc -l | awk '{printf "%.3f
", $0}')
local FREQ=$(grep 'cpu MHz' /proc/cpuinfo | head -1 | awk -F: '{print $2}')
local FREQ=$(echo "scale=2; $FREQ / 1024" | bc -l | awk '{printf "%.2f
", $0}')
local DISKTOT=$sum
local DISKOCC=$(df --output=used / | sed -n 2p)
local DISKFREE=$(expr $DISKTOT - $DISKOCC)
local DISKTOT=$(echo "scale=1; $DISKTOT / 1048576" | bc -l)
local DISKOCC=$(echo "scale=3; $DISKOCC / 1048576" | bc -l | awk '{printf "%.3f
", $0}')
local DISKFREE=$(echo "scale=3; $DISKFREE / 1048576" | bc -l | awk '{printf "%.3f
", $0}')
local HOSTNAME=$(hostname)
local IPADRESS=$(curl -sL ifconfig.me)
local CPUUSAGE=$(top -bn 2 -d 0.01 | grep '^%Cpu' | tail -n 1 | gawk '{print $2+$4+$6}')
if ! [ -d "/etc/einfo" ]; then
if [ "$EUID" = 0 ]; then
mkdir /etc/einfo > /dev/null 2>&1
chmod -R 777 /etc/einfo/ > /dev/null 2>&1
fi
fi
local file="/etc/einfo/tempinfo"
rm $file > /dev/null 2>&1
echo -e "SISTEMA                CPU|NEWLINE|" >> $file
echo -e "OS:    $(lsb_release --id | cut -f2)   Core:   $(cat /proc/cpuinfo | awk '/^processor/{print $3}' | wc -l)" >> $file
echo -e "Ver:   $(lsb_release --release | cut -f2)      Thread: $(grep -c processor /proc/cpuinfo)" >> $file
echo -e "Kernel:        $(uname)        Freq:   $FREQ GHz" >> $file
echo -e "Ver:   $(uname --kernel-release)       Model:  $(lscpu | grep 'Model name' | cut -f 2 -d ":" | awk '{$1=$1}1')|NEWLINE||NEWLINE|" >> $file
echo -e "RAM            DISCO|NEWLINE|" >> $file
echo -e "Tot:   $(echo $RAMTOT) GB      Tot:    $(echo $DISKTOT) GB" >> $file
echo -e "Occ:   $(echo $RAMOCC) GB      Occ:    $(echo $DISKOCC) GB" >> $file
echo -e "Lib:   $(echo $RAMFREE) GB     Lib:    $(echo $DISKFREE) GB|NEWLINE|" >> $file
echo -e "Utilizzo CPU:  $CPUUSAGE%|NEWLINE|" >> $file
if [[ "$1" != "-h" ]]; then
echo -e "IND IP:        $IPADRESS" >> $file
fi
echo -e "HOSTNAME:      $HOSTNAME" >> $file
column -ts $'   ' $file | sed 's/|NEWLINE|/
/g' | lolcat
rm $file > /dev/null 2>&1
if [ -f /etc/elseb/lastbackup* ]; then
printf "

" | lolcat
dataunix=$(date +%s)
cnumber=$(wc -l /etc/elseb/lastbackup* | awk '{print $1}')
ultimo=$(sed '1q;d' /etc/elseb/lastbackup* | base64 -d)
prossimo=$(sed '2q;d' /etc/elseb/lastbackup* | base64 -d)
stato=$(sed '3q;d' /etc/elseb/lastbackup* | base64 -d)
modalita=$(sed '4q;d' /etc/elseb/lastbackup* | base64 -d)
cartella=$(sed '5q;d' /etc/elseb/lastbackup* | base64 -d)
peso=$(sed '6q;d' /etc/elseb/lastbackup* | base64 -d)
numero=$(sed '7q;d' /etc/elseb/lastbackup* | base64 -d)
intervallo=$(sed '8q;d' /etc/elseb/lastbackup* | base64 -d)
if [ "$dataunix" -lt "$prossimo" ]; then
echo -e " ElseBackup 2.0 Attivo|NEWLINE|" >> $file
else
echo -e " ElseBackup 2.0 Errore|NEWLINE|" >> $file
fi
echo -e " Ultimo backup:        $(date -d @$ultimo '+%d.%m.%Y %H:%M:%S')" >> $file
if [ "$dataunix" -lt "$prossimo" ]; then
echo -e " Prossimo backup:      $(date -d @$prossimo '+%d.%m.%Y %H:%M:%S')" >> $file
echo -e " Stato:        $stato" >> $file
else
echo -e " Stato:        Errore" >> $file
echo -e " Errore:       programmazione backup non rispettata" >> $file
fi
if [[ "$cnumber" -gt "7" ]]; then
echo -e " Intervallo:   $intervallo" >> $file
fi
echo -e " Impostazione: $modalita" >> $file
echo -e " Cartella:     $cartella" >> $file
echo -e " Peso totale backups:  $(bc -l <<< "scale=1 ; $peso / 1024000") MB" >> $file
echo -e " Numero di backups:    $numero" >> $file
column -ts $'   ' $file | sed 's/|NEWLINE|/
/g' | lolcat
rm $file > /dev/null 2>&1
printf "
"
elif ! [ -f "/etc/elsec/.active" ]; then
printf "
 by t.me/ElseNetwork

" | lolcat
fi
}
einfo
