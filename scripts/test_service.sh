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

#Récupération du répertoire courant du script test_service.sh
CURRENTPATH=$(readlink -f "$(dirname "$0")")

cd "$CURRENTPATH" || exit
cd ..

if [ ! -f default.conf ]
then
        echo "Impossible de charger les variables globales, le fichier default.conf n'existe pas"
        exit
else
	#Inclusion des variables globales
        source default.conf
fi

#verification qu'il y a bien une variable passée en paramètre
if [ -z "$1" ]
then
	echo "Aucun utilisateur spécifié, arrêt de test_service.sh!"
	exit
fi

#Nom du service recherché
SERVICE="$1-rtorrent"
#Recherche si le service est actif ou non
TEST=$(ps aux | grep "$1" | grep SCREEN | tr -s " " | cut -d " " -f13)

if [ -z "$TEST" ]
then
        echo "Service Down..."
        echo "Redemarrage de $SERVICE"
        "$BASEPATH"/"$SCRIPTS"/reboot_rtorrent.sh "$1"

        #pause pour laisser le temps au service de demarrer proprement
        sleep 3s

elif [ "$SERVICE" = "$TEST" ]
then

        echo "Service Up"

fi
