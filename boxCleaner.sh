#!/bin/bash

#########################################################################
#									#
# Script : boxCleaner.sh						#
# Description : Permet de nettoyer une Seedbox en mode guidé		#
#									#
# Auteur : GorMsoN							#
#                                                                       #
#########################################################################

#Récupération du répertoire courant du script test_service.sh
CURRENTPATH=$(readlink -f "$(dirname "$0")")

cd "$CURRENTPATH" || exit

if [ ! -f default.conf ]
then
        echo -e "Impossible de charger les variables globales, le fichier default.conf n'existe pas"
        exit
else
        #Inclusion des variables globales
	# shellcheck disable=SC1091
        source default.conf
fi

CHOIX="Temp"
while [ "$CHOIX" == "9" ]
do
clear
echo -e "${CRED}
                ____             ________
               / __ )____  _  __/ ____/ /__  ____ _____  ___  _____
              / __  / __ \| |/_/ /   / / _ \/ __ \`/ __ \/ _ \/ ___/
             / /_/ / /_/ />  </ /___/ /  __/ /_/ / / / /  __/ /
            /_____/\____/_/|_|\____/_/\___/\__,_/_/ /_/\___/_/

${CEND}"

	echo -e "${CBLUE}1 - Lancer un scan complet multiutilisateurs${CEND}"
	echo -e "${CBLUE}2 - Lancer un scan pour un utilisateur${CEND}"
	echo -e "${CBLUE}3 - Lister les torrents d'un utilisateur${CEND}"
	echo -e "${CBLUE}4 - Classer les torrents d'un utilisateur par date de dernier accès${CEND}"
 	echo -e "${CBLUE}5 - Effacer les fichiers en écart (nécessite un scan complet)${CEND}"
	echo -e "${CBLUE}6 - Tester si rtorrent/rutorrent est actif pour un utilisateur${CEND}"
	echo -e "${CBLUE}7 - Relancer le service rtorrent pour un utilisateur${CEND}"
	echo -e "${CBLUE}8 - Supprimer complétement un fichier/dossier (Hardlink compris)${CEND}"
	echo -e "${CBLUE}9 - Quitter BoxCleaner${CEND}"
	echo ""
	echo -e -n "${CYELLOW}>>> Selectionnez une option : ${CEND}"
	read -r CHOIX

case $CHOIX in
	1)
		if [ -f "$BASEPATH"/utilisateurs.list ] && [ -f "$BASEPATH"/repertoires.list ]
		then
			"$BASEPATH"/"$SCRIPTS"/boxScanner utilisateurs.list repertoires.list
		else
			if [ ! -f "$BASEPATH"/utilisateurs.list ]
			then
				echo -e "${CRED}Erreur : Le fichier utilisateurs.list n'existe pas!${CEND}"
			fi
			if [ ! -f "$BASEPATH"/repertoires.list ]
                        then
                                echo -e "${CRED}Erreur : Le fichier repertoires.list n'existe pas!${CEND}"
                        fi
		fi
		echo -e -n "${CYELLOW}Appuyez sur Entrer pour continuer...${CEND}"
                read
		;;
	2)
		echo -e -n "${CBLUE}Utilisateurs : ${CEND}"
		read -r UTILISATEUR
		if [ -d /home/"$UTILISATEUR" ] && [ -f "$BASEPATH"/repertoires.list ]
		then
			"$BASEPATH"/"$SCRIPTS"/user_boxScanner.sh "$UTILISATEUR" repertoires.list
		else
			if [ ! -f "$BASEPATH"/repertoires.list ]
                        then
                                echo -e "${CRED}Erreur : Le fichier repertoires.list n'existe pas!${CEND}"
                        fi
			if [ ! -d /home/"$UTILISATEUR" ]
			then
				echo -e "${CRED}Erreur : L'utilisateur ne semble pas exister! Pas de dossier /home/$UTILISATEUR${CEND}"
			fi
		fi
		echo -e -n "${CYELLOW}Appuyez sur Entrer pour continuer...${CEND}"
                read
		;;
	3)
                echo -e -n "${CBLUE}Utilisateurs : ${CEND}"
                read -r UTILISATEUR
                if [ -d /home/"$UTILISATEUR" ]
                then
 			"$BASEPATH"/"$SCRIPTS"/liste_torrents_user.sh "$UTILISATEUR"
		else
			if [ ! -d /home/"$UTILISATEUR" ]
                        then
                                echo -e "${CRED}Erreur : L'utilisateur ne semble pas exister! Pas de dossier /home/$UTILISATEUR${CEND}"
                        fi
		fi
		echo -e -n "${CYELLOW}Appuyez sur Entrer pour continuer...${CEND}"
                read
		;;
	4)
		echo -e -n "${CBLUE}Utilisateurs : ${CEND}"
		read -r UTILISATEUR
                if [ -d /home/"$UTILISATEUR" ]
                then
                        "$BASEPATH"/"$SCRIPTS"/user_boxLastAccess.sh "$UTILISATEUR"
                else
                        if [ ! -d /home/"$UTILISATEUR" ]
                        then
                                echo -e "${CRED}Erreur : L'utilisateur ne semble pas exister! Pas de dossier /home/$UTILISATEUR${CEND}"
                        fi
		fi
		echo -e -n "${CYELLOW}Appuyez sur Entrer pour continuer...${CEND}"
                read
		;;
	5)
		if [ -f "$BASEPATH"/"$RAPPORTS"/cummul_admin ]
		then
			echo -e "${CGREEN}Attention!! L'opération suivante va effacer l'ensemble des fichiers du listing cummul_admin${CEND}"
			echo -e -n "${CRED}Etes vous sûr de vouloir continuer? (O/n) ${CEND}"
			read -r OKSUPP
			if [ "$OKSUPP" == "O" ] || ["$OKSUPP" == "o" ]
			then
				echo -e "${CGREEN}Début de la suppression des fichiers...${CEND}"
				"$BASEPATH"/"$SCRIPTS"/boxEraser.sh "$BASEPATH"/"$RAPPORTS"/cummul_admin
				echo -e "${CGREEN}Fin de la suppression des fichiers...${CEND}"
			elif [ "$OKSUPP" == "N" ] || ["$OKSUPP" == "n" ]
			then
				echo -e "${CGREEN}Abandon de la suppression, sage décision Padawan${CEND}"
			else
				echo -e "${CRED}Erreur de saisie, les choix possibles sont (O, o, N ou n)${CEND}"
			fi
		else
			echo -e "${CRED}Le fichier cummul_admin n'existe pas, vous devez lancer un Scan Complet (Option 1)${CEND}"
		fi
		echo -e -n "${CYELLOW}Appuyez sur Entrer pour continuer...${CEND}"
                read
		;;
	6)
		echo -e -n "${CBLUE}Utilisateurs : ${CEND}"
                read -r UTILISATEUR
                if [ -d /home/"$UTILISATEUR" ]
                then
                        "$BASEPATH"/"$SCRIPTS"/test_service.sh "$UTILISATEUR"
                else
                        if [ ! -d /home/"$UTILISATEUR" ]
                        then
                                echo -e "${CRED}Erreur : L'utilisateur ne semble pas exister! Pas de dossier /home/$UTILISATEUR${CEND}"
                        fi
                fi
                echo -e -n "${CYELLOW}Appuyez sur Entrer pour continuer...${CEND}"
                read
		;;
	7)
		echo -e -n "${CBLUE}Utilisateurs : ${CEND}"
                read -r UTILISATEUR
                if [ -d /home/"$UTILISATEUR" ]
                then
                        "$BASEPATH"/"$SCRIPTS"/reboot_rtorrent.sh "$UTILISATEUR"
                else
                        if [ ! -d /home/"$UTILISATEUR" ]
                        then
                                echo -e "${CRED}Erreur : L'utilisateur ne semble pas exister! Pas de dossier /home/$UTILISATEUR${CEND}"
                        fi
                fi
                echo -e -n "${CYELLOW}Appuyez sur Entrer pour continuer...${CEND}"
                read
		;;
	8)
		echo -e -n "${CBLUE}Cible : ${CEND}"
                read -r CIBLE
		if [ -f "$CIBLE" ] || [ -d "$CIBLE" ]
		then
			OKSUPP="TEMP"
			echo -e "${CGREEN}Attention!! L'opération suivante va effacer définitivement le fichier ou dossier spécifé!!${CEND}"
                        echo -e -n "${CRED}Etes vous sûr de vouloir continuer? (O/n) ${CEND}"
                        read -r OKSUPP
                        if [ "$OKSUPP" == "O" ] || ["$OKSUPP" == "o" ]
                        then
                                echo -e "${CGREEN}Début de la suppression...${CEND}"
                                "$BASEPATH"/"$SCRIPTS"/hardlink_delete.sh "$CIBLE"
                                echo -e "${CGREEN}Fin de la suppression...${CEND}"
                        elif [ "$OKSUPP" == "N" ] || ["$OKSUPP" == "n" ]
                        then
                                echo -e "${CGREEN}Abandon de la suppression, sage décision Padawan${CEND}"
                        else
                                echo -e "${CRED}Erreur de saisie, les choix possibles sont (O, o, N ou n)${CEND}"
                        fi
		else
			printf "${CRED}L'élément suivant %b n'existe pas!\n${CEND}" "$CIBLE"
		fi
		echo -e -n "${CYELLOW}Appuyez sur Entrer pour continuer...${CEND}"
                read
                ;;
	9)
		echo -e "${CGREEN}BoxCleaner... ByeBye ;-)${CEND}"
		;;
	*)
		echo -e "${CRED}J'la connais pas cette option o_O${CEND}"
esac

done
