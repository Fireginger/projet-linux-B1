# TP2 : Explorer et manipuler le système

Dans nos cours, on ne va que peu s'attarder sur l'aspect client des systèmes GNU/Linux, mais plutôt sur la façon dont on le manipule en tant qu'admin.

Ca permettra aussi, *via* la manipulation, d'appréhender un peu mieux comment un OS de ce genre fonctionne.

# Prérequis

> Y'a toujours une section prérequis dans mes TPs, ça vous sert à préparer l'environnement pour réaliser le TP. Dans ce TP, c'est le premier avec des prérequis, alors je vais détailler le principe et vous devrez me rendre la réalisation de ces étapes dans le compte rendu.

## 1. Une machine xubuntu fonctionnelle

N'hésitez pas à cloner celle qu'on a créé ensemble.

**Pour TOUTES les commandes que je vous donne dans le TP**

- elles sont dans le [memo de commandes Linux](../../cours/memos/commandes.md)
- vous **DEVEZ** consulter le `help` au minimum voire le `man` ou faire une recherche Internet pour comprendre comment fonctionne la commande

```bash
# Consulter le help de ls
$ ls --help

# Consulter le manuel de ls
$ man ls
```

## 2. Nommer la machine

➜ **On va renommer la machine**

- parce qu'on s'y retrouve plus facilement
- parce que toutes les machines sont nommées dans la vie réelle, pour cette raison, alors habituez vous à le faire systématiquement :)

On désignera la machine par le nom `node1.tp2.linux`

🌞 **Changer le nom de la machine**# B1 linux TP2

# Hostname

```bash
thomas@thomas:~$ sudo hostname node1.tp2.linux
# déco/reco
thomas@node1:~$ sudo nano /etc/hostname
thomas@node1:~$ cat /etc/hostname
node1.tp2.linux
```

➜ **Vérifiez avant de continuer le TP que la configuration réseau de la machine est OK. C'est à dire :**

- la machine doit pouvoir joindre internet
- votre PC doit pouvoir `ping` la machine

🌞 **Config réseau fonctionnelle**

Pour vérifier que vous avez une configuration réseau correcte (étapes à réaliser DANS LA VM) :

```bash
thomas@node1:~$ ping 1.1.1.1
PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data.
64 bytes from 1.1.1.1: icmp_seq=1 ttl=54 time=23.3 ms
64 bytes from 1.1.1.1: icmp_seq=2 ttl=54 time=26.8 ms
64 bytes from 1.1.1.1: icmp_seq=3 ttl=54 time=25.5 ms
64 bytes from 1.1.1.1: icmp_seq=4 ttl=54 time=22.5 ms
--- 1.1.1.1 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3005ms
rtt min/avg/max/mdev = 22.477/24.539/26.846/1.726 ms

thomas@node1:~$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=113 time=23.4 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=113 time=25.2 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=113 time=26.1 ms
64 bytes from 8.8.8.8: icmp_seq=4 ttl=113 time=25.0 ms
--- 8.8.8.8 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3005ms
rtt min/avg/max/mdev = 23.386/24.919/26.092/0.976 ms

thomas@node1:~$ ping ynov.com
PING ynov.com (92.243.16.143) 56(84) bytes of data.
64 bytes from xvm-16-143.dc0.ghst.net (92.243.16.143): icmp_seq=1 ttl=50 time=26.1 ms
64 bytes from xvm-16-143.dc0.ghst.net (92.243.16.143): icmp_seq=2 ttl=50 time=24.2 ms
64 bytes from xvm-16-143.dc0.ghst.net (92.243.16.143): icmp_seq=3 ttl=50 time=23.0 ms
64 bytes from xvm-16-143.dc0.ghst.net (92.243.16.143): icmp_seq=4 ttl=50 time=21.8 ms
--- ynov.com ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3004ms
rtt min/avg/max/mdev = 21.806/23.783/26.132/1.592 ms
```
Ensuite on vérifie que notre PC peut `ping` la machine (étapes à réaliser SUR VOTRE PC) :

```bash
C:\Users\Thomas>ping 192.168.218.1

Envoi d’une requête 'Ping'  192.168.218.1 avec 32 octets de données :
Réponse de 192.168.218.1 : octets=32 temps<1ms TTL=128
Réponse de 192.168.218.1 : octets=32 temps<1ms TTL=128
Réponse de 192.168.218.1 : octets=32 temps<1ms TTL=128
Réponse de 192.168.218.1 : octets=32 temps<1ms TTL=128

Statistiques Ping pour 192.168.218.1:
    Paquets : envoyés = 4, reçus = 4, perdus = 0 (perte 0%),
Durée approximative des boucles en millisecondes :
    Minimum = 0ms, Maximum = 0ms, Moyenne = 0ms
```

