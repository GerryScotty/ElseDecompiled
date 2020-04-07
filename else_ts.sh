VER=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
ME=`basename "$0"`
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
ME="$SCRIPTPATH/$ME"
USER=$(whoami)
DORA=$(date +%H-%M-%S)
DDATA=$(date +%m-%d-%y)
printf "[ElseTsInstaller] Controllo sicurezza..."
if ! [ -f "$ME" ]; then
printf "verificato"
else
printf "compromessa"
printf "
Errore: Non sei autorizzato a scaricare questo script
Devi farlo partire con il comando indicato su telegram.me/ElseNetwork
Lo script si AUTODISTRUGGERÀ!
"
rm "$ME"  > /dev/null 2>&1
exit 0
fi
printf "
[ElseTsInstaller] Controllo sistema..."
if [[ "$VER" = "\"Ubuntu\"" ]]; then
printf "ubuntu"
else
printf "$VER"
printf "
Errore: Questo script funziona solo su Ubuntu, questa macchina ha $VER
"
exit 0
fi
printf "
[ElseTsInstaller] Controllo utente..."
if [ "$EUID" = 0 ]; then
printf "root"
else
printf "$USER"
printf "
Errore: Questo script deve essere eseguito dall'utente root, al momento sei con l'utente $USER"
exit 0
fi
printf "
[ElseTsInstaller] Controllo connessione..."
wget -q --tries=10 --timeout=20 --spider http://google.com > /dev/null 2>&1
if [[ $? -eq 0 ]]; then
printf "online"
else
printf "offline"
printf "
Errore: Questo script ha bisogno di internet per funzionare, l'esecuzione verrà interrotta"
exit 0
fi
if [ -f "/etc/elsec/online" ]; then
printf "
[ElseTsInstaller] Rilevato ElseSecurity!"
fi
printf "

