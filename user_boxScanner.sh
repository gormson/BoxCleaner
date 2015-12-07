#!/bin/bash


#########################################################################
#                                                                       #
# Script : user_boxScanner.sh						#
# Description : Permet la préparation à la maintenance rutorrent/torrent#
#		pour pour 1 utilisateur donné				#
# Input : $1 - Nom de l'utilisateur à traiter				#
# Auteur : GorMsoN                                                      #
#                                                                       #
#########################################################################

#Inclusion des variables locales
source default.conf

#Test du bon demarrage du service rtorrent pour l'utilisateur
$BASEPATH/$SCRIPTS/test_service.sh $1

#Recuperation de l'ensemble des HASH des torrents presents dans rutorrent/rtorrent pour un utilisateur
for hash_torrent in $(xmlrpc localhost/$1 download_list | grep Index | cut -d\' -f2)
do
	xmlrpc localhost/$1 d.get_base_path $hash_torrent | grep "String\:" | cut -d\' -f2 >> $BASEPATH/$TMP/filepathrutorrent_$1
done

#Au cas où on supprime les lignes vide du fichier
sed -i '/^$/d' $BASEPATH/$TMP/filepathrutorrent_$1

#Liste des telechargements pour un utilisateur
ls -d /home/$1/torrents/tv/* > $BASEPATH/$TMP/filepathserver_$1
ls -d /home/$1/torrents/movie/* >> $BASEPATH/$TMP/filepathserver_$1
ls -d /home/$1/torrents/other/* >> $BASEPATH/$TMP/filepathserver_$1

#Nettoyage des caracteres echappes par xmlrpc en UTF8
while IFS="" read -r line || [[ -n "$line" ]]
do
        printf "%b\n" "${line}"

done < "$BASEPATH/$TMP/filepathrutorrent_$1" > $BASEPATH/$TMP/filepathrutorrent_$1.new

dateheure=$(date)

#Verification du contenu du repertoire de telechargement /home/USER/torrents
printf "Debut du rapport : $dateheure\n " > $BASEPATH/$RAPPORTS/rapport_$1
printf "\n" >> $BASEPATH/$RAPPORTS/rapport_$1
printf "CONTENU DU REPERTOIRE /home/$1/torrents/ :\n" >> $BASEPATH/$RAPPORTS/rapport_$1
printf "________________________________________________\n" >> $BASEPATH/$RAPPORTS/rapport_$1
printf "\n" >> $BASEPATH/$RAPPORTS/rapport_$1
printf "Le contenu type doit être composé de 3 dossiers uniquement : movie, tv et other\n" >> $BASEPATH/$RAPPORTS/rapport_$1
printf "\n" >> $BASEPATH/$RAPPORTS/rapport_$1

ls -d /home/$1/torrents/* >> $BASEPATH/$RAPPORTS/rapport_$1

printf "\n" >> $BASEPATH/$RAPPORTS/rapport_$1

#Comparaison des fichiers dans rutorrent et les telechargements enregistres
printf "LISTE DES ECARTS ENTRE RUTORRENT ET /home/$1/torrents/ :\n" >> $BASEPATH/$RAPPORTS/rapport_$1
printf "______________________________________________________________\n" >> $BASEPATH/$RAPPORTS/rapport_$1

#Creation du fichier de differences entre rutorrent et les telechargements
comm -3 <(sort $BASEPATH/$TMP/filepathrutorrent_$1.new)  <(sort $BASEPATH/$TMP/filepathserver_$1) > $BASEPATH/$TMP/difference_$1

#On liste les torrents sans fichiers associés
printf "\n" >> $BASEPATH/$RAPPORTS/rapport_$1
printf "Liste des torrents dans rutorrent sans fichiers attachés dans /home/$1/torrents/\n" >> $BASEPATH/$RAPPORTS/rapport_$1
printf "\n" >> $BASEPATH/$RAPPORTS/rapport_$1

#On récupère la première colonne du fichier de comparaison
#Colonne 1 = Torrents présents dans rutorrent mais sans fichiers Associés
cut -f1 $BASEPATH/$TMP/difference_$1 | grep '.' >> $BASEPATH/$RAPPORTS/rapport_$1
printf "\n" >> $BASEPATH/$RAPPORTS/rapport_$1
printf "Liste des fichiers dans /home/$1/torrents/ sans torrents attachés dans rutorrent\n" >> $BASEPATH/$RAPPORTS/rapport_$1
printf "\n" >> $BASEPATH/$RAPPORTS/rapport_$1

#On récupère la deuxième colonne du fichier de comparaison
#Colonne 2 = Fichiers présents dans l'arboresence mais sans lien dans rutorrent
#Avant de les exporter, on les place dans un fichier pour connaître la taille correspondante
cut -f2 $BASEPATH/$TMP/difference_$1 | grep '.' > $BASEPATH/$TMP/listefichiers_$1

#Creation du rapport admin
printf "Liste des fichiers à supprimer pour $1\n" >> $BASEPATH/$RAPPORTS/rapport_admin
xargs --arg-file=$BASEPATH/$TMP/listefichiers_$1 -0 --delimiter=\\n du -hsc >> $BASEPATH/$RAPPORTS/rapport_admin
printf "\n" >> $BASEPATH/$RAPPORTS/rapport_admin

#on exporte la liste des fichiers dans un fichier de cumul
more $BASEPATH/$TMP/listefichiers_$1 >> $BASEPATH/$RAPPORTS/cummul_admin  

#Récupération de la taille de chaques fichier et somme de l'ensemble
xargs --arg-file=$BASEPATH/$TMP/listefichiers_$1 -0 --delimiter=\\n du -hsc >> $BASEPATH/$RAPPORTS/rapport_$1
printf "\n" >> $BASEPATH/$RAPPORTS/rapport_$1

dateheure=$(date)
printf "Fin du rapport : $dateheure\n" >> $BASEPATH/$RAPPORTS/rapport_$1

#Suppression des fichiers intermediaires
rm $BASEPATH/$TMP/*

#Colorisation du rapport et mise à disposition sur une page html
ccze -h < $BASEPATH/$RAPPORTS/rapport_$1 > $PATHHTML/rapport_$1.html

#Et on affiche le rapport... for fun
more $BASEPATH/$RAPPORTS/rapport_$1
