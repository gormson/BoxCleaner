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

#verification qu'il y a bien une variable passée en paramètre
if [ -z "$1" ]
then
        echo "Aucun utilisateur spécifié, arrêt de reboot_rtorrent.sh!"
        exit
fi

killall --user "$1" rtorrent
rm /home/"$1"/.session/rtorrent.lock
su --command="screen -S $1-rtorrent -X quit" "$1"
su --command="screen -dmS $1-rtorrent rtorrent" "$1"
