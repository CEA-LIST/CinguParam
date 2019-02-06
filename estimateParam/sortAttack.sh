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


# Absolute path to this script
SCRIPT=$(readlink -f "$0")
# Absolute path this script is in
SCRIPT_PATH=$(dirname "${SCRIPT}")
#CinguParam base directory
BASE_DIR=$(dirname ${SCRIPT_PATH})
 
PARAM_DIR="${BASE_DIR}/storeParam"
COMMIT_ID="$(awk '{w=$1} END{print w}' ${PARAM_DIR}/commit.log)" # to determine last commit ID in database
POLITIC=${1:-"Cingulata_BFV"}
echo "POLITIC="${POLITIC}

NUMBER_FILE=$(ls ${PARAM_DIR}/${COMMIT_ID}/${POLITIC} | wc -l)
INPUT_FILE="${COMMIT_ID}_${POLITIC}_estimate_lwe"
OUTPUT_FILE="${COMMIT_ID}_${POLITIC}_sorted_attack_cost"    

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



