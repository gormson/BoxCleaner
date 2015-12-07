#!/bin/bash

#########################################################################
#									#
# Script : boxScanner.sh						#
# Description : Lance pour chaque utilisateurs dont la liste est passée #
#		en paramètre, le script user_boxScanner.sh listant les  #
#		écart entre rutorrent et leur /home/			#
# Input : $1 - Fichier contenant la liste des utilisateurs (1 user par 	#
#		ligne uniquement)					#
# Auteur : GorMsoN							#
#									#
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
	echo "Initilialisation des variables globales :"
        source default.conf
fi

#verification qu'il y a bien une variable passée en paramètre
if [ -z $1 ]
then
        echo "Aucune liste d'utilisateurs spécifié, arrêt de boxScanner.sh!"
        exit
fi

#Test d'intégrité de l'arborescence
$BASEPATH/$SCRIPTS/test_arbo.sh

echo "Chemin d'installation : $BASEPATH"
echo "Repertoire de travail : $TMP"
echo "Repertoire de stockage des rapports : $RAPPORTS"
echo "Nettoyage des Rapports Admin..."

#on vérifie si un rapport admin existe pour le supprimer
if [ -f $BASEPATH/$RAPPORTS/rapport_admin ]
then
	rm $BASEPATH/$RAPPORTS/rapport_admin
fi

#on vérifie si un cummul admin existe pour le supprimer
if [ -f $BASEPATH/$RAPPORTS/cummul_admin ]
then
        rm $BASEPATH/$RAPPORTS/cummul_admin
fi

echo "Début de l'analyse"
#on lance pour chaque utilisateur le script de listing des ecarts
for user in $(more $1)
do
	echo "$(date) : Traitement utilisateur $user..."
	$BASEPATH/user_boxScanner.sh "$user" > /dev/null 2>&1
done 

printf "Espace disque total gaspillé : " >> $BASEPATH/$RAPPORTS/rapport_admin
xargs --arg-file=$BASEPATH/$RAPPORTS/cummul_admin -0 --delimiter=\\n du -hsc | tail -1 | cut -f1 >> $BASEPATH/$RAPPORTS/rapport_admin

#Colorisation du rapport et mise à disposition sur une page html
echo "Création de la page rapport_admin.html"
ccze -h < $BASEPATH/$RAPPORTS/rapport_admin > $PATHHTML/rapport_admin.html

tail -1 $BASEPATH/$RAPPORTS/rapport_admin
echo "Fin de l'analyse..."
