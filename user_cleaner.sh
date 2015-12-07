#Recuperation de l'ensemble des HASH des torrents presents dans rutorrent/rtorrent pour un utilisateur
for hash_torrent in $(xmlrpc localhost/$1 download_list | grep Index | cut -d\' -f2)
do
        xmlrpc localhost/$1 d.get_base_path $hash_torrent | grep "String\:" | cut -d\' -f2 >> $BASEPATH/$TMP/filepathrutorrent_$1
done

#Liste des telechargements pour un utilisateur
ls -d /home/$1/torrents/tv/* > $BASEPATH/$TMP/filepathserver_$1
ls -d /home/$1/torrents/movie/* >> $BASEPATH/$TMP/filepathserver_$1
ls -d /home/$1/torrents/other/* >> $BASEPATH/$TMP/filepathserver_$1

#Nettoyage des caracteres echappes par xmlrpc en UTF8
while IFS="" read -r line || [[ -n "${line}" ]]
do
        printf "${line}\n" 
done < "$BASEPATH/$TMP/filepathrutorrent_$1" > $BASEPATH/$TMP/filepathrutorrent_$1.new

dateheure=$(date)

#Verification du contenu du repertoire de telechargement /home/USER/torrents
printf "Debut du rapport : $dateheure\n " > $BASEPATH/$RAPPORTS/rapport_$1
printf "\n" >> $BASEPATH/$RAPPORTS/rapport_$1
printf "CONTENU DU REPERTOIRE /home/$1/torrents/ :\n" >> $BASEPATH/$RAPPORTS/rapport_$1
printf "________________________________________________\n" >> $BASEPATH/$RAPPORTS/rapport_$1
printf "\n" >> $BASEPATH/$RAPPORTS/rapport_$1
printf "Le contenu type doit être composé de 3 dossiers uniquement : movie, tv et other\n" >> $BASEPATH/$RAPPORTS/rapport_$1
printf "\n" >> $BASEPATH/$RAPPORTS/rapport_$1

ls -d /home/$1/torrents/* >> $BASEPATH/$RAPPORTS/rapport_$1

printf "\n" >> $BASEPATH/$RAPPORTS/rapport_$1
