# A METTRE A JOUR
# BoxCleaner

## Avant-Propos

Ce script est basé sur une installation issue des excellent tutoriel du forum MonDedie.fr
Il sera donc à adapter suivant vos propres configurations.

## Installation & Configuration

### boxCleaner
BoxCleaner propose un script d'installation automatique et de configuration de la liste des utilisateurs et des dossiers.
- `cd /tmp/`
- `git clone https://github.com/gormson/BoxCleaner.git`
- `cd BoxCleaner`
- `chmod +x install.sh && ./install.sh`

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

## Complément.

Pour plus de détail rendez-vous ici : https://mondedie.fr/viewtopic.php?id=7542