# Part 1 : SSH


## 1. Installation du serveur

Sur les OS GNU/Linux, les installations se font à l'aide d'un gestionnaire de paquets.

🌞 **Installer le paquet `openssh-server`**

```bash
thomas@node1:~$ sudo apt install openssh-server
Reading package lists... Done
Building dependency tree
Reading state information... Done
openssh-server is already the newest version (1:8.2p1-4ubuntu0.3).
0 upgraded, 0 newly installed, 0 to remove and 68 not upgraded.
```

## 2. Lancement du service SSH

🌞 **Lancer le service `ssh`**

```bash
thomas@node1:~$ systemctl start ssh
==== AUTHENTICATING FOR org.freedesktop.systemd1.manage-units ===
Authentication is required to start 'ssh.service'.
Authenticating as: thomas,,, (thomas)
Password:
==== AUTHENTICATION COMPLETE ===

thomas@node1:~$ systemctl status ssh
● ssh.service - OpenBSD Secure Shell server
     Loaded: loaded (/lib/systemd/system/ssh.service; enabled; vendor preset: enabled)
     Active: active (running) since Wed 2021-10-27 11:14:04 CEST; 14min ago
       Docs: man:sshd(8)
             man:sshd_config(5)
   Main PID: 3836 (sshd)
      Tasks: 1 (limit: 2312)
     Memory: 2.6M
     CGroup: /system.slice/ssh.service
             └─3836 sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups
```

## 3. Etude du service SSH

🌞 **Analyser le service en cours de fonctionnement**

- afficher le statut du *service*
```bash
thomas@node1:~$ systemctl status ssh
● ssh.service - OpenBSD Secure Shell server
     Loaded: loaded (/lib/systemd/system/ssh.service; enabled; vendor preset: enabled)
     Active: active (running) since Wed 2021-10-27 11:14:04 CEST; 14min ago
       Docs: man:sshd(8)
             man:sshd_config(5)
   Main PID: 3836 (sshd)
      Tasks: 1 (limit: 2312)
     Memory: 2.6M
     CGroup: /system.slice/ssh.service
             └─3836 sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups
```
- afficher le/les processus liés au *service* `ssh`
```bash
thomas@node1:~$ ps -ef |  grep sshd
root         525       1  0 16:43 ?        00:00:00 sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups
root        1719     525  0 17:27 ?        00:00:00 sshd: thomas [priv]
thomas      1771    1719  0 17:27 ?        00:00:00 sshd: thomas@pts/1
thomas      7871    1772  0 17:45 pts/1    00:00:00 grep --color=auto sshd
```
- afficher le port utilisé par le *service* `ssh`
```bash
thomas@node1:~$ ss -l | grep ssh
tcp     LISTEN   0        128                                           0.0.0.0:ssh                                       0.0.0.0:*
tcp     LISTEN   0        128                                              [::]:ssh 
```
- afficher les logs du *service* `ssh`
```bash
cat /var/log/auth.log
Oct 27 10:56:46 node1 sshd[1432]: Accepted password for thomas from 192.168.218.1 port 63290 ssh2
Oct 27 10:56:46 node1 sshd[1432]: pam_unix(sshd:session): session opened for user thomas by (uid=0)
```

🌞 **Connectez vous au serveur**

- depuis votre PC, en utilisant un **client SSH**
```bash
thomas@node1:/$ ip a
3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:c6:db:11 brd ff:ff:ff:ff:ff:ff
    inet 192.168.218.16/24 brd 192.168.218.255 scope global dynamic noprefixroute enp0s8
thomas@node1:/$ ssh thomas@192.168.218.16
Welcome to Ubuntu 20.04.3 LTS (GNU/Linux 5.11.0-38-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

70 updates can be applied immediately.
19 of these updates are standard security updates.
To see these additional updates run: apt list --upgradable

Your Hardware Enablement Stack (HWE) is supported until April 2025.
Last login: Wed Oct 27 10:56:46 2021 from 192.168.218.1
```

## 4. Modification de la configuration du serveur

