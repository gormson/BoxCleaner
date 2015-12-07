#!/bin/bash

#########################################################################
#									#
# Script : boxCleaner.sh						#
# Description : Permet de nettoyer la SeedBox à partir de la liste des	#
#		écarts identifiés par boxScanner.sh			#
# Input : $1 - fichier cummulant tous les fichiers en écarts généré par	#
#		le script boxScanner.					#
# Auteur : GorMsoN							#
#                                                                       #
#########################################################################


#Inclusion des variables globales
source default.conf

#On utilise le script de suppresion à partir de l'inode du fichier
#pourquoi l'inode, simplement pour gérer le fichier et surtout les hardlinks 
#et donc libérer vraiment l'espace

echo "$(date) : Début du Nettoyage des fichiers orphelins..."

while IFS="" read -r filetodelete || [[ -n "$filetodelete" ]]
do
        $BASEPATH/$SCRIPTS/hardlink_delete "$filetodelete"
done < ${1}

printf "$(date) : Traitement de la liste de fichiers/dossiers terminée.\n" >> $BASEPATH/$LOG/boxCleaner.log
printf "\n" >> $BASEPATH/$LOG/boxCleaner.log

echo "$(date) : Fin du Nettoyage des fichiers orphelins."
