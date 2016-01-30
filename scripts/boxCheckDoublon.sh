#!/bin/bash

#########################################################################
#                                                                       #
# Script : boxCheckDoublon.sh						#
# Description : Permet de vérifier si un même torrent est présent sur 	#
#		dans le rtorrent de plusieurs utilisateurs (doublon)	#
# Input : $1 - Liste des utilisateurs					#
#	  $2 - Arboresence à scanner					#
#	  $3 - Arboresence Plex à Scanner				#
# Auteur : GorMsoN                                                      #
#                                                                       #
#########################################################################

#Récupération du répertoire courant du script boxCheckDoublon.sh
CURRENTPATH=$(readlink -f "$(dirname "$0")")

cd "$CURRENTPATH" || exit
cd ..

if [ ! -f default.conf ]
then
        echo -e "${CRED}Impossible de charger les variables globales, le fichier default.conf n'existe pas${CEND}"
        exit
else
        #Inclusion des variables globales
	echo -e "${CBLUE}Initilialisation des variables globales${CEND}"
	# shellcheck disable=SC1091
        source default.conf
fi

#verification qu'il y a bien une variable passée en paramètre
if [ ! $# -eq 3 ]
then
	echo -e "${CRED}Nombre d'arguments boxCheckDoublon.sh non conforme, arrêt de boxCheckDoublon.sh!${CEND}"
	exit
elif [ ! -f "${1}" ]
then
        echo -e "${CRED}Le fichier liste d'utilisateurs spécifié n'existe pas, arrêt de boxCheckDoublon.sh!${CEND}"
        exit
elif [ ! -f "${2}" ]
then
        echo -e "${CRED}Le fichier d'arborescence spécifié n'existe pas, arrêt de boxCheckDoublon.sh!${CEND}"
        exit
elif [ ! -f "${3}" ]
then
        echo -e "${CRED}Le fichier d'arborescence Plex spécifié n'existe pas, arrêt de boxCheckDoublon.sh!${CEND}"
        exit
fi

#Test de l'arborescence des dossiers
"$BASEPATH"/"$SCRIPTS"/test_arbo.sh

if [ -f "$BASEPATH"/"$RAPPORTS"/torrents_user.list ]
then
	rm "$BASEPATH"/"$RAPPORTS"/torrents_user.list
fi

if [ -f "$BASEPATH"/"$RAPPORTS"/listing_fichiers.list ]
then
        rm "$BASEPATH"/"$RAPPORTS"/listing_fichiers.list
fi

if [ -f "$BASEPATH"/"$RAPPORTS"/doublons_plex.list ]
then
        rm "$BASEPATH"/"$RAPPORTS"/doublons_plex.list
fi

#Recuperation de l'ensemble des HASH des torrents presents dans rutorrent/rtorrent pour tous les utilisateurs
while IFS="" read -r utilisateur || [[ -n "$utilisateur" ]]
do
	#Test du bon demarrage du service rtorrent pour l'utilisateur
	"$BASEPATH"/"$SCRIPTS"/test_service.sh "$utilisateur"

	echo -e "${CBLUE}Extraction des torrents : ${CGREEN}$utilisateur...${CEND}"
	for hash_torrent in $(xmlrpc localhost/"$utilisateur" download_list | grep Index | cut -d\' -f2)
	do
	# Mise en tableau NomduTorrent:HashduTorrent:Utilisateur:CheminduTorrent
		printf "%b:" "$(xmlrpc localhost/"$utilisateur" d.get_name "$hash_torrent" | grep "String\:" | cut -c 10- | sed 's/.\{1\}$//g')"
		printf "%b:" "$hash_torrent"
		printf "%b:" "$utilisateur"
		TORRENTPATH=$(xmlrpc localhost/"$utilisateur" d.get_base_path "$hash_torrent" | grep "String\:" | cut -c 10- | sed 's/.\{1\}$//g')
		printf "%b\n" "$TORRENTPATH"

	done >> "$BASEPATH"/"$RAPPORTS"/torrents_user.list
done < "${1}"

echo -e "${CBLUE}Début de la vérification des doublons...${CEND}"
nb_torrents=0
while IFS="" read -r ligne || [[ -n "$ligne" ]]
do
	torrentname="$(echo -e $ligne | cut -d":" -f1)"
	userencours="$(echo -e $ligne | cut -d":" -f3)"
	printf "."
	nb_torrents=$(($nb_torrents+1))
	while IFS="" read -r chemin || [[ -n "$chemin" ]]
	do
		while IFS="" read -r utilisateur || [[ -n "$utilisateur" ]]
		do
			if [ $utilisateur != $userencours ]
			then
				if [ -f /home/"$utilisateur"/"$chemin"/"$torrentname" ] || [ -d /home/"$utilisateur"/"$chemin"/"$torrentname" ]
				then
					printf "Torrent en double pour %b : %b\n" "$utilisateur" "$ligne"
				fi
			fi

		done < "${1}"

	done < "${2}"

done < "$BASEPATH"/"$RAPPORTS"/torrents_user.list
printf "\n"
printf "%b torrents traités\n" "$nb_torrents"

echo -e "${CBLUE}Listing des fichiers de la bibliothèque Plex...${CEND}"
while IFS="" read -r cheminplex || [[ -n "$cheminplex" ]]
do
	while IFS="" read -r utilisateur || [[ -n "$utilisateur" ]]
	do
		echo -e "${CBLUE}Extraction Bibliothèque Plex : $utilisateur...${CEND}"
		find /home/"$utilisateur"/"$cheminplex"/ -type f >> "$BASEPATH"/"$RAPPORTS"/listing_fichiers.list
	done < "${1}"
done < "${3}"

echo -e "${CBLUE}Listing de l'ensemble des doublons...${CEND}"
#Parcours de l'ensemble des fichiers torrents
while IFS="" read -r fichier || [[ -n "$fichier" ]]
do
	#verification des chemins plex pour chaque utilisateurs
	while IFS="" read -r cheminplex || [[ -n "$cheminplex" ]]
	do
		#Pour chaque utilisateur
        	while IFS="" read -r utilisateur || [[ -n "$utilisateur" ]]
        	do
			chainetest=/home/"$utilisateur"/"$cheminplex"/"$(basename "$fichier")"

                	if [ -f "$chainetest" ] && [ "$chainetest" != "$fichier" ]
			then
				if [ -f "$BASEPATH"/"$TMP"/doublons_plex ]
				then
					#on Ajoute le doublon sans en créer un autre dans le listing
					if [ "$(grep -c "$fichier" "$BASEPATH"/"$TMP"/doublons_plex)" == 0 ] && [ "$(grep -c "$chainetest" "$BASEPATH"/"$TMP"/doublons_plex)" == 0 ]
					then
						printf "%b\n%b\n" "$fichier" "$chainetest" >> "$BASEPATH"/"$TMP"/doublons_plex
					fi

				else
					printf "%b\n%b\n" "$fichier" "$chainetest" >> "$BASEPATH"/"$TMP"/doublons_plex
				fi
			fi
        	done < "${1}"
	done < "${3}"

done < "$BASEPATH"/"$RAPPORTS"/listing_fichiers.list

#Recherche de l'ensemble des fichiers liés à l'indode du fichier
while IFS="" read -r fichier || [[ -n "$fichier" ]]
do

	find /home/ -inum $(ls -i "$fichier" | cut -d" " -f1) >> "$BASEPATH"/"$TMP"/doublonsplextmp

done < "$BASEPATH"/"$TMP"/doublons_plex

#On retire les chemins qui ne nous interessent pas.
comm -3 <(sort "$BASEPATH"/"$TMP"/doublons_plex) <(sort "$BASEPATH"/"$TMP"/doublonsplextmp) | cut -f2 > "$BASEPATH"/"$TMP"/doublons_plex.new

#On recherche les détails des fichiers dans la liste des torrents
while IFS="" read -r fichier || [[ -n "$fichier" ]]
do
	if [ $(fgrep -c "$fichier" "$BASEPATH"/"$RAPPORTS"/torrents_user.list) == 0 ]
	then
       		fgrep "$(dirname "$fichier")" "$BASEPATH"/"$RAPPORTS"/torrents_user.list
	else
       		fgrep "$fichier" "$BASEPATH"/"$RAPPORTS"/torrents_user.list
	fi

done < "$BASEPATH"/"$TMP"/doublons_plex.new > "$BASEPATH"/"$TMP"/doublons_plex.new2

sort "$BASEPATH"/"$TMP"/doublons_plex.new2 > "$BASEPATH"/"$RAPPORTS"/doublons_plex.list 

#Affichage des doublons détectés
numero=1
echo -e "${CRED}Liste des doublons détectés${CEND}"
printf "\n"
while IFS="" read -r ligne || [[ -n "$ligne" ]]
do
	echo -e "${CGREEN}$numero	- ${CBLUE}$(echo "$ligne" | cut -d":" -f2)	- ${CGREEN}$(echo "$ligne" | cut -d":" -f3)	- ${CBLUE}$(echo "$ligne" | cut -d":" -f1) ${CEND}"
	numero=$((numero+1))
done < "$BASEPATH"/"$RAPPORTS"/doublons_plex.list

rm "$BASEPATH"/"$TMP"/*
