#!/bin/bash

#########################################################################
#									#
# Script : liste_torrents_user.sh					#
# Description : Listing des torrents actifs pour un utilisateur		#
# Input : $1 - le nom de l'utilisateur pour le listing			#
#									#
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
        echo -e "${CRED}Aucun utilisateur spécifié, arrêt de liste_torrents_user.sh!${CEND}"
        exit
fi

#Verification que le service est bien lancé pour l'user concerné
"$BASEPATH"/"$SCRIPTS"/test_service.sh "$1"

#On supprime le fichier de debug 
if [ -s "$BASEPATH"/"$DEBUG"/debug_"$1".new ]
then
	rm "$BASEPATH"/"$DEBUG"/debug_"$1".new
fi

echo -e "${CGREEN}Récupération de la liste des torrents${CEND}"
#Recuperation de l'ensemble des HASH des torrents presents dans rutorrent/rtorrent pour un utilisateur
for hash_torrent in $(xmlrpc localhost/"$1" download_list | grep Index | cut -d\' -f2)
do
	xmlrpc localhost/"$1" d.get_base_path "$hash_torrent" | grep "String\:" | cut -d\' -f2 >> "$BASEPATH"/"$DEBUG"/debug_"$1"
done

#Suppression des lignes vides
sed -i '/^$/d' "$BASEPATH"/"$DEBUG"/debug_"$1"

#Nettoyage des caracteres echappes par xmlrpc en UTF8
while IFS="" read -r line || [[ -n "$line" ]]
do
        printf "%b\n" "${line}"

done < "$BASEPATH/$DEBUG/debug_$1" > "$BASEPATH"/"$DEBUG"/debug_"$1".new

rm "$BASEPATH"/"$DEBUG"/debug_"$1"

echo -e "${CGREEN}Liste des torrents pour $1${CEND}"
echo ""
#Affichage du rapport
more "$BASEPATH"/"$DEBUG"/debug_"$1".new