[ElseTsInstaller] Installazione di TeamSpeak
"
printf "[ElseTsInstaller] Inserisci la versione di TeamSpeak che vuoi installare tra le seguenti opzioni:
3.10.0
3.10.1
3.10.2
3.11.0
La versione scelta: "
read versione
url="https://files.teamspeak-services.com/releases/server/"$versione"/teamspeak3-server_linux_amd64-"$versione".tar.bz2"
if [[ `wget -S --spider $url  2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then
printf "[ElseTsInstaller] Procedo all'installazione di TeamSpeak server "$versione"
"
else
printf "[ElseTsInstaller] La versione specificata non esiste!
"
exit 0
fi
if [ -d "/servers/teamspeak" ] || [ -f "/lib/systemd/system/teamspeak.service" ];then
printf "[ElseTsInstaller] Attenzione, è stata trovata un'altra Installazione di TeamSpeak, vuoi procedere comunque e sovrascrivere tutto? y/n "
read conferma
if [[ "$conferma" = "y" ]]; then
printf "[ElseTsInstaller] OK procedo!
"
service teamspeak stop > /dev/null 2>&1
rm /lib/systemd/system/teamspeak.service > /dev/null 2>&1
rm -rf /servers/teamspeak > /dev/null 2>&1
userdel -r teamspeak > /dev/null 2>&1
else
printf "[ElseTsInstaller] Operazione annullata!
"
exit 0
fi
fi
trap '' 2
printf "
Aggiorno repository..."
sudo apt-get update -y > /dev/null 2>&1
sudo dpkg --configure -a  > /dev/null 2>&1
printf "fatto"
printf "
Installo programmi necessari..."
sudo apt-get install curl software-properties-common bsdmainutils openssl -y  > /dev/null 2>&1
printf "fatto"
printf "
Correggo errori..."
apt --fix-broken install -y > /dev/null 2>&1
printf "fatto"
printf "
Controllo programmi..."
sudo apt-get install curl software-properties-common bsdmainutils openssl -y > /dev/null 2>&1
printf "fatto"
IPADRESS=$(curl -sL ifconfig.me)
printf "
Scarico e configuro TeamSpeak..."
LC_CTYPE=C tr -d -c '[:alnum:]' </dev/urandom | head -c 8  > /dev/null 2>&1
random=$(LC_CTYPE=C tr -d -c '[:alnum:]' </dev/urandom | head -c 15) > /dev/null 2>&1
mkdir /servers > /dev/null 2>&1
cd /servers > /dev/null 2>&1
wget $url > /dev/null 2>&1
tar xvjf "teamspeak3-server_linux_amd64-"$versione".tar.bz2" > /dev/null 2>&1
rm "teamspeak3-server_linux_amd64-"$versione".tar.bz2" > /dev/null 2>&1
mv teamspeak3-server_linux_amd64 teamspeak > /dev/null 2>&1
useradd -s /usr/sbin/nologin -M teamspeak > /dev/null 2>&1
chown -R teamspeak:teamspeak teamspeak > /dev/null 2>&1
cd teamspeak > /dev/null 2>&1
touch .ts3server_license_accepted > /dev/null 2>&1
printf "fatto"
printf "

[ElseTsInstaller] ATTENDI LA PRIMA ACCENSIONE DI TEAMSPEAK

"
sudo -u teamspeak bash /servers/teamspeak/ts3server_startscript.sh start serveradmin_password=$random
sleep 7
sudo -u teamspeak bash /servers/teamspeak/ts3server_startscript.sh stop > /dev/null 2>&1
echo "[Unit]
Description=TeamSpeak 3 Server
After=network.target
[Service]
WorkingDirectory=/servers/teamspeak/
User=teamspeak
Group=teamspeak
Type=forking
ExecStart=/servers/teamspeak/ts3server_startscript.sh start inifile=ts3server.ini
ExecStop=/servers/teamspeak/ts3server_startscript.sh stop
PIDFile=/servers/teamspeak/ts3server.pid
RestartSec=15
Restart=always
[Install]
WantedBy=multi-user.target" >> /lib/systemd/system/teamspeak.service
systemctl --system daemon-reload > /dev/null 2>&1
systemctl enable teamspeak.service > /dev/null 2>&1
cd / > /dev/null 2>&1
passw="ElseTsInstaller"$DDATA"-"$DORA
filename=".elsetsinstallerpswbkp"$DDATA"-"$DORA
printf -v filetxt "[ElseTsInstaller] -> telegram.me/ElseNetwork
Password serverquery dell'installazione "$DDATA"-"$DORA"
"$random":
"
enc=$(echo "$filetxt" | openssl enc -aes-256-cbc -a -A -pbkdf2 -iter 100000 -nosalt -pass "pass:$passw")
echo "$enc" > /root/"$filename"
echo "$enc" > /servers/teamspeak/"$filename"
versione=${versione:2:1}
if [[ "$versione" -gt "7" ]]; then
token=$(find /servers/teamspeak/logs/ -name '*1.log' -exec sed -n -e 4p {} \; | sed 's/.*token=//')
printf "
------------------------------------------------------------------
                      I M P O R T A N T
------------------------------------------------------------------
               Server Query Admin Account created
         loginname= \"serveradmin\", password= \"$random\"
------------------------------------------------------------------"
printf "


------------------------------------------------------------------
                      I M P O R T A N T
------------------------------------------------------------------
      ServerAdmin privilege key created, please use it to gain
      serveradmin rights for your virtualserver. please
      also check the doc/privilegekey_guide.txt for details.

       token=$token
------------------------------------------------------------------

"
fi
printf "[ElseTsInstaller] Installazione completata!
"
printf "[ElseTsInstaller] Esegui 'service teamspeak start' per avviare TeamSpeak e 'service teamspeak stop' per stopparlo
"
printf "[ElseTsInstaller] SALVATI LE PASSWORD MOSTRTATE SOPRA
"
printf "[ElseTsInstaller] Se non vedi nessuna password contatta https://t.me/ElseChatBot e allega uno screen di questa installazione
"
printf "[ElseTsInstaller] La VPS necessita un riavvio per fare funzionare TeamSpeak
"
printf "[ElseTsInstaller] Al riavvio il TeamSpeak verrà avviato in automatico e sarà accessibile dall'IP $IPADRESS
"
printf "[ElseTsInstaller] PREMI INVIO PER RIAVVIARE LA VPS"
read
printf "[ElseTsInstaller] Ti sei salvato le password? y/n --> "
read yn
if [[ "$yn" = "y" ]]; then
:
else
printf '[ElseTsInstaller] SALVATELE!!!
'
printf "[ElseTsInstaller] PREMI INVIO PER RIAVVIARE LA VPS"
read
fi
printf '[ElseTsInstaller] Riavvio in corso...
'
reboot
trap 2
