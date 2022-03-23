# TP5 : P'tit cloud perso

Dans ce TP on va monter un ptit serveur cloud nous-mêmes. On parle ici d'un serveur de partage de fichiers, accessible depuis une jolie interface Web.

Un peu comme un DropBox ou Google Drive. Mais en mieux. Et à nous. :3

# Sommaire

- 0. Prérequis
- I. Setup DB
- II. Setup Web

# 0. Prérequis


# I. Setup DB

Côté base de données, on va utiliser MariaDB.

## Sommaire

-I. Setup DB
  -Sommaire
   -1. Install MariaDB
   -2. Conf MariaDB
   -3. Test

## 1. Install MariaDB

🌞 **Installer MariaDB sur la machine `db.tp5.linux`**
```bash
[thomas@db ~]$ sudo dnf install mariadb-server
Complete!
```
🌞 **Le service MariaDB**

- lancez-le avec une commande `systemctl`
```bash
[thomas@db ~]$ systemctl start mariadb
==== AUTHENTICATING FOR org.freedesktop.systemd1.manage-units ====
Authentication is required to start 'mariadb.service'.
Authenticating as: thomas
Password:
==== AUTHENTICATION COMPLETE ====
```
- exécutez la commande `sudo systemctl enable mariadb` pour faire en sorte que MariaDB se lance au démarrage de la machine
```bash
[thomas@db ~]$ sudo systemctl enable mariadb
Created symlink /etc/systemd/system/mysql.service → /usr/lib/systemd/system/mariadb.service.
Created symlink /etc/systemd/system/mysqld.service → /usr/lib/systemd/system/mariadb.service.
Created symlink /etc/systemd/system/multi-user.target.wants/mariadb.service → /usr/lib/systemd/system/mariadb.service.
```
- vérifiez qu'il est bien actif avec une commande `systemctl`
```bash
[thomas@db ~]$ systemctl status mariadb
● mariadb.service - MariaDB 10.3 database server
   Loaded: loaded (/usr/lib/systemd/system/mariadb.service; enabled; vendor prese>
   Active: active (running) since Fri 2021-11-26 14:23:10 CET; 3min 41s ago
     Docs: man:mysqld(8)
           https://mariadb.com/kb/en/library/systemd/
```
- déterminer sur quel port la base de données écoute avec une commande `ss`
  - je veux que l'information soit claire : le numéro de port avec le processus qu'il y a derrière
```bash
[thomas@db ~]$ sudo ss -laputen | grep mysqld
tcp   LISTEN 0      80                    *:3306            *:*     users:(("mysqld",pid=1643,fd=21)) uid:27 ino:26729 sk:7 v6only:0 <->
```
- isolez les processus liés au service MariaDB (commande `ps`)
  - déterminez sous quel utilisateur est lancé le process MariaDB
```bash
[thomas@db ~]$ ps aux | grep mysql
mysql       1643  0.0 10.9 1296832 90944 ?       Ssl  14:23   0:00 /usr/libexec/mysqld --basedir=/usr
```
🌞 **Firewall**

- pour autoriser les connexions qui viendront de la machine `web.tp5.linux`, il faut conf le firewall
  - ouvrez le port utilisé par MySQL à l'aide d'une commande `firewall-cmd`
```bash
[thomas@db ~]$ sudo firewall-cmd --add-port=3306/tcp --permanent
[sudo] password for thomas:
success
```

## 2. Conf MariaDB

Première étape : le `mysql_secure_installation`. C'est un binaire qui sert à effectuer des configurations très récurrentes, on fait ça sur toutes les bases de données à l'install.  
C'est une question de sécu.

🌞 **Configuration élémentaire de la base**

```bash
[thomas@db ~]$ mysql_secure_installation

NOTE: RUNNING ALL PARTS OF THIS SCRIPT IS RECOMMENDED FOR ALL MariaDB
      SERVERS IN PRODUCTION USE!  PLEASE READ EACH STEP CAREFULLY!

In order to log into MariaDB to secure it, we'll need the current
password for the root user.  If you've just installed MariaDB, and
you haven't set the root password yet, the password will be blank,
so you should just press enter here.

Enter current password for root (enter for none):
```
Cette partie nous demande si on a déja un mot de passe root.

