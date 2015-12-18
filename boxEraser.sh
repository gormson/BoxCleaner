#!/bin/bash

#########################################################################
#									#
# Script : boxEraser.sh							#
# Description : Permet de nettoyer la SeedBox à partir de la liste des	#
#		écarts identifiés par boxScanner.sh			#
# Input : $1 - fichier cummulant tous les fichiers en écarts généré par	#
#		le script boxScanner.					#
# Auteur : GorMsoN							#
#                                                                       #
#########################################################################

#Récupération du répertoire courant du script test_service.sh
CURRENTPATH=$(readlink -f "$(dirname "$0")")

cd "$CURRENTPATH" || exit

if [ ! -f default.conf ]
then
        echo -e "${CRED}Impossible de charger les variables globales, le fichier default.conf n'existe pas${CEND}"
        exit
else
        #Inclusion des variables globales
	# shellcheck disable=SC1091
        source default.conf
fi

#verification qu'il y a bien une variable passée en paramètre
if [ -z "$1" ]
then
        echo -e "${CRED}Aucun listing de fichier en paramètre, arrêt de boxEraser.sh!${CEND}"
        exit
fi


#On utilise le script de suppresion à partir de l'inode du fichier
#pourquoi l'inode, simplement pour gérer le fichier et surtout les hardlinks 
#et donc libérer vraiment l'espace

printf "${CGREEN}%s : Début du Nettoyage des fichiers orphelins...${CEND}" "$(date)"

while IFS="" read -r filetodelete || [[ -n "$filetodelete" ]]
do
	echo -e "${CGREEN}Traitement de $filetodelete.${CEND}"
        if [ -f "$filetodelete" ] || [ -d "$filetodelete" ]
        then
                "$BASEPATH"/"$SCRIPTS"/hardlink_delete "$filetodelete"
        else
               printf "${CRED}%s : $filetodelete n'est pas un fichier ou un dossier${CEND}" "$(date)"
        fi
done < "${1}"

printf "%s : Traitement de la liste de fichiers/dossiers terminée.\n" "$(date)" >> "$BASEPATH"/"$LOG"/boxEraser.log
printf "\n" >> "$BASEPATH"/"$LOG"/boxEraser.log


printf "${CGREEN}%s : Fin du Nettoyage des fichiers orphelins.${CEND}" "$(date)"
