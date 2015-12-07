#!/bin/bash

#########################################################################
#									#
# Script : test_service.sh						#
# Description : permet de tester si le service rtorrent d'un utilisateur#
#		passé en paramètre est actif ou non. Si non, le service	#
#		correspondant est relancé.				#
# Input : $1 - le nom d'utilisateur à tester				#
# Auteur : GorMsoN							#
#                                                                       #
#########################################################################

#Inclusion des variables globales
source default.conf

#Nom du service recherché
SERVICE="$1-rtorrent"
#Recherche si le service est actif ou non
TEST=$(ps aux | grep "$1" | grep SCREEN | tr -s " " | cut -d " " -f13)


if [ -z $TEST ]
then
        echo "Service Down..."
        echo "Redemarrage de $SERVICE"
        $BASEPATH/reboot_rtorrent.sh $1

        #pause pour laisser le temps au service de demarrer proprement
        sleep 3s

elif [ $SERVICE = $TEST ]
then

        echo "Service Up"

fi
