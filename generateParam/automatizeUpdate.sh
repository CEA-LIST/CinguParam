#!/bin/bash

#activate and enable cron service on ArchLinux
#systemctl enable --now cronie

#edit crontab
#crontab -e

#add the following line to execute the following script each Saturday at 6am.
#0 10 * * 6 bash [PUT THE RIGHT DIRECTORY]/generateParam/automatizeUpdate.sh

HEAD_COMMIT=$(git ls-remote https://bitbucket.org/malb/lwe-estimator.git HEAD | awk '{print $1}' | cut -c-7 )
BASEDIR=$(dirname "$0")
cd $BASEDIR
if [ ! -d ../databaseParam/$HEAD_COMMIT ]
then 
        echo $HEAD_COMMIT $(date) >> ../databaseParam/update_history
        g++ -fopenmp -o updateParam updateParam.cpp -lboost_system -lboost_filesystem && ./updateParam 
fi


