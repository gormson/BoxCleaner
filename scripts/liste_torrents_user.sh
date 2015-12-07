#!/bin/bash

#Repertoires pas défauts utilisés par le script
BASEPATH="/home/rootgorm/maintenance"
DEBUG="debug"

#Verification que le service est bien lancé pour l'user concerné
$BASEPATH/test_service.sh $1

#On supprime le fichier de debug 
if [ -s $BASEPATH/$DEBUG/debug_$1.new ]
then
	rm $BASEPATH/$DEBUG/debug_$1.new
fi

#Recuperation de l'ensemble des HASH des torrents presents dans rutorrent/rtorrent pour un utilisateur
for hash_torrent in $(xmlrpc localhost/$1 download_list | grep Index | cut -d\' -f2)
do
	xmlrpc localhost/$1 d.get_base_path $hash_torrent | grep "String\:" | cut -d\' -f2 >> $BASEPATH/$DEBUG/debug_$1
done

#Suppression des lignes vides
sed -i '/^$/d' $BASEPATH/$DEBUG/debug_$1

#Nettoyage des caracteres echappes par xmlrpc en UTF8
while IFS="" read -r line || [[ -n "$line" ]]
do
        printf "%b\n" "${line}"

done < "$BASEPATH/$DEBUG/debug_$1" > $BASEPATH/$DEBUG/debug_$1.new

rm $BASEPATH/$DEBUG/debug_$1

#Affichage du rapport
more $BASEPATH/$DEBUG/debug_$1.new

