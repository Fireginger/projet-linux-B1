# TP1 : Are you dead yet ?

Ce premier TP a pour objectif de vous familiariser avec les environnements GNU/Linux.  

On va apprendre à quoi servent les commandes élémentaires comme `cat`, `cd`, `ls`... **non c'est pas vrai, on va casser des machines d'abord. Hihi.**

---

**Le but va être de péter la machine virtuelle.**

Peu importe comment, faut la péteeeeer.

Par "péter" on entend la rendre inutilisable. Ca peut être strictement inutilisable, ou des trucs un peu plus légers, **soyez créatifs**.

➜ Si la machine boot même plus, c'est valide.  
➜ Si la machine boot mais qu'on peut rien faire du tout, c'est valide.  
➜ Si la machine boot, qu'on peut faire des trucs mais que pendant 15 secondes après c'est mort, c'est valide.  
➜ Si ça boot étou, mais que c'est VRAIMENT CHIANT d'utiliser la machine, c'est VALIDE.  

**Bref si on peut pas utiliser la machine normalement, c'est VA-LI-DE.**

---

🌞 **Trouver au moins 5 façons différentes de péter la machine**

# Première Façon : Reboot infini

Pour casser la machine en la faisaint reboot à l'infini il suffit d'aller dans le menu, on va dans **Session and Startup**, puis dans **Application Autostart** et on va venir créer une application, qu'on va appeler "rebootinf" ou n'importe quel autre nom. Dans la partie "command" de cette application on va venir mettre : `xfce4-session-logout --reboot`. Avec cette commande, lorsque l'utilisateur va venir taper son mot de passe, la machine va automatiquement reboot dès que le bureau va se lancer.

# Deuxième Façon : InfiniTrain

Pour casser la machine d'une façon plus amusante, on va venir faire passer un train à l'infini dans le terminal. Pour cela, on va en premier installer **sl** avec la commande `sudo apt install sl`. Ensuite, on va venir créer un fichier avec la commande `sudo nano train.sh`, et dans ce fichier on va mettre le programme:
```
xinput set-prop 12 "Device enabled" 0
xinput set-prop 11 "Device enabled" 0
while true
do
    sl
done
```
Ce programme va nous permettre grâce à la commande `xinput set-prop 12 "Device enabled" 0` et la commande `xinput set-prop 11 "Device enabled" 0` qui vont permettre respectivement de désactiver le clic de la souris et les touches du clavier, et grâce à la boucle **while true** qui permet de faire une boucle infini, d'éxecuter **sl** en continue dans le terminal sans qu'on puisse le fermer.
Ensuite, on va aller dans l'explorateur de fichier, on va faire apparaitre les fichiers cachés pour aller chercher un fichier qui s'appelle **.bashrc**. Dans ce fichier on va venir mettre la commande `sh ~/train.sh`, qui va faire éxecuter le programme **train.sh** dès qu'un terminal va se lancer. Enfin, pour aller encore plus loin on va aller dans le menu et chercher **Session and Startup**. On va créer une application qui va éxecuter comme commande : `exo-open --launch TerminalEmulator --maximize` qui va faire que dès que le mot de passe est tapé, **un terminal en grand écran va s'ouvrir avec un train qui va passer à l'infini, avec le clavier et la souris de bloqués, sans pouvoir fermer le terminal**. 
Enjoy ;)

# Troisième façon : Supprime all

Une façon un peu plus simple de casser une vm c'est juste de **TOUT SUPPRIMER**. Pour cela on a juste à aller dans un terminal, utiliser la commande `cd ..` pour se mettre à la racine de la machine, puis de taper la commande :
`sudo rm - rf ./*`, ce qui va nous permettre de supprimer tous les fichiers de la machine et de la rendre inutilisable.

# Quatrième Façon : InfiniTerminal

Pour casser la virtual machine, il existe une autre façon, ouvrir des terminals à l'infini jusqu'a ce que le pc ne puisse plus le supporter. Pour ceci, nous allons aller dans le fichier **.bashrc** et nous allons mettre ces commandes :
``` 
xmodmap -e 'keycode 64='
xinput set-prop 12 "Device enabled" 0
exo-open --launch TerminalEmulator
```
La première ligne de ce programme va nous permettre de désactiver la touche **alt** empêchant ainsi la combinaison **alt+f4** et **ctrl+alt+fn+f1**, et la deuxième ligne sert à désactiver le click de la souris, empechant alors de rapidement fermer les pages de terminal qui vont s'ouvrir à l'infini grâce à la troisième ligne du programme, qui va faire que dès qu'un terminal s'ouvre, un autre terminal va s'ouvrir, qui va lui même faire ouvrir un autre terminal...

# Cinquième façon : ForkBomb

Enfin comme dernière façon de casser la machine, il y a la **forkbomb** qui va venir surcharger la mémoire de la machine virtuelle. Pour cela, on va juste venir créer un fichier "forkbomb.sh" dans lequelle on va mettre la commande : 
`:(){ :|:& };:`
Ensuite, pour casser la machine il nous reste uniquement à faire : `./forkbomb.sh &`. Et voila, la machine va maintenant se surcharger en arrière-plan.