```bash
Setting the root password ensures that nobody can log into the MariaDB
root user without the proper authorisation.

Set root password? [Y/n] Y
New password:
Re-enter new password:
Password updated successfully!
Reloading privilege tables..
 ... Success!
```
Cette partie nous fais rentrer un mot de passe root pour mariadb.

```bash
By default, a MariaDB installation has an anonymous user, allowing anyone
to log into MariaDB without having to have a user account created for
them.  This is intended only for testing, and to make the installation
go a bit smoother.  You should remove them before moving into a
production environment.

Remove anonymous users? [Y/n] Y
 ... Success!
```
Cette partie nous demande si on veut désactiver la connexion sans compte utilisateurs.

```bash
Disallow root login remotely? [Y/n] Y
 ... Success!
```
Cette partie nous demande si on veut désactiver la connexion root à distance.

```bash
By default, MariaDB comes with a database named 'test' that anyone can
access.  This is also intended only for testing, and should be removed
before moving into a production environment.

Remove test database and access to it? [Y/n] Y
 - Dropping test database...
 ... Success!
 - Removing privileges on test database...
 ... Success!
```
Cette partie nous demande si on veut désactiver la database "test" qui est une database accessible par tous.

```bash
Reloading the privilege tables will ensure that all changes made so far
will take effect immediately.

Reload privilege tables now? [Y/n] Y
 ... Success!

Cleaning up...

All done!  If you've completed all of the above steps, your MariaDB
installation should now be secure.

Thanks for using MariaDB!
```
Cette partie nous demande de redémarrer la table de privilèges pour mettre en place les changements.

🌞 **Préparation de la base en vue de l'utilisation par NextCloud**

- pour ça, il faut vous connecter à la base
```bash
[thomas@db ~]$ sudo mysql -u root -p
[sudo] password for thomas:
Enter password:
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 19
Server version: 10.3.28-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]>
```

## 3. Test

Bon, là il faut tester que la base sera utilisable par NextCloud.

🌞 **Installez sur la machine `web.tp5.linux` la commande `mysql`**
- vous utiliserez la commande `dnf provides` pour trouver dans quel paquet se trouve cette commande
```bash
[thomas@web ~]$ dnf provides mysql
Rocky Linux 8 - AppStream                                                               5.7 MB/s | 8.2 MB     00:01
Rocky Linux 8 - BaseOS                                                                  3.2 MB/s | 3.5 MB     00:01
Rocky Linux 8 - Extras                                                                   21 kB/s |  10 kB     00:00
mysql-8.0.26-1.module+el8.4.0+652+6de068a7.x86_64 : MySQL client programs and shared libraries
Repo        : appstream
Matched from:
Provide    : mysql = 8.0.26-1.module+el8.4.0+652+6de068a7
```
```bash
[thomas@web ~]$ sudo dnf install mysql
[sudo] password for thomas:
Last metadata expiration check: 1:07:54 ago on Fri 26 Nov 2021 02:44:53 PM CET.
Dependencies resolved.

Installed:
  mariadb-connector-c-config-3.1.11-2.el8_3.noarch               mysql-8.0.26-1.module+el8.4.0+652+6de068a7.x86_64
  mysql-common-8.0.26-1.module+el8.4.0+652+6de068a7.x86_64

Complete!
```

🌞 **Tester la connexion**

 utilisez la commande `mysql` depuis `web.tp5.linux` pour vous connecter à la base qui tourne sur `db.tp5.linux`
```bash
[thomas@web ~]$ mysql --host=10.5.1.12 --user=nextcloud --port=3306 -p --database=nextcloud
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 29
Server version: 5.5.5-10.3.28-MariaDB MariaDB Server
```
- une fois connecté à la base en tant que l'utilisateur `nextcloud` :
  - effectuez un bête `SHOW TABLES;`
```bash
mysql> SHOW TABLES;
Empty set (0.00 sec)
```

# II. Setup Web

## Sommaire

- II. Setup Web
  - Sommaire
  - 1. Install Apache
    - A. Apache
    - B. PHP
  - 2. Conf Apache
  - 3. Install NextCloud
  - 4. Test

## 1. Install Apache

### A. Apache

