# A METTRE A JOUR
# BoxCleaner

## Avant-Propos

Ce script est basé sur une installation issue des excellent tutoriel du forum MonDedie.fr
Il sera donc à adapter suivant vos propres configurations.

## Installation & Configuration

### boxCleaner
- Installation des dépendances : `apt-get install libxmlrpc-c3-dev`
- `mkdir /opt/boxCleaner` (ou autre mais vous devrez modifier le dossier d'installation dans le fichier `default.conf`)
- `cd /opt/boxCleaner`
- `git clone https://github.com/gormson/BoxCleaner.git`

### Liste des utilisateurs
Création de la liste des utilisateurs 
- `nano utilisateurs.list`
- sur chaque ligne renseigner un `utilisateur` unique ayant un compte seedbox.

### Configuration rtorrent/rutorrent
verifier que dans le ficher `.rtorrent.rc`de chaque utilisateur les informations suivantes
- `scgi_port = 127.0.0.1:PORT`
- `PORT` est unique pour chaque utilisateur

### Configuration nginx
Nginx doit être configuré pour recevoir et aiguiller les requettes à rtorrent/rutorrent.
- `nano /etc/nginx/sites-enabled/boxCleaner.conf`
- renseigner les informations suivantes 

        server {
        	listen      80;
        	server_name localhost;
        	location /user {
            		include scgi_params;
            		scgi_pass 127.0.0.1:PORT; 
        	}
        }

- Le bloc location est à dupliquer et renseigner pour chaque utilisateur en correspondance avec son `.rtorrent.rc`

## Description Générale

`boxCleaner` est un ensemble de petit script que j'ai écrit pour pouvoir aider à l'entretient des seedbox.

## Fonctionnement:
1) Le contenu rutorrent de chaque utilisateurs est listé

2) Le contenu du dossier /home/`user`/torrents contenant les fichiers/dossiers avec les mêmes noms que les torrents est listé

3) Les deux listes sont comparées pour vérifier les incohérences

4) Un fichier d'ecart est créé (`./rapports/cummul_admin`) pour lister les fichiers sans attaches avec rutorrent/rtorrent

5) L'admin a la possibilité de lancer la suppression de tout ces éléments via `./boxCleaner.sh rapports/cummul_admin`

6) Une page html par utilisateur est créé (par défaut dans `/var/www/rutorrent/logserver/`) sous le nom rapport_`user`.hmtl

7) En complément un rapport admin résumant tous les rapports utilisateurs est créé au même endroit sous le nom `rapport_admin.html`

## Détections supportées
1) Un torrent présent dans rutorrent/rtorrent mais sans fichier associé >> `Mineur`, pas de consommation d'espace disque inutile

2) Un fichier présent sur le serveur mais sans torrent associé >> `Majeur`, consommation d'espace disque inutilement

## Scripts

### Les scripts principaux

Les principaux scripts sont les suivants:
- `boxScanner.sh` : Donne un état de correspondance,pour une liste d'utilisateur passée en paramètre, entre rutorrent/rtorrent et l'arborescence /home/`user`/torrents
- `user_boxScanner.sh` : idem que `boxScanner.sh` mais pour un utilisateur spécifique
- `boxCleaner.sh` : A partir de la liste des fichiers en trop créée par `boxScanner.sh`, permet d'effacer l'ensemble des fichiers/dossiers identifiés

### Scripts Complémentaires

Pour le bon fonctionnement de boxCleaner, les outils suivants sont utilisés
- `hardlink_delete` : supprime un fichier ou un dossier à partir de son inode pour supprimer aussi les liens durs éventuellement présents.
- `liste_torrents_user.sh` : Permet de lister les torrents actifs dans rutorrent/rtorrent pour un utilisateurs passé en paramètre
- `reboot_rtorrent.sh` : relance un processus `rtorrent` d'un utilisateur passé en paramètre
- `test_service.sh` : test si `user`-rtorrent est actif pour un utilisateur `user` passé en paramètre
- `test_arbo.sh`: test si l'arborescence de boxCleaner est conforme.
