#!/bin/bash
trap "exit" SIGINT
echo Configured to execute spring boot app in $(PROFILE)
java -jar -Dspring.profiles.active=$(PROFILE) /$(SERVICE).jar
