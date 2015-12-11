#!/bin/bash

#########################################################################
#                                                                       #
# Script : user_boxLastAccess.sh                                        #
# Description : Permet, pour un utilisateur de lister les torrents et de#
#               les classer par ordre de dernier accès                  #
# Input : $1 - Nom de l'utilisateur à traiter                           #
# Auteur : GorMsoN                                                      #
#                                                                       #
#########################################################################

#Récupération du répertoire courant du script test_service.sh
CURRENTPATH=$(readlink -f "$(dirname "$0")")

cd "$CURRENTPATH" || exit

if [ ! -f default.conf ]
then
        echo "Impossible de charger les variables globales, le fichier default.conf n'existe pas"
        exit
else
        #Inclusion des variables globales
        echo "Initilialisation des variables globales :"
        # shellcheck disable=SC1091
	source default.conf
fi

#verification qu'il y a bien une variable passée en paramètre
if [ ! $# -eq 1 ]
then
        echo "Nombre d'arguments user_boxLastAccess.sh non conforme, arrêt de user_boxLastAccess.sh!"
        exit
elif [ ! -d "/home/${1}" ]
then
        echo "L'utilisateur spécifié n'existe pas, arrêt de user_boxLastAccess.sh!"
        exit
fi

#Test de l'arborescence des dossiers
"$BASEPATH"/"$SCRIPTS"/test_arbo.sh

#Test du bon demarrage du service rtorrent pour l'utilisateur
"$BASEPATH"/"$SCRIPTS"/test_service.sh "$1"

#Recuperation de l'ensemble des HASH des torrents presents dans rutorrent/rtorrent pour un utilisateur
for hash_torrent in $(xmlrpc localhost/"$1" download_list | grep Index | cut -d\' -f2)
do
      	IDTEMPS=$(xmlrpc localhost/"$1" f.get_last_touched "$hash_torrent":f0 | tail -1 | cut -d " " -f3)
	IDTEMPS=$(echo "scale=6; $IDTEMPS/1000000" | bc)
	LASTTOUCHED=$(date --date=@"$IDTEMPS" "+%Y-%m-%d %H:%M:%S")

	printf "%s " "$LASTTOUCHED" >> "$BASEPATH"/"$TMP"/filenamerutorrent_"$1"
	printf "%b\n" "$(xmlrpc localhost/"$1" d.get_name "$hash_torrent" | grep "String\:" | cut -d\' -f2)" >> "$BASEPATH"/"$TMP"/filenamerutorrent_"$1"

done

#Au cas où on supprime les lignes vide du fichier
sed -i '/^$/d' "$BASEPATH"/"$TMP"/filenamerutorrent_"$1"
#sed -i '/^$/d' $BASEPATH/$TMP/lasttouched_$1