🌞 **Installer Apache sur la machine `web.tp5.linux`**
```bash
[thomas@web ~]$ sudo dnf install httpd
Complete!
```
🌞 **Analyse du service Apache**
- lancez le service `httpd` et activez le au démarrage
```bash
[thomas@web ~]$ systemctl start httpd
==== AUTHENTICATING FOR org.freedesktop.systemd1.manage-units ====
Authentication is required to start 'httpd.service'.
Authenticating as: thomas
Password:
==== AUTHENTICATION COMPLETE ====

[thomas@web ~]$ sudo systemctl enable httpd
```
- isolez les processus liés au service `httpd`
```bash
[thomas@web ~]$ sudo ss -laputen | grep httpd
tcp   LISTEN 0      128                   *:80              *:*     users:(("httpd",pid=907,fd=4),("httpd",pid=906,fd=4),("httpd",pid=905,fd=4),("httpd",pid=874,fd=4)) ino:22934 sk:6 v6only:0 <->
```
- déterminez sur quel port écoute Apache par défaut
Il écoute sur le port 80.
- déterminez sous quel utilisateur sont lancés les processus Apache
```bash
[thomas@web ~]$ ps aux | grep httpd
apache       903  0.0  1.0 296924  8456 ?        S    21:11   0:00 /usr/sbin/httpd -DFOREGROUND
apache       905  0.0  2.2 1485828 18308 ?       Sl   21:11   0:01 /usr/sbin/httpd -DFOREGROUND
apache       906  0.0  1.9 1354692 16268 ?       Sl   21:11   0:00 /usr/sbin/httpd -DFOREGROUND
apache       907  0.0  1.9 1354692 16268 ?       Sl   21:11   0:00 /usr/sbin/httpd -DFOREGROUND
```
Les processus Apache sont lancés sous l'utilisateur Apache.

🌞 **Un premier test**

- ouvrez le port d'Apache dans le firewall
```bash
[thomas@web ~]$ sudo firewall-cmd --add-port=80/tcp --permanent
success
[thomas@web ~]$ sudo firewall-cmd --reload
success
```
- testez, depuis votre PC, que vous pouvez accéder à la page d'accueil par défaut d'Apache
  - avec une commande `curl`
```bash
  [thomas@web ~]$ curl www.apache.com
<!DOCTYPE html>
<!--[if lt IE 7 ]>      <html lang="en-US" class="no-js ie6"> <![endif]-->
<!--[if IE 7 ]>         <html lang="en-US" class="no-js ie7"> <![endif]-->
<!--[if IE 8 ]>         <html lang="en-US" class="no-js ie8"> <![endif]-->
<!--[if IE 9 ]>         <html lang="en-US" class="no-js ie9"> <![endif]-->
<!--[if (gt IE 9)|!(IE)]><!-->
<html lang="en-US" class="no-js"> <!--<![endif]-->
<head>
<meta charset="UTF-8" />

<!-- Title now generate from add_theme_support('title-tag') -->



<!-- STYLESHEET INIT -->
<link href="http://www.apache.com/wp-content/themes/mesocolumn/style.css" rel="stylesheet" type="text/css" />
```
Je ne met qu'un bout du curl étant donné qu'il est très long.
### B. PHP

NextCloud a besoin d'une version bien spécifique de PHP.  
Suivez **scrupuleusement** les instructions qui suivent pour l'installer.

🌞 **Installer PHP**

# ajout des dépôts EPEL
$ sudo dnf install epel-release
```bash
[thomas@web ~]$ sudo dnf install epel-release
Last metadata expiration check: 0:53:15 ago on Sun 28 Nov 2021 10:04:57 PM CET.
Complete!
```
$ sudo dnf update
```bash
[thomas@web ~]$ sudo dnf update
Last metadata expiration check: 0:53:46 ago on Sun 28 Nov 2021 10:04:57 PM CET.
Dependencies resolved.
Complete!
```
# ajout des dépôts REMI
$ sudo dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm
```bash
[thomas@web ~]$ sudo dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm
Last metadata expiration check: 0:54:06 ago on Sun 28 Nov 2021 10:04:57 PM CET.
remi-release-8.rpm
Complete!
```
$ dnf module enable php:remi-7.4
```bash
[thomas@web ~]$ sudo dnf module enable php:remi-7.4
Last metadata expiration check: 0:54:17 ago on Sun 28 Nov 2021 10:04:57 PM CET.
Dependencies resolved.
Complete!
```
# install de PHP et de toutes les libs PHP requises par NextCloud
$ sudo dnf install zip unzip libxml2 openssl php74-php php74-php-ctype php74-php-curl php74-php-gd php74-php-iconv php74-php-json php74-php-libxml php74-php-mbstring php74-php-openssl php74-php-posix php74-php-session php74-php-xml php74-php-zip php74-php-zlib php74-php-pdo php74-php-mysqlnd php74-php-intl php74-php-bcmath php74-php-gmp
```bash
[thomas@web ~]$ sudo dnf install zip unzip libxml2 openssl php74-php php74-php-ctype php74-php-curl php74-php-gd php74-php-iconv php74-php-json php74-php-libxml php74-php-mbstring php74-php-openssl php74-php-posix php74-php-session php74-php-xml php74-php-zip php74-php-zlib php74-php-pdo php74-php-mysqlnd php74-php-intl php74-php-bcmath php74-php-gmp
Last metadata expiration check: 0:54:31 ago on Sun 28 Nov 2021 10:04:57 PM CET.
Complete!
```

