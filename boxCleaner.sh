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

#Récupération du répertoire courant du script test_service.sh
CURRENTPATH=$(readlink -f $(dirname $0))

cd $CURRENTPATH

if [ ! -f default.conf ]
then
        echo "Impossible de charger les variables globales, le fichier default.conf n'existe pas"
        exit
else
        #Inclusion des variables globales
        source default.conf
fi

#verification qu'il y a bien une variable passée en paramètre
if [ -z $1 ]
then
        echo "Aucun listing de fichier en paramètre, arrêt de boxCleaner.sh!"
        exit
fi


#On utilise le script de suppresion à partir de l'inode du fichier
#pourquoi l'inode, simplement pour gérer le fichier et surtout les hardlinks 
#et donc libérer vraiment l'espace

echo "$(date) : Début du Nettoyage des fichiers orphelins..."

while IFS="" read -r filetodelete || [[ -n "$filetodelete" ]]
do
        if [ -f "$filetodelete" ] || [ -d "$filetodelete" ]
        then
                $BASEPATH/$SCRIPTS/hardlink_delete "$filetodelete"
        else
                echo "$(date) : $filetodelete n'est pas un fichier ou un dossier"
        fi
done < ${1}

printf "$(date) : Traitement de la liste de fichiers/dossiers terminée.\n" >> $BASEPATH/$LOG/boxCleaner.log
printf "\n" >> $BASEPATH/$LOG/boxCleaner.log

echo "$(date) : Fin du Nettoyage des fichiers orphelins."
