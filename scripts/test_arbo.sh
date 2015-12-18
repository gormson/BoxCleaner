#!/bin/bash

#########################################################################
#									#
# Script : test_arbo.sh							#
# Description : Permet de tester si les dossiers nécessaires au		#
#		fonctionnement sont présent, si non, les dossiers sont	#
#		créés							#
#									#
# Auteur : GorMsoN							#
#                                                                       #
#########################################################################

#Récupération du répertoire courant du script test_arbo.sh
CURRENTPATH=$(readlink -f "$(dirname "$0")")

cd "$CURRENTPATH" || exit
cd ..

if [ ! -f default.conf ]
then
	echo "Impossible de charger les variables globales, le fichier default.conf n'existe pas"
	exit
else
	# shellcheck disable=SC1091
	source default.conf
fi


#Verification du dossier rapports
if [ ! -d "$BASEPATH"/"$RAPPORTS" ]
then
	echo -e "${CRED}Le dossier $RAPPORTS n'existe pas.${CEND}"
	echo -e "${CRED}Création du Dossier...${CEND}"
	mkdir "$BASEPATH"/"$RAPPORTS"
fi

#Verification du dossier log
if [ ! -d "$BASEPATH"/"$LOG" ]
then
        echo -e "${CRED}Le dossier $LOG n'existe pas.${CEND}"
        echo -e "${CRED}Création du Dossier...${CEND}"
        mkdir "$BASEPATH"/"$LOG"
fi

#Verification du dossier debug
if [ ! -d "$BASEPATH"/"$DEBUG" ]
then
        echo -e "${CRED}Le dossier $DEBUG n'existe pas.${CEND}"
        echo -e "${CRED}Création du Dossier...${CEND}"
        mkdir "$BASEPATH"/"$DEBUG"
fi

#Verification du dossier temporaire
if [ ! -d "$BASEPATH"/"$TMP" ]
then
        echo -e "${CRED}Le dossier $TMP n'existe pas.${CEND}"
        echo -e "${CRED}Création du Dossier...${CEND}"
        mkdir "$BASEPATH"/"$TMP"
fi

echo -e "${CGREEN}Fin du contrôle d'intégrité de $BASEPATH...${CEND}"
