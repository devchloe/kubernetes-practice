#!/bin/bash
trap "exit" SIGINT
#INTERVAL=$1
echo Configured to generate new fourtune every $INTERVAL seconds

mkdir /var/htdocs
while :
do
  echo $(date) Writing fortune to /var/htdocs/index.html
  /usr/games/fortune > /var/htdocs/index.html
  sleep $INTERVAL
done
