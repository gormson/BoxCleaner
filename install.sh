#!/bin/bash

#Répertoire d'installation par défaut
CHEMIN="/opt"
#Chemin d'installation complet
BASEPATH="$CHEMIN"/"boxCleaner"
#Répertoire des fichiers de configuration Nginx"
NGINX="/etc/nginx/sites-enabled"
#Repertoire de stockage des rapports html
LOGSERVER="/var/www/rutorrent/logserver"
RUTORRENT="/var/www/rutorrent"

# variables de couleurs
CSI="\033["
CEND="${CSI}0m"
CRED="${CSI}1;31m"
CGREEN="${CSI}1;32m"
CYELLOW="${CSI}1;33m"
CBLUE="${CSI}1;34m"

clear
echo -e "${CRED}
                ____             ________
               / __ )____  _  __/ ____/ /__  ____ _____  ___  _____
              / __  / __ \| |/_/ /   / / _ \/ __ \`/ __ \/ _ \/ ___/
             / /_/ / /_/ />  </ /___/ /  __/ /_/ / / / /  __/ /
            /_____/\____/_/|_|\____/_/\___/\__,_/_/ /_/\___/_/

${CEND}"

echo -e -n "${CBLUE}Vous allez installer BoxCleaner, voulez-vous continuer (O/n)? ${CEND}"
read -r choix

if [[ ( "$choix" != "o" && "$choix" != "O" ) && ( "$choix" != "n" && "$choix" != "N" ) ]]
then
	echo -e -n "${CRED}Erreur de saisie, choix possibles : o/O/n/N${CEND}"
	read -r choix

	if [[ ( "$choix" != "o" && "$choix" != "O" ) && ( "$choix" != "n" && "$choix" != "N" ) ]]
	then
		echo -e "${CRED}Là vaut mieux s'arrêter...${CEND}"
		echo -e "${CRED}Fin de l'installation de BoxCleaner${CEND}"
		exit
	fi
else
	if [ "$choix" == "n" ] || [ "$choix" == "N" ]
	then
		echo -e "${CRED}Arrêt de l'installation de BoxCleaner${CEND}"
	        exit
	elif [ "$choix" == "o" ] || [ "$choix" == "O" ]
	then
		echo ""
		echo -e "${CGREEN}Installation de LibXMLRPC...${CEND}"
		apt-get install libxmlrpc-core-c3-dev -y

		echo ""
		echo -e "${CGREEN}Installation CCZE...${CEND}"
		apt-get install ccze -y

		echo ""
		CHEMIN="temp"
		while [ ! -d "$CHEMIN" ]
		do
			echo -e -n "${CBLUE}Entrez le dossier où doit être installé BoxCleaner (ex /votre/dossier/boxCleaner) ou laissez vide ($BASEPATH par defaut) : ${CEND}"
			read -r CHEMIN
			if [ -z "$CHEMIN" ]
			then
				CHEMIN=$BASEPATH
				echo -e "${CRED}Le dossier va être créé"
				mkdir "$CHEMIN" || exit

			elif [ ! -d "$CHEMIN" ]
			then
				echo -e "${CRED}Le chemin saisi ($CHEMIN) n'existe pas!${CEND}"
				echo -e "${CRED}Le dossier va être créé"
				mkdir "$CHEMIN" || exit
				#echo -e "${CRED}Erreur sur MKDIR, Fin de l'installation${CEND}"
			fi
		done

		#On recopie le dossier depuis /tmp/ vers /opt/ OU le chemin personnalisé
		echo ""
		echo -e "${CBLUE}Recopie du Répertoire boxCleaner${CEND}"
		echo -e "${CYELLOW}cp -r ../BoxCleaner $CHEMIN${CEND}"
		cp -r ../BoxCleaner/* "$CHEMIN"

                echo ""
                echo -e "${CBLUE}Recopie du .git et .gitingore${CEND}"
                echo -e "${CYELLOW}cp -r ../BoxCleaner/.git* $CHEMIN${CEND}"
                cp -r ../BoxCleaner/.git* "$CHEMIN"

		#On rend exécutable les scripts
		echo ""
		echo -e "${CBLUE}Passage des scripts en executables${CEND}"
		echo -e "${CYELLOW}chmod +x $CHEMIN/*.sh && chmod +x $CHEMIN/scripts/*.sh{CEND}"
		chmod +x "$CHEMIN"/*.sh && chmod +x "$CHEMIN"/scripts/*.sh

		#Création de la liste des utilisateurs
		PSEUDO="temp"

		echo ""
		echo -e "${CBLUE}Vérification des doublons${CEND}"
		if  [ ! -f "$CHEMIN"/utilisateurs.list ]
		then
			touch "$CHEMIN"/utilisateurs.list
		else 
			echo -e "${CRED}Un fichier utilisateurs.list existe déjà!${CEND}"
			echo -e "${CRED}Le fichier va être mis de côté (utilisateurs_$(date "+%Y%m%d_%H%M%S").bak)${CEND}"
			mv "$CHEMIN"/utilisateurs.list "$CHEMIN"/utilisateurs_"$(date "+%Y%m%d_%H%M%S")".bak
			touch "$CHEMIN"/utilisateurs.list
		fi

		#Création de la liste des répertoires
		if  [ ! -f "$CHEMIN"/repertoires.list ]
                then
		        touch "$CHEMIN"/repertoires.list
                else
                        echo -e "${CRED}Un fichier repertoires.list existe déjà!${CEND}"
                        echo -e "${CRED}Le fichier va être mis de côté (repertoires_$(date "+%Y%m%d_%H%M%S").bak)${CEND}"
                        mv "$CHEMIN"/repertoires.list "$CHEMIN"/repertoires_$(date "+%Y%m%d_%H%M%S").bak
                        touch "$CHEMIN"/repertoires.list
                fi

                #Création de la liste des répertoires_plex
                if  [ ! -f "$CHEMIN"/repertoires_plex.list ]
                then
                        touch "$CHEMIN"/repertoires_plex.list
                else
                        echo -e "${CRED}Un fichier repertoires_plex.list existe déjà!${CEND}"
                        echo -e "${CRED}Le fichier va être mis de côté (repertoires_plex_$(date "+%Y%m%d_%H%M%S").bak)${CEND}"
                        mv "$CHEMIN"/repertoires_plex.list "$CHEMIN"/repertoires_plex_$(date "+%Y%m%d_%H%M%S").bak
                        touch "$CHEMIN"/repertoires_plex.list
                fi

		#Création du fichier de conf Nginx
		if [ ! -f "$NGINX"/boxCleaner.conf ]
		then
			touch "$NGINX"/boxCleaner.conf
			{
				printf "server {\n"
        			printf "	listen      80;\n"
        			printf " 	server_name localhost;\n"
			} >> "$NGINX"/boxCleaner.conf
		else
			echo -e "${CRED}Un fichier boxCleaner.conf existe déjà!${CEND}"
			echo -e "${CRED}Le fichier va être mis de côté (boxCleaner_$(date "+%Y%m%d_%H%M%S").bak)${CEND}"
			mv "$NGINX"/boxCleaner.conf "$NGINX"/boxCleaner_$(date "+%Y%m%d_%H%M%S").bak
			touch "$NGINX"/boxCleaner.conf
                        {
                                printf "server {\n"
                                printf "        listen      80;\n"
                                printf "        server_name localhost;\n"
                        } >> "$NGINX"/boxCleaner.conf
		fi

		echo ""
		echo -e "${CBLUE}Création de la liste des utilisateurs...${CEND}"
		while [ ! -z "$PSEUDO" ]
		do
			printf "\n"
			echo -e -n "${CGREEN}Pseudo (Vide pour arrêter):${CEND}"
			read -r PSEUDO

			#Vérification de la présence du dossier utilisateur
			if [ -z "$PSEUDO" ]
			then
				echo -e "${CGREEN}Fin de l'enregistrement des utilisateurs${CEND}"
			elif [ ! -d "/home/$PSEUDO" ]
			then
				echo -e "${CRED}Aucun dossier /home/$PSEUDO détecté : ATTENTION!${CEND}"
				echo -e "${CRED}L'utilisateur devra être ajouté manuellement.${CEND}"
				echo -e "${CRED}Le fichier boxCleaner.conf devra être renseigné manuellement.${CEND}"
			else
				echo -e "${CGREEN}>>> Dossier /home/$PSEUDO/ : OK${CEND}"
				echo -e "${CGREEN}>>> Ajout de l'utilisateur à utilisateurs.list${CEND}"
				printf "%b\n" "$PSEUDO" >> $CHEMIN/utilisateurs.list

				#on verifie que rtorrent de l'utilisateur est configuré avec scgi_port
				if [ ! -f "/home/$PSEUDO/.rtorrent.rc" ]
				then
					echo -e "${CRED}Aucun fichier /home/$PSEUDO/.rtorrent.rc détecté : ATTENTION!${CEND}"
					echo -e "${CRED}Impossible d'ajouter le bloc utilisateur au fichier boxCleaner.conf Nginx${CEND}"
				else
					echo -e "${CGREEN}>>> Fichier /home/$PSEUDO/.rtorrent.rc : OK${CEND}"
					printf "${CGREEN}>>> Port SCGI trouvé pour %s : %s\n${CEND}" "$PSEUDO" $(more /home/$PSEUDO/.rtorrent.rc | grep scgi_port | cut -d " " -f3 | cut -d ":" -f2)
					echo -e "${CGREEN}>>> Ecriture du fichier boxCleaner.conf"
					{
						printf "	location /%s {\n" "$PSEUDO"
						printf "		include scgi_params;\n"
						printf "		scgi_pass %s;\n" "$(more /home/$PSEUDO/.rtorrent.rc | grep scgi_port | cut -d " " -f3)"
						printf "	}\n"
					} >> $NGINX/boxCleaner.conf

				fi
			fi

		done

		#on ferme l'accolade du fichier nginx
		printf "	}" >> $NGINX/boxCleaner.conf

		echo -e "${CBLUE}Restart Nginx pour prise en compte du fichier boxCleaner.conf${CEND}"
		service nginx restart

		DOSSIER="temp"
		echo ""
		echo -e "${CBLUE}Création de la liste des répertoires...${CEND}"
		echo -e "${CRED}Renseignez les répertoires où sont téléchargés les torrents et devant être scannés${CEND}"
		echo -e "${CRED}Si un répertoire n'est pas renseigné, il ne sera pas scanné et pourra donc, à tort, remonter des écarts${CEND}"
		echo -e "${CYELLOW}Nom du dossier de téléchargement dans /home/user/, comme par exemple : ${CEND}"
		echo -e "${CYELLOW}	Pour prendre en compte /home/user/torrents/ 	rentrez torrents${CEND}"
		echo -e "${CYELLOW}	Pour prendre en compte /home/user/torrents/tv/	rentrez torrents/tv${CEND}"
                while [ ! -z "$DOSSIER" ]
                do
                        printf "\n"
			echo -e -n "${CGREEN} Dossier (Vide pour arrêter): ${CEND}"
                        read -r DOSSIER

                        #Vérification de la présence du dossier specifié par l'utilisateur
                        if [ -z "$DOSSIER" ]
                        then
                                echo -e "${CBLUE}Fin de l'enregistrement des répertoires${CEND}"
                        elif [ ! -d "/home/$(head -1 $CHEMIN/utilisateurs.list)/$DOSSIER" ]
			then
				echo -e "${CRED}>>> Le dossier /home/$(head -1 $CHEMIN/utilisateurs.list)/$DOSSIER n'existe pas!${CEND}"
				echo -e "${CRED}>>> Dossier non ajouté à repertoires.list${CEND}"
			else
				#pour que le script boxScanner fonctionne correctement, il ne doit pas y avoir de / à la fin 
				if [ "${DOSSIER: -1}" = "/" ]
				then
					printf "${CGREEN}>>> Dossier %b : OK${CEND}\n" "${DOSSIER%/}"
					printf "%b\n" "${DOSSIER%/}" >> $CHEMIN/repertoires.list
				else
					echo -e "${CGREEN}>>> Dossier $DOSSIER : OK${CEND}"
					printf "%b\n" "$DOSSIER" >> $CHEMIN/repertoires.list
				fi
			fi
		done

		DOSSIER="temp"
		echo ""
		echo -e "${CBLUE}Création de la liste des répertoires Plex...${CEND}"
		echo -e "${CRED}Renseignez les répertoires où sont stockés les fichiers indéxés par Plex et devant être scannés${CEND}"
		echo -e "${CYELLOW}Nom du dossier Plex dans /home/user/, comme par exemple : ${CEND}"
		echo -e "${CYELLOW}	Pour prendre en compte /home/user/termines/ 	rentrez termines${CEND}"
		echo -e "${CYELLOW}	Pour prendre en compte /home/user/termines/tv/	rentrez termines/tv${CEND}"
                while [ ! -z "$DOSSIER" ]
                do
                        printf "\n"
			echo -e -n "${CGREEN} Dossier (Vide pour arrêter): ${CEND}"
                        read -r DOSSIER

                        #Vérification de la présence du dossier specifié par l'utilisateur
                        if [ -z "$DOSSIER" ]
                        then
                                echo -e "${CBLUE}Fin de l'enregistrement des répertoires${CEND}"
                        elif [ ! -d "/home/$(head -1 $CHEMIN/utilisateurs.list)/$DOSSIER" ]
			then
				echo -e "${CRED}>>> Le dossier /home/$(head -1 $CHEMIN/utilisateurs.list)/$DOSSIER n'existe pas!${CEND}"
				echo -e "${CRED}>>> Dossier non ajouté à repertoires.list${CEND}"
			else
				#pour que le script boxScanner fonctionne correctement, il ne doit pas y avoir de / à la fin 
				if [ "${DOSSIER: -1}" = "/" ]
				then
					printf "${CGREEN}>>> Dossier %b : OK${CEND}\n" "${DOSSIER%/}"
					printf "%b\n" "${DOSSIER%/}" >> $CHEMIN/repertoires_plex.list
				else
					echo -e "${CGREEN}>>> Dossier $DOSSIER : OK${CEND}"
					printf "%b\n" "$DOSSIER" >> $CHEMIN/repertoires_plex.list
				fi
			fi
		done


		echo ""
		echo -e "${CBLUE}Vérification de la correspondance entre :${CEND}"
		echo -e "${CYELLOW}	- utilisateurs.list${CEND}"
		echo -e "${CYELLOW}	- repertoires.list${CEND}"

		while IFS="" read -r utilisateur || [[ -n "$utilisateur" ]]
		do
			while IFS="" read -r repertoire || [[ -n "$repertoire" ]]
			do
				if [ ! -d /home/"$utilisateur"/"$repertoire" ]
				then
					printf "${CYELLOW}Check /home/%b/%b${CEND} 					: ${CRED}Erreur${CEND}\n" "$utilisateur" "$repertoire"
				else
					printf "${CYELLOW}Check /home/%b/%b${CEND}				 	: ${CGREEN}OK${CEND}\n" "$utilisateur" "$repertoire"
				fi
			done < "$CHEMIN"/repertoires.list

		done < "$CHEMIN"/utilisateurs.list

                echo ""
                echo -e "${CBLUE}Vérification de la correspondance entre :${CEND}"
                echo -e "${CYELLOW}     - utilisateurs.list${CEND}"
                echo -e "${CYELLOW}     - repertoires_plex.list${CEND}"

                while IFS="" read -r utilisateur || [[ -n "$utilisateur" ]]
                do
                        while IFS="" read -r repertoire || [[ -n "$repertoire" ]]
                        do
                                if [ ! -d /home/"$utilisateur"/"$repertoire" ]
                                then
                                        printf "${CYELLOW}Check /home/%b/%b${CEND}                                      : ${CRED}Erreur${CEND}\n" "$utilisateur" "$repertoire"
                                else
                                        printf "${CYELLOW}Check /home/%b/%b${CEND}                                      : ${CGREEN}OK${CEND}\n" "$utilisateur" "$repertoire"
                                fi
                        done < "$CHEMIN"/repertoires_plex.list

                done < "$CHEMIN"/utilisateurs.list

		echo ""
		echo -e "${CBLUE}Vérification de la présence du répertoire $LOGSERVER${CEND}"
		if [ ! -d "$LOGSERVER" ]
		then
			echo -e "${CRED}Le répertoire n'existe pas!${CEND}"
			if [ ! -d "$RUTORRENT" ]
			then
				echo -e "${CRED}Le répertoire $RUTORRENT n'existe pas non plus${CEND}"
				echo -e "${CRED}Le répertoire de sauvegardes des rapports HTML devient : $CHEMIN"
				LOGSERVER="$CHEMIN"
			else
				echo -e "${CYELLOW}Creation du répertoire...${CEND}"
				mkdir "$LOGSERVER"
				echo -e "${CYELLOW}Affectation des droits...${CEND}"
				chown www-data:www-data "$LOGSERVER"
				echo -e "${CGREEN}Répertoire $LOGSERVER : OK${CEND}"
			fi
		else
			echo -e "${CGREEN}Répertoire $LOGSERVER : OK${CEND}"
		fi

		#Suppression des lignes de configuration utilisateur par défaut pour les remplacer par celles de l'installation courante
		tac "$CHEMIN"/default.conf | sed '1,3d' | tac > "$CHEMIN"/default.conf.new
		rm  "$CHEMIN"/default.conf
		more "$CHEMIN"/default.conf.new > "$CHEMIN"/default.conf
		rm "$CHEMIN"/default.conf.new

		echo ""
		echo -e "${CBLUE}Ajout des paramètres à default.conf${CEND}"
		{
			printf "\n#Paramètres utilisateur (installation auto)\n"
			printf "BASEPATH=\"%b\"\n" "$CHEMIN" 
			printf "PATHHTML=\"%b\"\n" "$LOGSERVER"
		} >> "$CHEMIN"/default.conf

		echo ""
		echo -e "${CRED}Rappel de la configuration :${CEND}"
		echo -e "${CRED}____________________________${CEND}"
		echo ""
		echo -e "${CYELLOW}>>> utilisateurs.list${CEND}"
		more $CHEMIN/utilisateurs.list
		echo -e -n "${CYELLOW}Appuyez sur Entrer pour continuer...${CEND}"
		read
		echo ""
		echo -e "${CYELLOW}>>> repertoires.list${CEND}"
		more $CHEMIN/repertoires.list
		echo -e -n "${CYELLOW}Appuyez sur Entrer pour continuer...${CEND}"
		read
                echo ""
                echo -e "${CYELLOW}>>> repertoires_plex.list${CEND}"
                more $CHEMIN/repertoires_plex.list
                echo -e -n "${CYELLOW}Appuyez sur Entrer pour continuer...${CEND}"
                read
		echo ""
		echo -e "${CYELLOW}>>> boxCleaner.conf${CEND}"
		more $NGINX/boxCleaner.conf
		echo -e -n "${CYELLOW}Appuyez sur Entrer pour continuer...${CEND}"
		read
		echo ""
		echo -e "${CYELLOW}>>> default.conf${CEND}"
		more $CHEMIN/default.conf
		echo -e -n "${CYELLOW}Appuyez sur Entrer pour continuer...${CEND}"
		read
		echo ""
		echo -e "${CBLUE}Fin de l'installation... Enjoy${CEND}"
	fi
fi


