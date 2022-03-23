# TP6 : Stockage et sauvegarde


# Partie 1 : Préparation de la machine `backup.tp6.linux`


# I. Ajout de disque

🌞 **Ajouter un disque dur de 5Go à la VM `backup.tp6.linux`**
```bash
[thomas@backup ~]$ lsblk | grep 5G
sdb           8:16   0    5G  0 disk
```

🌞 **Partitionner le disque à l'aide de LVM**

- créer un *physical volume (PV)* : le nouveau disque ajouté à la VM
```bash
[thomas@backup ~]$ sudo pvcreate /dev/sdb
[sudo] password for thomas:
  Physical volume "/dev/sdb" successfully created.
[thomas@backup ~]$ sudo pvs
  PV         VG Fmt  Attr PSize  PFree
  /dev/sda2  rl lvm2 a--  <7.00g    0
  /dev/sdb      lvm2 ---   5.00g 5.00g
```
- créer un nouveau *volume group (VG)*
  - il devra s'appeler `backup`
  - il doit contenir le PV créé à l'étape précédente
```bash
[thomas@backup ~]$ sudo vgcreate backup /dev/sdb
  Volume group "backup" successfully created
```
- créer un nouveau *logical volume (LV)* : ce sera la partition utilisable
  - elle doit être dans le VG `backup`
  - elle doit occuper tout l'espace libre
```bash
[thomas@backup ~]$ sudo lvcreate -l 100%FREE backup -n last_backup
  Logical volume "last_backup" created.

[thomas@backup ~]$ sudo lvs
  last_backup backup -wi-a-----  <5.00g
```

🌞 **Formater la partition**
- vous formaterez la partition en ext4 (avec une commande `mkfs`)
  - le chemin de la partition, vous pouvez le visualiser avec la commande `lvdisplay`
  - pour rappel un *Logical Volume (LVM)* **C'EST** une partition
```bash
[thomas@backup ~]$ sudo mkfs -t ext4 /dev/backup/last_backup
mke2fs 1.45.6 (20-Mar-2020)
Creating filesystem with 1309696 4k blocks and 327680 inodes
Filesystem UUID: 45296045-770b-490f-ab93-5bb0ccd1c2ad
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912, 819200, 884736

Allocating group tables: done
Writing inode tables: done
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done
```

🌞 **Monter la partition**

- montage de la partition (avec la commande `mount`)
  - la partition doit être montée dans le dossier `/backup`
  - preuve avec une commande `df -h` que la partition est bien montée
```bash
[thomas@backup ~]$ df -h | grep backup
/dev/mapper/backup-last_backup  4.9G   20M  4.6G   1% /backup
```
  - prouvez que vous pouvez lire et écrire des données sur cette partition
```bash
[thomas@backup ~]$ mount | grep backup
/dev/mapper/backup-last_backup on /backup type ext4 (rw,relatime,seclabel)
```
On voit bien le rw qui signifie read and write.

- définir un montage automatique de la partition (fichier `/etc/fstab`)
  - vous vérifierez que votre fichier `/etc/fstab` fonctionne correctement
```bash
[thomas@backup ~]$ sudo umount backup/
[thomas@backup ~]$ sudo mount -av
/                        : ignored
/boot                    : already mounted
none                     : ignored
mount: /dev/backup does not contain SELinux labels.
       You just mounted an file system that supports labels which does not
       contain labels, onto an SELinux box. It is likely that confined
       applications will generate AVC messages and not be allowed access to
       this file system.  For more details see restorecon(8) and mount(8).
/backup              : successfully mounted
```
```bash
[thomas@backup ~]$ sudo lvs
  last_backup backup -wi-ao----  <5.00g
```

# Partie 2 : Setup du serveur NFS sur `backup.tp6.linux`

🌞 **Préparer les dossiers à partager**
- créez deux sous-dossiers dans l'espace de stockage dédié
```bash
[thomas@backup backup]$ sudo mkdir web.tp6.linux
[thomas@backup backup]$ sudo mkdir db.tp6.linux
[thomas@backup backup]$ ls
db.tp6.linux  lost+found  web.tp6.linux
```

🌞 **Install du serveur NFS**
- installez le paquet `nfs-utils`
```bash
[thomas@backup ~]$ sudo dnf install nfs-utils
Last metadata expiration check: 1 day, 17:36:04 ago on Wed 01 Dec 2021 04:54:48 PM CET.
Dependencies resolved.
Complete!
```

🌞 **Conf du serveur NFS**
- fichier `/etc/idmapd.conf`
```bash
[thomas@backup ~]$ cat /etc/idmapd.conf | grep tp6
Domain = tp6.linux
```
- fichier `/etc/exports`
```bash
[thomas@backup ~]$ [thomas@backup ~]$ cat /etc/exports
/dev/backup/web.tp6.linux 10.5.1.0/24(rw,no_root_squash)
/dev/backup/db.tp6.linux 10.5.1.0/24(rw,no_root_squash)
```
"rw" signifie read and write, ce qui signifie qu on peut écrire et lire ces fichiers.
"no_root_squash" signifie que le root de la machine a les droits root sur le répertoire.


