#!/bin/bash

#########################################################################
#									#
# Script : reboot_rorrents.sh				        	#
# Description : Relance le processus rtorrent d'un utilisateur		#
# Input : $1 - le nom de l'utilisateur          			#
#									#
# Auteur : GorMsoN							#
#                                                                       #
#########################################################################

# variables de couleurs
CSI="\033["
CEND="${CSI}0m"
CRED="${CSI}1;31m"
CGREEN="${CSI}1;32m"
CYELLOW="${CSI}1;33m"
CBLUE="${CSI}1;34m"

#verification qu'il y a bien une variable passée en paramètre
if [ -z "$1" ]
then
        echo -e "${CRED}Aucun utilisateur spécifié, arrêt de reboot_rtorrent.sh!${CEND}"
        exit
fi

echo -e "${CYELLOW}Kill du process rtorrent pour $1${CEND}"
killall --user "$1" rtorrent

echo -e "${CYELLOW}Suppression du fichier rtorrent.lock${CEND}"
rm /home/"$1"/.session/rtorrent.lock

echo -e "${CYELLOW}Quit Screen du process $1-rtorrent${CEND}"
su --command="screen -S $1-rtorrent -X quit" "$1"

echo -e "${CYELLOW}Lancement Screen du process $1-rtorrent${CEND}"
su --command="screen -dmS $1-rtorrent rtorrent" "$1"
