#!/bin/bash

killall --user $1 rtorrent
rm /home/$1/.session/rtorrent.lock
su --command="screen -S $1-rtorrent -X quit" $1

su --command="screen -dmS $1-rtorrent rtorrent" $1