🌞 **Démarrez le service**
- le service s'appelle `nfs-server`
- après l'avoir démarré, prouvez qu'il est actif
```bash
[thomas@backup ~]$ systemctl status nfs-server
● nfs-server.service - NFS server and services
   Loaded: loaded (/usr/lib/systemd/system/nfs-server.service; disabled; vendor preset: disabled)
   Active: active (exited) since Fri 2021-12-03 10:41:47 CET; 2s ago
  Process: 24782 ExecStopPost=/usr/sbin/exportfs -f (code=exited, status=0/SUCCESS)
  Process: 24780 ExecStopPost=/usr/sbin/exportfs -au (code=exited, status=0/SUCCESS)
  Process: 24779 ExecStop=/usr/sbin/rpc.nfsd 0 (code=exited, status=0/SUCCESS)
  Process: 24827 ExecStart=/bin/sh -c if systemctl -q is-active gssproxy; then systemctl reload gssproxy ; fi (code=exi>
  Process: 24816 ExecStart=/usr/sbin/rpc.nfsd (code=exited, status=0/SUCCESS)
  Process: 24815 ExecStartPre=/usr/sbin/exportfs -r (code=exited, status=0/SUCCESS)
 Main PID: 24827 (code=exited, status=0/SUCCESS)

Dec 03 10:41:47 backup.tp6.linux systemd[1]: Starting NFS server and services...
Dec 03 10:41:47 backup.tp6.linux systemd[1]: Started NFS server and services.
```
- faites en sorte qu'il démarre automatiquement au démarrage de la machine
```bash
[thomas@backup ~]$ sudo systemctl enable nfs-server
Created symlink /etc/systemd/system/multi-user.target.wants/nfs-server.service → /usr/lib/systemd/system/nfs-server.service.
```

🌞 **Firewall**
- le port à ouvrir et le `2049/tcp`
```bash
[thomas@backup ~]$ sudo firewall-cmd --add-port=2049/tcp --permanent
success
[thomas@backup ~]$ sudo firewall-cmd --reload
success
```
- prouvez que la machine écoute sur ce port (commande `ss`)
```bash
[thomas@backup ~]$ sudo ss -laputen | grep 2049
tcp   LISTEN 0      64                 [::]:2049          [::]:*     ino:58553 sk:19 v6only:1 <->
[thomas@backup ~]$ sudo ss -lapute | grep nfs
tcp   LISTEN 0      64                 [::]:nfs            [::]:*      ino:58553 sk:19 v6only:1 <-> 
```

# Partie 3 : Setup des clients NFS : `web.tp6.linux` et `db.tp6.linux`

On commence par `web.tp6.linux`.

🌞 **Install'**
```bash
[thomas@web ~]$ sudo dnf install nfs-utils
Last metadata expiration check: 1:56:15 ago on Fri 03 Dec 2021 03:35:25 PM CET.
Dependencies resolved.

Installed:
  gssproxy-0.8.0-19.el8.x86_64           keyutils-1.5.10-9.el8.x86_64        libverto-libevent-0.3.0-5.el8.x86_64
  nfs-utils-1:2.3.3-46.el8.x86_64        rpcbind-1.2.5-8.el8.x86_64

Complete!
```

🌞 **Conf'**
- pareil que pour le serveur : fichier `/etc/idmapd.conf`
```bash
[thomas@web ~]$ cat /etc/idmapd.conf | grep tp6
Domain = tp6.linux
```
🌞 **Montage !**

- montez la partition NFS `/backup/web.tp6.linux/` avec une comande `mount`
  - la partition doit être montée sur le point de montage `/srv/backup`
```bash
[thomas@web ~]$ [thomas@web ~]$ sudo mount -t nfs 10.5.1.13:/backup/web.tp6.linux/ /srv/backup
```
  - preuve avec une commande `df -h` que la partition est bien montée
```bash
[thomas@web ~]$ df -h |grep backup
10.5.1.13:/backup/web.tp6.linux  4.9G   20M  4.6G   1% /srv/backup
```
  - prouvez que vous pouvez lire et écrire des données sur cette partition
```bash
10.5.1.13:/backup/web.tp6.linux on /srv/backup type nfs4 (rw,relatime,vers=4.2,rsize=131072,wsize=131072,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,clientaddr=10.5.1.11,local_lock=none,addr=10.5.1.13)
```
On a toujours bien le r et le w qui signifie read and write.
- définir un montage automatique de la partition (fichier `/etc/fstab`)
  - vous vérifierez que votre fichier `/etc/fstab` fonctionne correctement
```bash
[thomas@web ~]$ sudo mount -av
/                        : ignored
/boot                    : already mounted
none                     : ignored
mount.nfs4: timeout set for Tue Dec  7 18:54:13 2021
mount.nfs4: trying text-based options 'vers=4.2,addr=10.5.1.13,clientaddr=10.5.1.11'
/srv/backup              : successfully mounted
```

🌞 **Répétez les opérations sur `db.tp6.linux`**
  - preuve avec une commande `df -h` que la partition est bien montée
