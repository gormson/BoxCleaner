#!/bin/bash

#########################################################################
#									#
# Script : boxScanner.sh						#
# Description : Lance pour chaque utilisateurs dont la liste est passée #
#		en paramètre, le script user_boxScanner.sh listant les  #
#		écart entre rutorrent et leur /home/			#
# Input : $1 - Fichier contenant la liste des utilisateurs (1 user par 	#
#		ligne uniquement)					#
#	  $2 - Fichier contenant l'arborescence à parcourir pour les 	#
#		différents users
# Auteur : GorMsoN							#
#									#
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
	# shellcheck disable=SC1091
	source default.conf
	echo -e "${CRED}Initilialisation des variables globales${CEND}"
fi

#verification qu'il y a bien une variable passée en paramètre
if [ -z "$1" ]
then
        echo -e "${CRED}Aucune liste d'utilisateurs spécifié, arrêt de boxScanner.sh!${CEND}"
        exit
fi

#verification qu'il y a bien une variable passée en paramètre
if [ ! $# -eq 2 ]
then
        echo -e "${CRED}Nombre d'arguments user_boxScanner.sh non conforme, arrêt de boxScanner.sh!${CEND}"
        exit
elif [ ! -f "${1}" ]
then
        echo -e "${CRED}La liste d'utilisateurs spécifié n'existe pas, arrêt de boxScanner.sh!${CEND}"
        exit
elif [ ! -f "${2}" ]
then
        echo -e "${CRED}Le fichier d'arborescence spécifié n'existe pas, arrêt de boxScanner.sh!${CEND}"
        exit
fi

#Test d'intégrité de l'arborescence
"$BASEPATH"/"$SCRIPTS"/test_arbo.sh

echo -e "${CBLUE}Chemin d'installation : $BASEPATH${CEND}"
echo -e "${CBLUE}Repertoire de travail : $TMP${CEND}"
echo -e "${CBLUE}Repertoire de stockage des rapports : $RAPPORTS${CEND}"
echo -e "${CBLUE}Nettoyage des Rapports Admin...${CEND}"

#on vérifie si un rapport admin existe pour le supprimer
if [ -f "$BASEPATH"/"$RAPPORTS"/rapport_admin ]
then
	rm "$BASEPATH"/"$RAPPORTS"/rapport_admin
fi

#on vérifie si un cummul admin existe pour le supprimer
if [ -f "$BASEPATH"/"$RAPPORTS"/cummul_admin ]
then
        rm "$BASEPATH"/"$RAPPORTS"/cummul_admin
fi

echo -e "${CBLUE}Début de l'analyse${CEND}"
#on lance pour chaque utilisateur le script de listing des ecarts
for user in $(more "$1")
do
	printf "${CYELLOW}%s : Traitement utilisateur %s...\n${CEND}" "$(date)" "$user"
	"$BASEPATH"/user_boxScanner.sh "$user" "${2}" > /dev/null 2>&1

done 

{
	printf "Espace disque total gaspillé : "
	xargs --arg-file="$BASEPATH"/"$RAPPORTS"/cummul_admin -0 --delimiter=\\n du -hsc | tail -1 | cut -f1
} >> "$BASEPATH"/"$RAPPORTS"/rapport_admin

#Colorisation du rapport et mise à disposition sur une page html
echo -e "${CBLUE}Création de la page rapport_admin.html${CEND}"
ccze -h < "$BASEPATH"/"$RAPPORTS"/rapport_admin > "$PATHHTML"/rapport_admin.html

tail -1 "$BASEPATH"/"$RAPPORTS"/rapport_admin
echo -e "${CGREEN}Fin de l'analyse...${CEND}"
