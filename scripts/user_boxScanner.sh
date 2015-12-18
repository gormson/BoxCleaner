#!/bin/bash


#########################################################################
#                                                                       #
# Script : user_boxScanner.sh						#
# Description : Permet la préparation à la maintenance rutorrent/torrent#
#		pour pour 1 utilisateur donné				#
# Input : $1 - Nom de l'utilisateur à traiter				#
#	  $2 - Arboresence à scanner					#
# Auteur : GorMsoN                                                      #
#                                                                       #
#########################################################################

#Récupération du répertoire courant du script test_service.sh
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
if [ ! $# -eq 2 ]
then
	echo -e "${CRED}Nombre d'arguments user_boxScanner.sh non conforme, arrêt de user_boxScanner.sh!${CEND}"
	exit
elif [ ! -d "/home/${1}" ]
then
        echo -e "${CRED}L'utilisateurs spécifié n'existe pas, arrêt de user_boxScanner.sh!${CEND}"
        exit
elif [ ! -f "${2}" ]
then
        echo -e "${CRED}Le fichier d'arborescence spécifié n'existe pas, arrêt de user_boxScanner.sh!${CEND}"
        exit
fi

#Test de l'arborescence des dossiers
"$BASEPATH"/"$SCRIPTS"/test_arbo.sh

#Test du bon demarrage du service rtorrent pour l'utilisateur
"$BASEPATH"/"$SCRIPTS"/test_service.sh "$1"

echo -e "${CBLUE}Extraction de la liste des torrents${CEND}"

#Recuperation de l'ensemble des HASH des torrents presents dans rutorrent/rtorrent pour un utilisateur
for hash_torrent in $(xmlrpc localhost/"$1" download_list | grep Index | cut -d\' -f2)
do
	xmlrpc localhost/"$1" d.get_base_path "$hash_torrent" | grep "String\:" | cut -d\' -f2 >> "$BASEPATH"/"$TMP"/filepathrutorrent_"$1"
done

#Au cas où on supprime les lignes vide du fichier
sed -i '/^$/d' "$BASEPATH"/"$TMP"/filepathrutorrent_"$1"

echo -e "${CBLUE}Extraction du contenu des répertoires${CEND}"
#Liste des telechargements pour un utilisateur suivant arbo utilisateur
while IFS="" read -r line || [[ -n "$line" ]]
do
        printf "%b\n" "/home/${1}/${line}" >> "$BASEPATH"/"$TMP"/filtre_arbo_"$1"
        ls -d /home/"${1}"/"$line"/*
done < "${2}" > "$BASEPATH"/"$TMP"/filepathserver_"$1"_tmp

echo -e "${CBLUE}Comparaison contenu rutorrent vs server${CEND}"
comm -3 <(sort "$BASEPATH"/"$TMP"/filepathserver_"$1"_tmp) <(sort tmp/filtre_arbo_"$1") | cut -f1 | sed '/^$/d' > "$BASEPATH"/"$TMP"/filepathserver_"$1"
rm "$BASEPATH"/"$TMP"/filtre_arbo_"$1"
rm "$BASEPATH"/"$TMP"/filepathserver_"$1"_tmp

#Nettoyage des caracteres echappes par xmlrpc en UTF8
while IFS="" read -r line || [[ -n "$line" ]]
do
        printf "%b\n" "${line}"

done < "$BASEPATH"/"$TMP"/filepathrutorrent_"$1" > "$BASEPATH"/"$TMP"/filepathrutorrent_"$1".new


#Verification du contenu du repertoire de telechargement /home/USER/torrents
{
	printf "Debut du rapport : %s\n" "$(date)"
	printf "\n"
	printf "CONTENU DU REPERTOIRE /home/%s/torrents/ :\n" "$1"
	printf "________________________________________________\n"
	printf "\n"
	printf "Contenu du dossier de téléchargement torrents\n" 
	printf "\n"

	ls -d /home/"$1"/torrents/*

	printf "\n"

	#Comparaison des fichiers dans rutorrent et les telechargements enregistres
	printf "LISTE DES ECARTS ENTRE RUTORRENT ET /home/%s/torrents/ :\n" "$1"
	printf "______________________________________________________________\n"
} >> "$BASEPATH"/"$RAPPORTS"/rapport_"$1"

#Creation du fichier de differences entre rutorrent et les telechargements
comm -3 <(sort "$BASEPATH"/"$TMP"/filepathrutorrent_"$1".new)  <(sort "$BASEPATH"/"$TMP"/filepathserver_"$1") > "$BASEPATH"/"$TMP"/difference_"$1"

#On liste les torrents sans fichiers associés
{
	printf "\n"
	printf "Liste des torrents dans rutorrent sans fichiers attachés dans /home/%s/torrents/\n" "$1"
	printf "\n"

	#On récupère la première colonne du fichier de comparaison
	#Colonne 1 = Torrents présents dans rutorrent mais sans fichiers Associés
	cut -f1 "$BASEPATH"/"$TMP"/difference_"$1" | grep '.'
	printf "\n"
	printf "Liste des fichiers dans /home/%s/torrents/ sans torrents attachés dans rutorrent\n" "$1"
	printf "\n"
} >> "$BASEPATH"/"$RAPPORTS"/rapport_"$1"

#On récupère la deuxième colonne du fichier de comparaison
#Colonne 2 = Fichiers présents dans l'arboresence mais sans lien dans rutorrent
#Avant de les exporter, on les place dans un fichier pour connaître la taille correspondante
cut -f2 "$BASEPATH"/"$TMP"/difference_"$1" | grep '.' > "$BASEPATH"/"$TMP"/listefichiers_"$1"

#Creation du rapport admin
printf "Liste des fichiers à supprimer pour %s\n" "$1" >> "$BASEPATH"/"$RAPPORTS"/rapport_admin
{
	xargs --arg-file="$BASEPATH"/"$TMP"/listefichiers_"$1" -0 --delimiter=\\n du -hsc
	printf "\n"
} >> "$BASEPATH"/"$RAPPORTS"/rapport_admin

#on exporte la liste des fichiers dans un fichier de cumul
more "$BASEPATH"/"$TMP"/listefichiers_"$1" >> "$BASEPATH"/"$RAPPORTS"/cummul_admin

#Récupération de la taille de chaques fichier et somme de l'ensemble
{
	xargs --arg-file="$BASEPATH"/"$TMP"/listefichiers_"$1" -0 --delimiter=\\n du -hsc
	printf "\n"
} >> "$BASEPATH"/"$RAPPORTS"/rapport_"$1"

#Recuperation de la liste des torrents et classement par date de dernier accès
"$BASEPATH"/"$SCRIPTS"/user_boxLastAccess.sh "$1"
{
	printf "TORRENTS ACTIFS CLASSES PAR DATE DE DERNIER ACCES :\n"
	printf "___________________________________________________\n\n"
	more "$BASEPATH"/"$TMP"/filenamerutorrent_"$1" | sort

	printf "Fin du rapport : %s\n" "$(date)" >> "$BASEPATH"/"$RAPPORTS"/rapport_"$1"
} >> "$BASEPATH"/"$RAPPORTS"/rapport_"$1"
#Suppression des fichiers intermediaires
rm "$BASEPATH"/"$TMP"/*
echo -e "${CBLUE}Suppression des fichiers temporaires.${CEND}"

#Colorisation du rapport et mise à disposition sur une page html
ccze -h < "$BASEPATH"/"$RAPPORTS"/rapport_"$1" > "$PATHHTML"/rapport_"$1".html
echo -e "${CGREEN}Rapport utilisateur HTML généré : $PATHHTML/rapport_$1.html${CEND}"

#Et on affiche le rapport... for fun
more "$BASEPATH"/"$RAPPORTS"/rapport_"$1"