```bash
[thomas@db ~]$ df -h | grep backup
10.5.1.13:/backup/db.tp6.linux  4.9G   20M  4.6G   1% /srv/backup
```
  - preuve que vous pouvez lire et écrire des données sur cette partition
```bash
[thomas@db ~]$ mount | grep backup
10.5.1.13:/backup/db.tp6.linux on /srv/backup type nfs4 (rw,relatime,vers=4.2,rsize=131072,wsize=131072,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,clientaddr=10.5.1.12,local_lock=none,addr=10.5.1.13)
```
  - preuve que votre fichier `/etc/fstab` fonctionne correctement
```bash
[thomas@db ~]$ sudo umount /srv/backup
[thomas@db ~]$ sudo mount -av
/                        : ignored
/boot                    : already mounted
none                     : ignored
mount.nfs4: timeout set for Tue Dec  7 19:01:53 2021
mount.nfs4: trying text-based options 'vers=4.2,addr=10.5.1.13,clientaddr=10.5.1.12'
/srv/backup              : successfully mounted
```

# Partie 4 : Scripts de sauvegarde

## I. Sauvegarde Web

🌞 **Ecrire un script qui sauvegarde les données de NextCloud**

fichier qui contient le script :
```bash
[thomas@web ~]$ cat sauvegarde.sh
#!/bin/bash
time_log=$(date +'%y/%m/%d %H:%M:%S')
time_tar=$(date +'%y%m%d_%H%M%S')
tar -czPvf /srv/backup/nextcloud_$time_tar.tar.gz /var/www/nextcloud
echo "[$time_log] Backup /srv/backup/nextcloud_$time_tar created successfully." >> /var/log/backup/backup.log
echo "Backup /srv/backup/nextcloud_$time_tar created successfully."
```

🌞 **Créer un service**
```bash
[thomas@web system]$ cat backup.service
[Unit]
Description=My backup service

[Service]
ExecStart=bash /home/thomas/sauvegarde.sh
Type=oneshot

[Install]
WantedBy=multi-user.target
```

🌞 **Vérifier que vous êtes capables de restaurer les données**
```bash
[thomas@web ~]$ sudo systemctl start backup
[thomas@web ~]$ cat /var/log/backup/backup.log
[21/12/07 22:38:44] Backup /srv/backup/nextcloud_211207_223844 created successfully.
```

🌞 **Créer un *timer***

Contenu du fichier `/etc/systemd/system/backup.timer` :
```bash
[thomas@web system]$ cat /etc/systemd/system/backup.timer
[Unit]
Description=Lance backup.service à intervalles réguliers
Requires=backup.service

[Timer]
Unit=backup.service
OnCalendar=hourly

[Install]
WantedBy=timers.target
```

Activez maintenant le *timer* avec :
```bash
# on indique qu'on a modifié la conf du système
[thomas@web system]$ sudo systemctl daemon-reload

# démarrage immédiat du timer
[thomas@web system]$ sudo systemctl start backup.timer

# activation automatique du timer au boot de la machine
[thomas@web system]$ sudo systemctl enable backup.timer
Created symlink /etc/systemd/system/timers.target.wants/backup.timer → /etc/systemd/system/backup.timer.
```

Enfin, on vérifie que le *timer* a été pris en compte, et on affiche l'heure de sa prochaine exécution :
```bash
[thomas@web system]$ sudo systemctl list-timers | grep backup
Tue 2021-12-07 23:00:00 CET  12min left    n/a                          n/a          backup.timer                 backup.service
```

## II. Sauvegarde base de données

🌞 **Ecrire un script qui sauvegarde les données de la base de données MariaDB**

fichier qui contient le script :
```bash
#!/bin/bash
time_log=$(date +'%y/%m/%d %H:%M:%S')
time_tar=$(date +'%y%m%d_%H%M%S')
mysqldump -h 10.5.1.12 -p -u nextcloud nextcloud > mysqlfile.sql
tar -czPvf /srv/backup/nextcloud_db_$time_tar.tar.gz mysqlfile.sql
echo "[$time_log] Backup /srv/backup/nextcloud_db_$time_tar created successfully." >> /var/log/backup/backup_db.log
echo "Backup /srv/backup/nextcloud_db_$time_tar created successfully."
```
🌞 **Créer un service**
- créer un service `backup_db.service` qui exécute votre script
```bash
[Unit]
Description=My backup db service

[Service]
ExecStart=bash /home/thomas/savedb.sh
Type=oneshot

[Install]
WantedBy=multi-user.target
```
🌞 **Créer un `timer`**
- il exécute le service `backup_db.service` toutes les heures
```bash
[Unit]
Description=Lance backup_db.service à intervalles réguliers
Requires=backup_db.service

[Timer]
Unit=backup_db.service
OnCalendar=hourly

[Install]
WantedBy=timers.target
```

```bash
[thomas@web system]$ sudo systemctl daemon-reload

[thomas@web system]$ sudo systemctl start backup_db.timer

[thomas@web system]$ sudo systemctl list-timers | grep backup
Wed 2021-12-08 01:00:00 CET  58min left n/a                          n/a          backup_db.timer              backup_db.service
```