## 2. Conf Apache

🌞 **Analyser la conf Apache**

- mettez en évidence, dans le fichier de conf principal d'Apache, la ligne qui inclut tout ce qu'il y a dans le dossier de *drop-in*
```bash
IncludeOptional conf.d/*.conf
```

🌞 **Créer un VirtualHost qui accueillera NextCloud**
- créez un nouveau fichier dans le dossier de *drop-in*
  - attention, il devra être correctement nommé (l'extension) pour être inclus par le fichier de conf principal
```bash
[thomas@web ~]$ cat /etc/httpd/conf.d/virtualhost.conf
<VirtualHost *:80>
  # on précise ici le dossier qui contiendra le site : la racine Web
  DocumentRoot /var/www/nextcloud/html/

  # ici le nom qui sera utilisé pour accéder à l'application
  ServerName  web.tp5.linux

  <Directory /var/www/nextcloud/html/>
    Require all granted
    AllowOverride All
    Options FollowSymLinks MultiViews

    <IfModule mod_dav.c>
      Dav off
    </IfModule>
  </Directory>
</VirtualHost>
```
🌞 **Configurer la racine web**

- la racine Web, on l'a configurée dans Apache pour être le dossier `/var/www/nextcloud/html/`
- creéz ce dossier
```bash
[thomas@web www]$ sudo mkdir nextcloud
[thomas@web netxcloud]$ sudo mkdir html
```
- faites appartenir le dossier et son contenu à l'utilisateur qui lance Apache (commande `chown`, voir le [mémo commandes](../../cours/memos/commandes.md))
```bash
[thomas@web www]$ sudo chown apache:apache netxcloud/
[thomas@web www]$ sudo chown apache:apache html/
[thomas@web www]$ ls -l
total 0
drwxr-xr-x. 2 root   root  6 Nov 15 04:13 cgi-bin
drwxr-xr-x. 2 apache root  6 Nov 15 04:13 html
drwxr-xr-x. 3 apache apache 18 Nov 26 17:58 netxcloud
```

🌞 **Configurer PHP**
- dans l'install de NextCloud, PHP a besoin de conaître votre timezone (fuseau horaire)
- pour récupérer la timezone actuelle de la machine, utilisez la commande `timedatectl` (sans argument)
```bash
[thomas@web www]$ timedatectl
               Local time: Mon 2021-11-29 07:42:25 CET
           Universal time: Mon 2021-11-29 06:42:25 UTC
                 RTC time: Mon 2021-11-29 06:42:23
                Time zone: Europe/Paris (CET, +0100)
System clock synchronized: yes
              NTP service: active
          RTC in local TZ: no
```
- modifiez le fichier `/etc/opt/remi/php74/php.ini` :
  - changez la ligne `;date.timezone =`
  - par `date.timezone = "<VOTRE_TIMEZONE>"`
  - par exemple `date.timezone = "Europe/Paris"`
```bash
[thomas@web www]$ cat /etc/opt/remi/php74/php.ini | grep timezone
; Defines the default timezone used by the date functions
; http://php.net/date.timezone
date.timezone = "Europe/Paris"
```

## 3. Install NextCloud

On dit "installer NextCloud" mais en fait c'est juste récupérer les fichiers PHP, HTML, JS, etc... qui constituent NextCloud, et les mettre dans le dossier de la racine web.

🌞 **Récupérer Nextcloud**
```bash
[thomas@web www]$ cd

[thomas@web ~]$ curl -SLO https://download.nextcloud.com/server/releases/nextcloud-21.0.1.zip
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  148M  100  148M    0     0  28.1M      0  0:00:05  0:00:05 --:--:-- 32.0M

[thomas@web ~]$ ls
nextcloud-21.0.1.zip
```
🌞 **Ranger la chambre**

- extraire le contenu de NextCloud (beh ui on a récup un `.zip`)
```bash
[thomas@web ~]$ unzip nextcloud-21.0.1.zip

[thomas@web ~]$ ls
nextcloud  nextcloud-21.0.1.zip
```
- déplacer tout le contenu dans la racine Web
  - n'oubliez pas de gérer les permissions de tous les fichiers déplacés ;)
```bash
[thomas@web ~]$ sudo mv nextcloud /var/www/netxcloud/html/

[thomas@web html]$ sudo chown -hR apache:apache /var/www/nextcloud/html/
[thomas@web html]$ ls -al
total 128
drwxr-xr-x. 13 apache apache  4096 Nov 29 22:32 .
drwxr-xr-x.  3 apache apache    18 Nov 29 22:18 ..
drwxr-xr-x. 43 apache apache  4096 Apr  8  2021 3rdparty
drwxr-xr-x. 47 apache apache  4096 Apr  8  2021 apps
-rw-r--r--.  1 apache apache 17900 Apr  8  2021 AUTHORS
drwxr-xr-x.  2 apache apache    67 Apr  8  2021 config
-rw-r--r--.  1 apache apache  3900 Apr  8  2021 console.php
-rw-r--r--.  1 apache apache 34520 Apr  8  2021 COPYING
drwxr-xr-x. 22 apache apache  4096 Apr  8  2021 core
-rw-r--r--.  1 apache apache  5122 Apr  8  2021 cron.php
-rw-r--r--.  1 apache apache  2734 Apr  8  2021 .htaccess
-rw-r--r--.  1 apache apache   156 Apr  8  2021 index.html
-rw-r--r--.  1 apache apache  2960 Apr  8  2021 index.php
drwxr-xr-x.  6 apache apache   125 Apr  8  2021 lib
-rw-r--r--.  1 apache apache   283 Apr  8  2021 occ
drwxr-xr-x.  2 apache apache    23 Apr  8  2021 ocm-provider
drwxr-xr-x.  2 apache apache    55 Apr  8  2021 ocs
drwxr-xr-x.  2 apache apache    23 Apr  8  2021 ocs-provider
-rw-r--r--.  1 apache apache  3144 Apr  8  2021 public.php
-rw-r--r--.  1 apache apache  5341 Apr  8  2021 remote.php
drwxr-xr-x.  4 apache apache   133 Apr  8  2021 resources
-rw-r--r--.  1 apache apache    26 Apr  8  2021 robots.txt
-rw-r--r--.  1 apache apache  2446 Apr  8  2021 status.php
drwxr-xr-x.  3 apache apache    35 Apr  8  2021 themes
drwxr-xr-x.  2 apache apache    43 Apr  8  2021 updater
-rw-r--r--.  1 apache apache   101 Apr  8  2021 .user.ini
-rw-r--r--.  1 apache apache   382 Apr  8  2021 version.php
```
- supprimer l'archive
```bash
[thomas@web ~]$ sudo rm nextcloud-21.0.1.zip
```

## 4. Test

🌞 **Modifiez le fichier `hosts` de votre PC**

- ajoutez la ligne : `10.5.1.11 web.tp5.linux
```bash
# Copyright (c) 1993-2009 Microsoft Corp.
#
# This is a sample HOSTS file used by Microsoft TCP/IP for Windows.
#
# This file contains the mappings of IP addresses to host names. Each
# entry should be kept on an individual line. The IP address should
# be placed in the first column followed by the corresponding host name.
# The IP address and the host name should be separated by at least one
# space.
#
# Additionally, comments (such as these) may be inserted on individual
# lines or following the machine name denoted by a '#' symbol.
#
# For example:
#
#      102.54.94.97     rhino.acme.com          # source server
#       38.25.63.10     x.acme.com              # x client host

# localhost name resolution is handled within DNS itself.
#	127.0.0.1       localhost
#	::1             localhost
10.5.1.11       web.tp5.linux
```


