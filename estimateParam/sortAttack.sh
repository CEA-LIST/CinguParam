#!/bin/bash
 
 # -*- coding: utf-8 -*-
#
#    (C) Copyright 2018 CEA LIST. All Rights Reserved.
#    Contributor(s): Cingulata team (formerly Armadillo team)
#
#    This software is governed by the CeCILL-C license under French law and
#    abiding by the rules of distribution of free software.  You can  use,
#    modify and/ or redistribute the software under the terms of the CeCILL-C
#    license as circulated by CEA, CNRS and INRIA at the following URL
#    "http://www.cecill.info".
#
#    As a counterpart to the access to the source code and  rights to copy,
#    modify and redistribute granted by the license, users are provided only
#    with a limited warranty  and the software's author,  the holder of the
#    economic rights,  and the successive licensors  have only  limited
#    liability.
#
#    The fact that you are presently reading this means that you have had
#    knowledge of the CeCILL-C license and that you accept its terms.
#

HEAD_ID=$(git ls-remote https://bitbucket.org/malb/lwe-estimator.git HEAD | awk '{print $1}'  | cut -c-7 )
BASE_DIR=$(dirname $(pwd))
PARAM_DIR="${BASE_DIR}/storeParam"
LAST_ID="$(awk '{w=$1} END{print w}' ${PARAM_DIR}/commit.log)" # to determine last commit ID in database

#Color text
DEFAULT_ZEN='\e[m'
CYAN_WARNING='\e[0;36m'
RED_ERROR='\e[0;31m'


NUMBER_FILE=$(ls ${PARAM_DIR}/${HEAD_ID} | wc -l)
INPUT_FILE="${HEAD_ID}_estimate_lwe"
OUTPUT_FILE="${HEAD_ID}_sorted_attack_cost"    
   
if [ ! -d "${PARAM_DIR}/${HEAD_ID}" ]
        echo -e "${CYAN_WARNING}The parameters with lwe-estimator commit ${HEAD_ID} are not in the database.${DEFAULT_ZEN}" 
        PS3='Please enter your choice: '
                        options=("Sort LWE attacks (last commit=${LAST_ID})" "Update the database (dependency: sagemath)" "Quit")
                        select REPLY in "${options[@]}"
                        do
                            case ${REPLY} in
                                "Sort LWE attacks (last commit=${LAST_ID})")
                                    NUMBER_FILE=$(ls ${PARAM_DIR}/${LAST_ID} | wc -l)
                                    INPUT_FILE="${LAST_ID}_estimate_lwe"
                                    OUTPUT_FILE="${LAST_ID}_sorted_attack_cost" 
                                    break
                                    ;;
                                "Update the database (dependency: sagemath)")
                                    cd "${BASE_DIR}/generateParam" && parallel  --header : --results ${PARAM_DIR}/${HEAD_ID} bash updateParam.sh {1} {2} {3} {4} ${HEAD_ID} ::: mult_depth $(seq 20) ::: min_secu 80 128 192 ::: model "bkz_enum" "bkz_sieve" "core_sieve" "q_core_sieve" ::: gen_method "wordsizeinc" "bitsizeinc" && bash renameParam.sh ${PARAM_DIR}/${HEAD_ID} 80 128 192
                                    echo "${HEAD_ID}" "$(date)" >> "${PARAM_DIR}/commit.log"
                                    break
                                    ;;
                                "Quit")
                                    break
                                    ;;
                                *) echo "invalid option $REPLY";;
                            esac
                        done        
fi
 
 

 
#empty output file
cp /dev/null "${OUTPUT_FILE}"

#sort attack estimation cost into ascending order
 for i in $(seq 1 ${NUMBER_FILE})
 do
        RANKING=$(sed -n $((4*i-2)),$((4*i))p ${INPUT_FILE} | tr '^' ':' | tr '.'  ':' | cut -f 1,4 -d: | sort  -n -t: -k2,2)
        FILENAME=$(sed -n $((4*i-3))p ${INPUT_FILE})
        echo ${RANKING} ${FILENAME}   >>  ${OUTPUT_FILE}        
done

#think to human reader :-)
cat "${OUTPUT_FILE}" | sed "s/ /    /g"   | column -t | sort -n -k4 > tmp  
mv tmp "${OUTPUT_FILE}"



