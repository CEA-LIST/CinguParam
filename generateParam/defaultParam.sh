#!/bin/bash

    #(C) Copyright 2019 CEA LIST. All Rights Reserved.
    #Contributor(s): Cingulata team (formerly Armadillo team)
 
    #This software is governed by the CeCILL-C license under French law and
    #abiding by the rules of distribution of free software.  You can  use,
    #modify and/ or redistribute the software under the terms of the CeCILL-C
    #license as circulated by CEA, CNRS and INRIA at the following URL
    #"http://www.cecill.info".
 
    #As a counterpart to the access to the source code and  rights to copy,
    #modify and redistribute granted by the license, users are provided only
    #with a limited warranty  and the software's author,  the holder of the
    #economic rights,  and the successive licensors  have only  limited
    #liability.
 
    #The fact that you are presently reading this means that you have had
    #knowledge of the CeCILL-C license and that you accept its terms.

#Color text
DEFAULT_ZEN='\e[m'
CYAN_WARNING='\e[0;36m'
RED_ERROR='\e[0;31m'


if [ $# -eq 0 ]
  then
    echo -e "${RED_ERROR}You forget to supply a politic.${DEFAULT_ZEN}"
    exit 3 # Undefined politic
fi

POLITICS=()
while read -r line; do
                POLITICS+=( "$(echo $line | awk -F: '{print}')" )
done < available_politics


CHOICE="$1"
IS_DEFINED="no"
for DESCRIPTION in "${POLITICS[@]}"
do
{
     POLITIC=$(echo ${DESCRIPTION}| awk -F: '{print $1}')
     if [ ${CHOICE} = ${POLITIC} ];
     then
     {
       PRIVATE_KEY_DISTRIB=$(echo  $DESCRIPTION | awk -F: '{print $2}')     
       SECURITY_REDUCTION=$(echo  $DESCRIPTION | awk -F: '{print $3}')
       IS_DEFINED="yes"
       break     
     }
     fi
}
done


if [ ${IS_DEFINED} = "no" ]
then
{
      echo -e "${RED_ERROR}Politic $CHOICE is not defined."
      echo -e "Use existing politic or define your own ones."
      echo -e  "Definitions are given in the file generateParam/available_politics.${DEFAULT_ZEN}"
      exit 3 # Undefined politic
 
}
fi



