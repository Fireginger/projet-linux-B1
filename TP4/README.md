# TP4 : Une distribution orientée serveur

Maow dans ce TP on va setup quelque chose qui ressemble un peu plus à un serveur de la vraie vie.

Un des principaux trucs qu'on va jeter c'est l'interface graphique : à quoi ça sert de cliquer dans 40 menus sur des machins quand on peut faire la même chose en une seule ligne de commande puissante ?

Qui dit serveur dit servir, on mettra en place un serveur Web dans la deuxième partie du TP.

# Sommaire

- TP4 : Une distribution orientée serveur
- Sommaire](#sommaire)
- I. Install de Rocky Linux
- II. Checklist
- III. Mettre en place un service
  - 1. Intro NGINX
  - 2. Install
  - 3. Analyse
  - 4. Visite du service web
  - 5. Modif de la conf du serveur web

# I. Install de Rocky Linux

# II. Checklist

🌞 **Choisissez et définissez une IP à la VM**

- vous allez devoir configurer l'interface host-only
- ce sera nécessaire pour pouvoir SSH dans la VM et donc écrire le compte-rendu
- je veux, dans le compte-rendu :
  - le contenu de votre fichier de conf
```bash
TYPE=Ethernet
BOOTPROTO=static
NAME=enp0s8
DEVICE=enp0s8
ONBOOT=yes
IPADDR=10.250.1.56
NETMASK=255.255.255.0
```
  - le résultat d'un `ip a` pour me prouver que les changements on pris effet
```bash
[thomas@localhost ~]$ ip a
3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
  link/ether 08:00:27:63:63:08 brd ff:ff:ff:ff:ff:ff
  inet 10.250.1.56/24 brd 10.250.1.255 scope global noprefixroute enp0s8
      valid_lft forever preferred_lft forever
  inet6 fe80::a00:27ff:fe63:6308/64 scope link
      valid_lft forever preferred_lft forever
```
➜ **Connexion SSH fonctionnelle**

🌞 **Vous me prouverez que :**
- le service ssh est actif sur la VM
```bash
[thomas@localhost ~]$ systemctl status sshd
● sshd.service - OpenSSH server daemon
   Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; vendor preset: enabled)
   Active: active (running) since Tue 2021-11-23 16:21:46 CET; 1h 12min ago
     Docs: man:sshd(8)
           man:sshd_config(5)
 Main PID: 857 (sshd)
    Tasks: 1 (limit: 4935)
   Memory: 4.2M
   CGroup: /system.slice/sshd.service
```
- vous pouvez vous connecter à la VM, grâce à un échange de clés :
> Pour me prouver que vous pouvez vous connecter avec un échange de clé il faut me montrer, dans l'idéal :
la clé publique (le cadenas) sur votre PC :
```bash
C:\Users\Thomas\.ssh>type id_rsa.pub
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC5mCFAXJwojFe0U/ztyA/xxA6FClZD6Z+zencacPkKSoENj0uZz7g5bklubOsiZbvdvUpJ4bvJsT4amCieOf/xSJ/BbTxi72OEgaP6BZpAf2zdnQy7hpB3Kwlm5YzGOg3Tf3HnlUhbRlat5ecj5K0R83mtRoqRQmCv9z5YRuTLa9ISI55u0mfW6qhoNgbbWND49aMr1zs7yumKiXABVz9Cd/UZWtJuUqpZQtFzRKcf5FCbOVuJQH+J10MxNX6Mi3OQ2USE8IK2dO7gFCItcivIxc8Cj3bEkAQkGAIphKCx14gPXDF35Dm79Tkr2iCUNJ0RpOzfAlJqCA8MY91abkge8SuPsMWyfaoGwpIST2bhGfJM9DEULzMPul7dTbwMPWZaLVNE+c9VvB1wMZvu1ApoC9aISse9VqHlAIGDthnEZN82MtplJF+oljpb4uN7VSiGzQiTQFHBxPbf5d7J4iNPFZL4EbweTh1Qoa0NzIXdKdENqNOzTDLXhSp1WmNcXexJfeaqEEZe5zUK3ykZEntFgw5m747/Ac9Z0pv5/0hMr1liHmcp2YqPYWSfObrk1SRwHwb1GNsjkIjVQjgJxw1BU3U3sMot3qwIPjPvUA+IKMw20PFfMeFXW+c1V2z0oDw2dyM6sbpImV9eEwHd27zxTzN8BzZNGYzPeecPPG4c2Q== thomas@THOMAS_YNOV
```
un `cat` du fichier `authorized_keys` concerné sur la VM :
```bash
[thomas@localhost ~]$ cat /home/thomas/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC5mCFAXJwojFe0U/ztyA/xxA6FClZD6Z+zencacPkKSoENj0uZz7g5bklubOsiZbvdvUpJ4bvJsT4amCieOf/xSJ/BbTxi72OEgaP6BZpAf2zdnQy7hpB3Kwlm5YzGOg3Tf3HnlUhbRlat5ecj5K0R83mtRoqRQmCv9z5YRuTLa9ISI55u0mfW6qhoNgbbWND49aMr1zs7yumKiXABVz9Cd/UZWtJuUqpZQtFzRKcf5FCbOVuJQH+J10MxNX6Mi3OQ2USE8IK2dO7gFCItcivIxc8Cj3bEkAQkGAIphKCx14gPXDF35Dm79Tkr2iCUNJ0RpOzfAlJqCA8MY91abkge8SuPsMWyfaoGwpIST2bhGfJM9DEULzMPul7dTbwMPWZaLVNE+c9VvB1wMZvu1ApoC9aISse9VqHlAIGDthnEZN82MtplJF+oljpb4uN7VSiGzQiTQFHBxPbf5d7J4iNPFZL4EbweTh1Qoa0NzIXdKdENqNOzTDLXhSp1WmNcXexJfeaqEEZe5zUK3ykZEntFgw5m747/Ac9Z0pv5/0hMr1liHmcp2YqPYWSfObrk1SRwHwb1GNsjkIjVQjgJxw1BU3U3sMot3qwIPjPvUA+IKMw20PFfMeFXW+c1V2z0oDw2dyM6sbpImV9eEwHd27zxTzN8BzZNGYzPeecPPG4c2Q== thomas@THOMAS_YNOV
```
et une connexion sans aucun mot de passe demandé :
```bash
C:\Users\Thomas>ssh thomas@10.250.1.56
Activate the web console with: systemctl enable --now cockpit.socket

Last login: Tue Nov 23 18:06:47 2021 from 10.250.1.1
[thomas@localhost ~]$
```

➜ **Accès internet**

🌞 **Prouvez que vous avez un accès internet**

- avec une commande `ping`
```bash
[thomas@localhost ~]$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=113 time=19.9 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=113 time=29.8 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=113 time=20.8 ms
64 bytes from 8.8.8.8: icmp_seq=4 ttl=113 time=19.9 ms
64 bytes from 8.8.8.8: icmp_seq=5 ttl=113 time=20.1 ms
64 bytes from 8.8.8.8: icmp_seq=6 ttl=113 time=19.8 ms
--- 8.8.8.8 ping statistics ---
6 packets transmitted, 6 received, 0% packet loss, time 5029ms
rtt min/avg/max/mdev = 19.752/21.713/29.820/3.645 ms

[thomas@localhost ~]$ ping 1.1.1.1
PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data.
64 bytes from 1.1.1.1: icmp_seq=1 ttl=63 time=5.29 ms
64 bytes from 1.1.1.1: icmp_seq=2 ttl=63 time=4.86 ms
64 bytes from 1.1.1.1: icmp_seq=3 ttl=63 time=7.94 ms
64 bytes from 1.1.1.1: icmp_seq=4 ttl=63 time=4.91 ms
64 bytes from 1.1.1.1: icmp_seq=5 ttl=63 time=5.70 ms
64 bytes from 1.1.1.1: icmp_seq=6 ttl=63 time=4.45 ms
--- 1.1.1.1 ping statistics ---
6 packets transmitted, 6 received, 0% packet loss, time 5022ms
rtt min/avg/max/mdev = 4.449/5.524/7.938/1.149 ms
```

🌞 **Prouvez que vous avez de la résolution de nom**

Un petit `ping` vers un nom de domaine, celui que vous voulez :
```bash
[thomas@localhost ~]$ ping animedigitalnetwork.fr
PING animedigitalnetwork.fr (52.222.174.67) 56(84) bytes of data.
64 bytes from server-52-222-174-67.cdg50.r.cloudfront.net (52.222.174.67): icmp_seq=1 ttl=245 time=20.2 ms
64 bytes from server-52-222-174-67.cdg50.r.cloudfront.net (52.222.174.67): icmp_seq=2 ttl=245 time=58.1 ms
64 bytes from server-52-222-174-67.cdg50.r.cloudfront.net (52.222.174.67): icmp_seq=3 ttl=245 time=19.2 ms
64 bytes from server-52-222-174-67.cdg50.r.cloudfront.net (52.222.174.67): icmp_seq=4 ttl=245 time=23.6 ms
64 bytes from server-52-222-174-67.cdg50.r.cloudfront.net (52.222.174.67): icmp_seq=5 ttl=245 time=35.6 ms
64 bytes from server-52-222-174-67.cdg50.r.cloudfront.net (52.222.174.67): icmp_seq=6 ttl=245 time=27.0 ms
--- animedigitalnetwork.fr ping statistics ---
6 packets transmitted, 6 received, 0% packet loss, time 5028ms
rtt min/avg/max/mdev = 19.183/30.619/58.139/13.438 ms
```

➜ **Nommage de la machine**

🌞 **Définissez `node1.tp4.linux` comme nom à la machine**

- montrez moi le contenu du fichier `/etc/hostname`
```bash
[thomas@node1 ~]$ cat /etc/hostname
node1.tp4.linux
```
- tapez la commande `hostname` (sans argument ni option) pour afficher votre hostname actuel
```bash
[thomas@node1 ~]$ hostname
node1.tp4.linux
```

# III. Mettre en place un service

## 1. Intro NGINX

NGINX (prononcé "engine-X") est un serveur web. C'est un outil de référence aujourd'hui, il est réputé pour ses performances et sa robustesse.
Une fois le serveur web installé, on récupère :

- **un service**
- **des fichiers de conf**
- **une racine web**
- **des logs**

## 2. Install

🌞 **Installez NGINX en vous référant à des docs online**
pour mettre à jour tous les paquets disponibles :
```bash
[thomas@node1 ~]$ sudo dnf upgrade
```
pour installer NGINX
```bash
[thomas@node1 ~]$ sudo dnf install nginx
```
## 3. Analyse

Avant de config étou, on va lancer à l'aveugle et inspecter ce qu'il se passe.
Commencez donc par démarrer le service NGINX :

```bash
$ sudo systemctl start nginx
$ sudo systemctl status nginx
```

🌞 **Analysez le service NGINX**
- avec une commande `ps`, déterminer sous quel utilisateur tourne le processus du service NGINX :
```bash
[thomas@node1 ~]$ ps -A | grep nginx
  80758 ?        00:00:00 nginx
  80759 ?        00:00:00 nginx
```
- avec une commande `ss`, déterminer derrière quel port écoute actuellement le serveur web
```bash
[thomas@node1 ~]$ sudo ss -laputen
tcp   LISTEN  0       128                  [::]:80             [::]:*      users:(("nginx",pid=81237,fd=9),("nginx",pid=81111,fd=9)) ino:163567 sk:d4 v6only:1 <->
```
- en regardant la conf, déterminer dans quel dossier se trouve la racine web
```bash
[thomas@node1 ~]$ sudo nano /etc/nginx/nginx.conf
    server {
        listen       80 default_server;
        listen       [::]:80 default_server;
        server_name  _;
        root         /usr/share/nginx/html;
```
- inspectez les fichiers de la racine web, et vérifier qu'ils sont bien accessibles en lecture par l'utilisateur qui lance le processus
```bash
[thomas@node1 ~]$ ls -l /usr/share/nginx/html/
total 20
-rw-r--r--. 1 root root 3332 Jun 10 11:09 404.html
-rw-r--r--. 1 root root 3404 Jun 10 11:09 50x.html
-rw-r--r--. 1 root root 3429 Jun 10 11:09 index.html
-rw-r--r--. 1 root root  368 Jun 10 11:09 nginx-logo.png
-rw-r--r--. 1 root root 1800 Jun 10 11:09 poweredby.png
```
On voit bien les trois r ce qui signifie que c'est "readable" par tou le monde.

## 4. Visite du service web

🌞 **Configurez le firewall pour autoriser le trafic vers le service NGINX** (c'est du TCP ;) )
```bash
[thomas@node1 ~]$ sudo firewall-cmd --add-port=80/tcp --permanent
success
```
On ajoute le port 80 comme port ouvert par le firewall.
```bash
[thomas@node1 ~]$ sudo firewall-cmd --reload
success
```
On reload pour que les changements prennent effet.

🌞 **Tester le bon fonctionnement du service**
```bash
[thomas@node1 ~]$ curl --head http://10.250.1.56/
HTTP/1.1 200 OK
Server: nginx/1.14.1
Date: Wed, 24 Nov 2021 18:38:56 GMT
Content-Type: text/html
Content-Length: 3429
Last-Modified: Thu, 10 Jun 2021 09:09:03 GMT
Connection: keep-alive
ETag: "60c1d6af-d65"
Accept-Ranges: bytes
```

## 5. Modif de la conf du serveur web

🌞 **Changer le port d'écoute**
- une simple ligne à modifier, vous me la montrerez dans le compte rendu
  - faites écouter NGINX sur le port 8080
```bash
[thomas@node1 ~]$ sudo nano /etc/nginx/nginx.conf
listen       8080 default_server;
```
- redémarrer le service pour que le changement prenne effet
  - `sudo systemctl restart nginx`
```bash
[thomas@node1 ~]$ systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Wed 2021-11-24 19:54:22 CET; 19s ago
  Process: 81109 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 81107 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 81106 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 81111 (nginx)
    Tasks: 2 (limit: 4935)
   Memory: 3.7M
   CGroup: /system.slice/nginx.service
           ├─81111 nginx: master process /usr/sbin/nginx
           └─81112 nginx: worker process
```
- prouvez-moi que le changement a pris effet avec une commande `ss
```bash
[thomas@node1 ~]$ sudo ss -laputen
tcp   LISTEN  0       128               0.0.0.0:8080        0.0.0.0:*      users:(("nginx",pid=81112,fd=8),("nginx",pid=81111,fd=8)) ino:163566 sk:d3 <->
```
- n'oubliez pas de fermer l'ancier port dans le firewall, et d'ouvrir le nouveau
```bash
[thomas@node1 ~]$ sudo firewall-cmd --remove-port=80/tcp --permanent
success
[thomas@node1 ~]$ sudo firewall-cmd --add-port=8080/tcp --permanent
success
[thomas@node1 ~]$ sudo firewall-cmd --reload
success
```
- prouvez avec une commande `curl` sur votre machine que vous pouvez désormais visiter le port 8080
```bash
[thomas@node1 ~]$ curl --head http://10.250.1.56:8080/
HTTP/1.1 200 OK
Server: nginx/1.14.1
Date: Wed, 24 Nov 2021 19:14:16 GMT
Content-Type: text/html
Content-Length: 3429
Last-Modified: Thu, 10 Jun 2021 09:09:03 GMT
Connection: keep-alive
ETag: "60c1d6af-d65"
Accept-Ranges: bytes
```

🌞 **Changer l'utilisateur qui lance le service**
- pour ça, vous créerez vous-même un nouvel utilisateur sur le système : `web`
```bash
[thomas@node1 ~]$ sudo useradd web
```
- l'utilisateur devra avoir un mot de passe, et un homedir défini explicitement à `/home/web`
```bash
C:\Users\Thomas>ssh web@10.250.1.56
web@10.250.1.56's password:
Activate the web console with: systemctl enable --now cockpit.socket

Last login: Wed Nov 24 22:00:25 2021 from 10.250.1.1
```
```bash
[web@node1 ~]$ pwd
/home/web
```
- un peu de conf à modifier dans le fichier de conf de NGINX pour définir le nouvel utilisateur en tant que celui qui lance le service
  - vous me montrerez la conf effectuée dans le compte-rendu
```bash
[thomas@node1 ~]$ sudo nano /etc/nginx/nginx.conf
# For more information on configuration, see:
#   * Official English Documentation: http://nginx.org/en/docs/
#   * Official Russian Documentation: http://nginx.org/ru/docs/

user web;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;
```
- vous prouverez avec une commande `ps` que le service tourne bien sous ce nouveau utilisateur
```bash
[thomas@node1 ~]$ sudo ps aux | grep nginx
root       82236  0.0  0.2 119160  2172 ?        Ss   22:30   0:00 nginx: master process /usr/sbin/nginx
web        82237  0.0  0.9 151820  7884 ?        S    22:30   0:00 nginx: worker process
thomas     82252  0.0  0.1 221928  1080 pts/0    S+   22:35   0:00 grep --color=auto nginx
```

🌞 **Changer l'emplacement de la racine Web**
- vous créerez un nouveau dossier : `/var/www/super_site_web`
  - avec un fichier  `/var/www/super_site_web/index.html` qui contient deux trois lignes de HTML, peu importe, un bon `<h1>toto</h1>` des familles, ça fera l'affaire
```bash
[thomas@node1 var]$ cat /var/www/super_site_web/index.html
<html>
    <head>
        <title>site internet</title>
    </head>

    <body>
        <h1>Et voila mon site Internet<h1>
    </body>
</html>
```
- le dossier et tout son contenu doivent appartenir à `web`
```bash
[thomas@node1 var]$ ls -l /var/www/
total 0
drwxr-xr-x. 2 web root 24 Nov 24 22:41 super_site_web

[thomas@node1 var]$ ls -l /var/www/super_site_web/
total 4
-rw-r--r--. 1 web root 142 Nov 24 22:44 index.html
```
- configurez NGINX pour qu'il utilise cette nouvelle racine web
```bash
[thomas@node1 ~]$ sudo nano /etc/nginx/nginx.conf
    server {
        listen       8080 default_server;
        listen       [::]:80 default_server;
        server_name  _;
        root         /var/www/super_site_web;
        index index.html;
```
- prouvez avec un `curl` depuis votre hôte que vous accédez bien au nouveau site
```bash
[thomas@node1 ~]$ curl http://10.250.1.56:8080/
<html>
    <head>
        <title>site internet</title>
    </head>

    <body>
        <h1>Et voila mon site Internet<h1>
    </body>
</html>
```
