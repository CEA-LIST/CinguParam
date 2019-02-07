#!/bin/bash

HEAD_ID=$(git ls-remote https://bitbucket.org/malb/lwe-estimator.git HEAD | awk '{print $1}' | cut -c-7 )
POLITIC=${1:-Cingulata_BFV} # More info on defined politics in defaultParam.sh.
INPUT_DIR="../storeParam/${HEAD_ID}/${POLITIC}"

FILE_LIST=$(ls ${INPUT_DIR})
OUTPUT_FILE=${HEAD_ID}_${POLITIC}_estimate_lwe

export SHELL=$(type -p bash)

lwe_estimator_from_xml()
{
                PATH_TO_FILE=$1
                FILE=${PATH_TO_FILE##*/} # extract string after last /
                n=$(xmllint --xpath 'fhe_params/extra/n/text()' ${PATH_TO_FILE}) 
                q=$(xmllint --xpath 'fhe_params/extra/q/text()' ${PATH_TO_FILE}) 
                alpha=$(xmllint --xpath 'fhe_params/extra/alpha/text()' ${PATH_TO_FILE}) 
                bkz_reduction_cost_model=$(xmllint --xpath 'fhe_params/extra/bkz_reduction_cost_model/text()' ${PATH_TO_FILE}) 
                private_key_distribution=$(xmllint --xpath 'fhe_params/extra/private_key_distribution/text()' ${PATH_TO_FILE}) 
                m=$n
                {
                        echo $FILE         
                        sage -c "load('https://bitbucket.org/malb/lwe-estimator/raw/HEAD/estimator.py');"  \
                                "ring_operations=estimate_lwe($n,$alpha,$q,m=$m,secret_distribution=${private_key_distribution}, reduction_cost_model=${bkz_reduction_cost_model})" 2>&1
                } | tee -a temp_${FILE}
                 
}
export -f lwe_estimator_from_xml
parallel --header :  lwe_estimator_from_xml   ${INPUT_DIR}/{1} ::: FILE ${FILE_LIST} 

cat temp_* >| ${OUTPUT_FILE}
rm temp_*
