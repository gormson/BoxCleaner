# BoxCleaner
Script permettant de réaliser une maintenance automatique de votre seedbox.
Cette maintenance est légère et permet juste de vérifier les incohérences

# Fonctionnement:
	1 - Le contenu rutorrent de chaque utilisateurs est listé
	2 - Le contenu du dossier /home/<user>/torrents contenant les fichiers/dossiers avec les mêmes noms que les torrents est listé
	3 - Les deux listes sont comparées pour vérifier les incohérences
	
# Détections supportées
	1 - Un torrent présent dans rutorrent/rtorrent mais sans fichier associé >> Mineur, pas de consommation d'espace disque inutile
	2 - Un fichier présent sur le serveur mais sans torrent associé >> Majeur, consommation d'espace disque inutilement
	

