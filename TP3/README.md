# TP 3 : A little script

- TP 3 : A little script
- Intro
- I. Script carte d'identité
- II. Script youtube-dl
- III. MAKE IT A SERVICE

# Intro

Aujourd'hui un TP pour apprendre un peu **le scripting**.

Le scripting dans GNU/Linux, c'est simplement le fait d'écrire dans un fichier une suite de commande, qui seront exécutées les unes à la suite des autres lorsque l'on exécutera le script.

Plus précisément, on utilisera la syntaxe du shell `bash`. Et on a le droit à l'algo (des conditions `if`, des boucles `while`, etc).

# I. Script carte d'identité

## Rendu

📁 **Fichier `/srv/idcard/idcard.sh`**

🌞 Vous fournirez dans le compte-rendu, en plus du fichier, **un exemple d'exécution avec une sortie**, dans des balises de code.
```bash
thomas@thomas-VirtualBox:~$ sh /srv/idcard/idcard.sh
Machine name : thomas-VirtualBox
OS Ubuntu 20.04.3 LTS (Focal Fossa) and kernel version is 5.11.0-38-generic
IP : 192.168.218.18
RAM : 1,4Gi RAM restant sur 1,9Gi RAM totale
Disque : 2,2G space left
Top 5 processes by RAM usage :
  -  4.6 /usr/sbin/lightdm-gtk-greeter
  -  2.8 /usr/lib/xorg/Xorg -core :0 -seat seat0 -auth /var/run/lightdm/root/:0 -nolisten tcp vt7 -novtswitch
  -  1.1 /usr/bin/python3 /usr/share/unattended-upgrades/unattended-upgrade-shutdown --wait-for-signal
  -  1.0 /usr/sbin/NetworkManager --no-daemon
  -  0.9 /usr/bin/python3 /usr/bin/networkd-dispatcher --run-startup-triggers
Listening ports :
  - 53     :  users:(("systemd-resolve",pid=401,fd=13))
  - 22     :  users:(("sshd",pid=543,fd=3))
  - 631    :  users:(("cupsd",pid=439,fd=7))
  - 22     :  users:(("sshd",pid=543,fd=4))
  - 631    :  users:(("cupsd",pid=439,fd=6))
Here's your random cat : https://cdn2.thecatapi.com/images/d37.jpg
```

# II. Script youtube-dl

**Un petit script qui télécharge des vidéos Youtube.** Vous l'appellerez `yt.sh`. Il sera stocké dans `/srv/yt/yt.sh`.

➜ **1. Permettre le téléchargement d'une vidéo youtube dont l'URL est passée au script**

➜ **2. Le script produira une sortie personnalisée**

➜ **3. A chaque vidéo téléchargée, votre script produira une ligne de log dans le fichier `/var/log/yt/download.log`**

## Rendu

📁 **Le script `/srv/yt/yt.sh`**

📁 **Le fichier de log `/var/log/yt/download.log`**, avec au moins quelques lignes

🌞 Vous fournirez dans le compte-rendu, en plus du fichier, **un exemple d'exécution avec une sortie**, dans des balises de code.
```bash
thomas@thomas-VirtualBox:~$ sudo bash /srv/yt/yt.sh https://www.youtube.com/watch?v=VtzvlXL9gXk
Video https://www.youtube.com/watch?v=VtzvlXL9gXk was downloaded.
File path : /srv/yt/downloads/za warudo/za warudo.mp4
```

# III. MAKE IT A SERVICE

YES. Yet again. **On va en faire un [service](../../cours/notions/serveur/README.md#ii-service).**

## Rendu

📁 **Le script `/srv/yt/yt-v2.sh`**

📁 **Fichier `/etc/systemd/system/yt.service`**

🌞 Vous fournirez dans le compte-rendu, en plus des fichiers :
- un `systemctl status yt` quand le service est en cours de fonctionnement
```bash
thomas@thomas-VirtualBox:~$ systemctl status yt.service
● yt.service - My youtube downloader
     Loaded: loaded (/etc/systemd/system/yt.service; enabled; vendor preset: enabled)
     Active: active (running) since Mon 2021-11-22 00:24:11 CET; 7min ago
   Main PID: 3384 (bash)
      Tasks: 2 (limit: 2299)
     Memory: 1.5M
     CGroup: /system.slice/yt.service
             ├─3384 /usr/bin/bash /srv/yt/yt-v2.sh
             └─3533 sleep 10
```
- un extrait de `journalctl -xe -u yt`
```bash
thomas@thomas-VirtualBox:~$ journalctl -xe -u yt
-- The job identifier is 3627.
nov. 22 00:24:50 thomas-VirtualBox bash[3384]: Video https://www.youtube.com/watch?v=H9aC5AGY9YU was downloaded.
nov. 22 00:24:50 thomas-VirtualBox bash[3384]: File path : /srv/yt/downloads/juan./juan..mp4
nov. 22 00:25:40 thomas-VirtualBox bash[3384]: Video https://www.youtube.com/watch?v=tJpSVqmG27I was downloaded.
nov. 22 00:25:40 thomas-VirtualBox bash[3384]: File path : /srv/yt/downloads/pablo! (meme)/pablo! (meme).mp4
```
- la commande qui permet à ce service de démarrer automatiquement quand la machine démarre
```bash
thomas@thomas-VirtualBox:~$ sudo systemctl enable yt.service
```
