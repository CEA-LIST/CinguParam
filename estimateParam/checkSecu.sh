#!/bin/bash

HEAD_ID=$(git ls-remote https://bitbucket.org/malb/lwe-estimator.git HEAD | awk '{print $1}' | cut -c-7 )
POLITIC=${1:-Cingulata_BFV} # More info on defined politics in defaultParam.sh.
INPUT_DIR="../storeParam/${HEAD_ID}/${POLITIC}"

FILE_LIST=$(ls -vr ${INPUT_DIR} ) # For toy example, you can add  "| grep ^0_" e.g.
OUTPUT_FILE=${HEAD_ID}_${POLITIC}_estimate_lwe

export SHELL=$(type -p bash)

lwe_estimator_from_xml()
{
                PATH_TO_FILE=$1
                FILE=${PATH_TO_FILE##*/} # extract string after last /
                n=$(xmllint --xpath 'fhe_params/extra/n/text()' ${PATH_TO_FILE}) 
                q=$(xmllint --xpath 'fhe_params/extra/q_CINGULATA_BFV/text()' ${PATH_TO_FILE}) # Estimated security depends on log2(q) not on factorization of q, from our knowledge.
                m=$(xmllint --xpath 'fhe_params/extra/nr_samples/text()' ${PATH_TO_FILE})
                alpha=$(xmllint --xpath 'fhe_params/extra/alpha/text()' ${PATH_TO_FILE}) 
                bkz_reduction_cost_model=$(xmllint --xpath 'fhe_params/extra/bkz_reduction_cost_model/text()' ${PATH_TO_FILE})
                prv_key_distr=$(xmllint --xpath 'fhe_params/extra/prv_key_distr/text()' ${PATH_TO_FILE})
                t=$(xmllint --xpath 'fhe_params/extra/t/text()' ${PATH_TO_FILE})
                L=$(echo "${FILE}" | awk -F'[_]' '{print $1}')  # multiplicative depth 
                if [ $t -gt 2 -a $L -gt 15 ]; then skip="('mitm', 'arora-gb', 'bkw', 'dec')"; else skip="('mitm', 'arora-gb', 'bkw')"; fi # estimate decoding attack is too costly for big parameters (e.g with mult. depth 20) with non binary plaintext modulus (e.g t=40961 or t=65537)
                if [ "${prv_key_distr}" = "normal" ]; then prv_key_distr='"normal"'; fi
                {
                        echo $FILE         
                        sage -c "load('https://bitbucket.org/malb/lwe-estimator/raw/HEAD/estimator.py');"  \
                                "ring_operations=estimate_lwe($n,$alpha,$q,m=$m,secret_distribution=${prv_key_distr}, reduction_cost_model=${bkz_reduction_cost_model},skip=${skip})" 2>&1
                        echo
                } | tee -a temp_${FILE}
                 
}
export -f lwe_estimator_from_xml
nice parallel -j-1 --header :  lwe_estimator_from_xml   ${INPUT_DIR}/{1} ::: FILE ${FILE_LIST}

cat temp_* >| ${OUTPUT_FILE}
rm temp_*