Pour modifier comment un *service* se comporte il faut modifier le fichier de configuration. On peut tout changer à notre guise.

🌞 **Modifier le comportement du service**
- effectuez le modifications suivante :
  - changer le ***port d'écoute*** du service *SSH*
```bash
thomas@node1:~$ cat /etc/ssh/sshd_config
Include /etc/ssh/sshd_config.d/*.conf
Port 12345
#AddressFamily any
#ListenAddress 0.0.0.0
#ListenAddress ::
```
- pour cette modification, prouver à l'aide d'une commande qu'elle a bien pris effet
```bash
thomas@node1:~$ ss -l
tcp        LISTEN      0            128                                                      [::]:12345                                    [::]:*
```
🌞 **Connectez vous sur le nouveau port choisi**

- depuis votre PC, avec un *client SSH*
```bash
C:\Users\Thomas>ssh thomas@192.168.218.16 -p 12345
thomas@192.168.218.16 password:
Welcome to Ubuntu 20.04.3 LTS (GNU/Linux 5.11.0-38-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

51 updates can be applied immediately.
To see these additional updates run: apt list --upgradable

Your Hardware Enablement Stack (HWE) is supported until April 2025.
Last login: Wed Oct 27 11:07:32 2021 from 192.168.218.1
```

# Partie 2 : FTP

## 1. Installation du serveur

🌞 **Installer le paquet `vsftpd`**
```bash
thomas@node1:~$ sudo apt install vsftpd
```
## 2. Lancement du service FTP

🌞 **Lancer le service `vsftpd`**
```bash
thomas@node1:~$ systemctl start vsftpd
==== AUTHENTICATING FOR org.freedesktop.systemd1.manage-units ===
Authentication is required to start 'vsftpd.service'.
Authenticating as: thomas,,, (thomas)
Password:
==== AUTHENTICATION COMPLETE ===

thomas@node1:~$ systemctl status vsftpd
● vsftpd.service - vsftpd FTP server
     Loaded: loaded (/lib/systemd/system/vsftpd.service; enabled; vendor preset: enabled)
     Active: active (running) since Wed 2021-10-27 11:23:20 CEST; 5min ago
   Main PID: 14000 (vsftpd)
      Tasks: 1 (limit: 2312)
     Memory: 528.0K
     CGroup: /system.slice/vsftpd.service
             └─14000 /usr/sbin/vsftpd /etc/vsftpd.conf

```

## 3. Etude du service FTP

🌞 **Analyser le service en cours de fonctionnement**
```bash
- afficher le statut du service
thomas@node1:~$ systemctl status vsftpd
● vsftpd.service - vsftpd FTP server
     Loaded: loaded (/lib/systemd/system/vsftpd.service; enabled; vendor preset: enabled)
     Active: active (running) since Wed 2021-10-27 11:23:20 CEST; 5min ago
   Main PID: 14000 (vsftpd)
      Tasks: 1 (limit: 2312)
     Memory: 528.0K
     CGroup: /system.slice/vsftpd.service
             └─14000 /usr/sbin/vsftpd /etc/vsftpd.conf

- afficher le/les processus liés au service `vsftpd`
thomas@node1:~$ ps -e | grep vsftpd
  14000 ?        00:00:00 vsftpd

- afficher le port utilisé par le service `vsftpd`
thomas@node1:~$ ss -l
tcp        LISTEN      0            32                                                          *:ftp                                         *:*

- afficher les logs du service `vsftpd`
thomas@node1:~$ journalctl | grep ftp
oct. 27 11:23:20 node1.tp2.linux systemd[1]: Starting vsftpd FTP server...
oct. 27 11:23:20 node1.tp2.linux systemd[1]: Started vsftpd FTP server.
```

🌞 **Connectez vous au serveur**

- depuis votre PC, en utilisant un *client FTP*

- essayez d'uploader et de télécharger un fichier
uploader :
```bash
Wed Oct 27 16:46:30 2021 [pid 4002] [thomas] OK UPLOAD: Client "::ffff:192.168.218.1", "/home/thomas/accompagnement informatique.txt", 38 bytes, 50.15Kbyte/sec
```
télécharger : 
```bash
Wed Oct 27 16:48:30 2021 [pid 4027] [thomas] OK DOWNLOAD: Client "::ffff:192.168.218.1", "/home/thomas/accompagnement informatique.txt", 38 bytes, 84.53Kbyte/sece
```
une fois un fichier upload, vérifiez avec un `ls` sur la machine Linux que le fichier a bien été uploadé
```bash
thomas@node1:~$ ls
'accompagnement informatique.txt'   Desktop   Documents   Downloads   Music   Pictures   Public   ssh   Templates   Videos
```

