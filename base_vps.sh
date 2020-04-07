VER=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
ME=`basename "$0"`
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
ME="$SCRIPTPATH/$ME"
USER=$(whoami)
printf "[ElseBaseInstaller] Controllo sicurezza..."
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
[ElseBaseInstaller] Controllo sistema..."
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
[ElseBaseInstaller] Controllo utente..."
if [ "$EUID" = 0 ]; then
printf "root"
else
printf "$USER"
printf "
Errore: Questo script deve essere eseguito dall'utente root, al momento sei con l'utente $USER"
exit 0
fi
printf "
[ElseBaseInstaller] Controllo connessione..."
wget -q --tries=10 --timeout=20 --spider http://google.com > /dev/null 2>&1
if [[ $? -eq 0 ]]; then
printf "online"
else
printf "offline"
printf "
Errore: Questo script ha bisogno di internet per funzionare, l'esecuzione verrà interrotta"
exit 0
fi
printf "

Inizializzazione completata

Potrebbero volerci fino a 30 minuti!
Non interrompere per nessun motivo l'installazione!

"
for i in {5..0}
do
"cho -ne " Il processo partirà in $i secondi
sleep 1
done
printf "
ElseBaseInstaller partito
"
cd /
touch /root/.hushlogin
sudo update-locale LANG=en_US.UTF8 > /dev/null 2>&1
rm /etc/motd > /dev/null 2>&1
rm /etc/profile.d/ainfo.sh > /dev/null 2>&1
if ! [[ -f "/etc/update-motd.d/.alreadydel" ]]; then
rm -rf /etc/update-motd.d/* > /dev/null 2>&1
fi
printf "
Aggiorno repository..."
sudo apt-get update -y > /dev/null 2>&1
sudo dpkg --configure -a  > /dev/null 2>&1
printf "fatto"
printf "
Correggo errori..."
apt --fix-broken install -y > /dev/null 2>&1
printf "fatto"
printf "
Installo programmi..."
sudo add-apt-repository ppa:certbot/certbot -y > /dev/null 2>&1
sudo apt-get install build-essential dnsutils bsdmainutils ntp ntpdate p7zip-full software-properties-common lolcat gawk whois curl php php-mysql php-curl screen bc openjdk-8-jdk rsync -y  > /dev/null 2>&1
printf "fatto"
printf "
Imposto data italiana..."
sudo ntpdate ntp.ubuntu.com > /dev/null 2>&1
sudo ln -fs /usr/share/zoneinfo/Europe/Rome /etc/localtime > /dev/null 2>&1
sudo dpkg-reconfigure --frontend noninteractive tzdata > /dev/null 2>&1
printf "fatto"
printf "
Imposto motd di base..."
wget else00.com/ei/ainfo > /dev/null 2>&1
mv ainfo /etc/profile.d/ainfo.sh > /dev/null 2>&1
chmod +x /etc/profile.d/ainfo.sh > /dev/null 2>&1
if ! [ -d "/etc/einfo" ]; then
mkdir /etc/einfo > /dev/null 2>&1
fi
chmod -R 777 /etc/einfo/
printf "fatto"
history -c
printf "

ElseBaseInstaller completo!
"