🌞 **Visualiser les logs**
- mettez en évidence une ligne de log pour un download
```bash
Wed Oct 27 16:04:13 2021 [pid 3862] [thomas] OK DOWNLOAD: Client "::ffff:192.168.218.1", "/home/thomas/accompagnement informatique.txt", 38 bytes, 76.04Kbyte/sec
```
- mettez en évidence une ligne de log pour un upload
```bash
Wed Oct 27 16:46:30 2021 [pid 4002] [thomas] OK UPLOAD: Client "::ffff:192.168.218.1", "/home/thomas/accompagnement informatique.txt", 38 bytes, 50.15Kbyte/sec
```

## 4. Modification de la configuration du serveur

Pour modifier comment un service se comporte il faut modifier de configuration. On peut tout changer à notre guise.

🌞 **Modifier le comportement du service**

- c'est dans le fichier `/etc/vsftpd.conf`
- effectuez les modifications suivantes :
  - changer le port où écoute `vstfpd`
```bash
thomas@node1:~$ cat /etc/vsftpd.conf
# Example config file /etc/vsftpd.conf
#
# The default compiled in settings are fairly paranoid. This sample file
# loosens things up a bit, to make the ftp daemon more usable.
# Please see vsftpd.conf.5 for all compiled in defaults.
#
#
listen_port=54321
```
- pour les deux modifications, prouver à l'aide d'une commande qu'elles ont bien pris effet
  - une commande `ss -l` pour vérifier le port d'écoute :
```bash
tcp     LISTEN   0        32                                                  *:54321                                           *:*
```
🌞 **Connectez vous sur le nouveau port choisi**

- depuis votre PC, avec un *client FTP*
- re-tester l'upload et le download

upload :
```bash
Wed Oct 27 17:03:10 2021 [pid 4129] [thomas] OK UPLOAD: Client "::ffff:192.168.218.1", "/home/thomas/accompagnement informatique.txt", 38 bytes, 45.20Kbyte/sec
```
download :
```bash
Wed Oct 27 17:03:14 2021 [pid 4137] [thomas] OK DOWNLOAD: Client "::ffff:192.168.218.1", "/home/thomas/accompagnement informatique.txt", 38 bytes, 65.91Kbyte/sec
```

# Partie 3 : Création de votre propre service

# II. Jouer avec netcat

Une fois la connexion établie, vous devrez pouvoir échanger des messages entre les deux machines, comme un petit chat !

🌞 **Donnez les deux commandes pour établir ce petit chat avec `netcat`**

- la commande tapée sur la VM
```bash
thomas@node1:~$ nc -l 1234
bonjour
j utilise netcat
pour parler entre deux machines
```
- la commande tapée sur votre PC
```bash
C:\Users\Thomas\Desktop\netcat>ncat.exe 192.168.218.16 1234
bonjour
j utilise netcat
pour parler entre deux machines
```

🌞 **Utiliser `netcat` pour stocker les données échangées dans un fichier**
Sur la vm :
```bash
thomas@node1:~$ sudo nano netcat_file
thomas@node1:~$ nc -l 1234 > netcat_file
```
Sur le PC :
```bash
C:\Users\Thomas\Desktop\netcat>ncat.exe 192.168.218.16 1234
bonjour
je
suis
thomas
```
Sur la vm :
```bash
thomas@node1:~$ cat netcat_file
bonjour
je
suis
thomas
```
Avec **>>**, la commande permet de sauvegarder ce qui est dans le fichier avant l'écriture, alors que **>** remplace tous ce qui a dans le fichier par ce qu'on écrit, sans garder ce qu'il y avait avant.

## 1. Créer le service

🌞 **Créer un nouveau service**

```bash
thomas@node1:~$ sudo nano /etc/systemd/system/chat_tp2.service


thomas@node1:~$ cat /etc/systemd/system/chat_tp2.service
[Unit]
Description=Little chat service (TP2)

[Service]
ExecStart=/usr/bin/nc -l 1234

[Install]
WantedBy=multi-user.target


thomas@node1:~$ which nc
/usr/bin/nc
```

## 2. Test test et retest

🌞 **Tester le nouveau service**
démarrer le système :
```bash
thomas@node1:~$ systemctl start chat_tp2.service
==== AUTHENTICATING FOR org.freedesktop.systemd1.manage-units ===
Authentication is required to start 'chat_tp2.service'.
Authenticating as: thomas,,, (thomas)
Password:
==== AUTHENTICATION COMPLETE ===
```
vérifier le système :
```bash
thomas@node1:~$ systemctl status chat_tp2.service
● chat_tp2.service - Little chat service (TP2)
     Loaded: loaded (/etc/systemd/system/chat_tp2.service; disabled; vendor preset: enabled)
     Active: active (running) since Mon 2021-11-08 19:51:08 CET; 1min 3s ago
   Main PID: 1760 (nc)
      Tasks: 1 (limit: 2312)
     Memory: 188.0K
     CGroup: /system.slice/chat_tp2.service
             └─1760 /usr/bin/nc -l 1234

nov. 08 19:51:08 node1.tp2.linux systemd[1]: Started Little chat service (TP2).
```
```bash
thomas@node1:~$ ss -l
tcp   LISTEN 0      1                                         0.0.0.0:1234                        0.0.0.0:*
```

```bash
# Voir l'état du service, et les derniers logs
thomas@node1:~$ systemctl status chat_tp2.service
● chat_tp2.service - Little chat service (TP2)
     Loaded: loaded (/etc/systemd/system/chat_tp2.service; disabled; vendor preset: enabled)
     Active: active (running) since Mon 2021-11-08 19:51:08 CET; 49min ago
   Main PID: 1760 (nc)
      Tasks: 1 (limit: 2312)
     Memory: 188.0K
     CGroup: /system.slice/chat_tp2.service
             └─1760 /usr/bin/nc -l 1234

nov. 08 19:51:08 node1.tp2.linux systemd[1]: Started Little chat service (TP2).


# Voir tous les logs du service
thomas@node1:~$ journalctl -xe -u chat_tp2.service
--
-- The unit chat_tp2.service has successfully entered the 'dead' state.
nov. 08 19:37:23 node1.tp2.linux systemd[1]: Started Little chat service (TP2).
-- Subject: A start job for unit chat_tp2.service has finished successfully
-- Defined-By: systemd
-- Support: http://www.ubuntu.com/support
--
-- A start job for unit chat_tp2.service has finished successfully.
--
-- The job identifier is 1595.
nov. 08 19:37:36 node1.tp2.linux nc[1491]: fz
nov. 08 19:37:40 node1.tp2.linux nc[1491]: bonjour
nov. 08 19:37:41 node1.tp2.linux nc[1491]: je
nov. 08 19:37:42 node1.tp2.linux nc[1491]: suis
nov. 08 19:37:43 node1.tp2.linux nc[1491]: thomas
nov. 08 19:37:45 node1.tp2.linux systemd[1]: chat_tp2.service: Succeeded.
-- Subject: Unit succeeded
-- Defined-By: systemd
-- Support: http://www.ubuntu.com/support
--
-- The unit chat_tp2.service has successfully entered the 'dead' state.
nov. 08 19:51:08 node1.tp2.linux systemd[1]: Started Little chat service (TP2).
-- Subject: A start job for unit chat_tp2.service has finished successfully
-- Defined-By: systemd
-- Support: http://www.ubuntu.com/support
--
-- A start job for unit chat_tp2.service has finished successfully.
--
-- The job identifier is 1859.


# Suivre en temps réel l'arrivée de nouveaux logs
thomas@node1:~$ journalctl -xe -u chat_tp2.service -f
-- The job identifier is 1859.
nov. 08 20:43:28 node1.tp2.linux nc[1760]: bonjour
nov. 08 20:43:32 node1.tp2.linux nc[1760]: je
nov. 08 20:43:34 node1.tp2.linux nc[1760]: suis
nov. 08 20:43:35 node1.tp2.linux nc[1760]: thomas
nov. 08 20:43:37 node1.tp2.linux nc[1760]: et
nov. 08 20:43:46 node1.tp2.linux nc[1760]: j utilise netcat
nov. 08 20:43:51 node1.tp2.linux systemd[1]: chat_tp2.service: Succeeded.
-- Subject: Unit succeeded
-- Defined-By: systemd
-- Support: http://www.ubuntu.com/support
--
-- The unit chat_tp2.service has successfully entered the 'dead' state.
```
