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
    
    
HEAD_ID=$(git ls-remote https://bitbucket.org/malb/lwe-estimator.git HEAD | awk '{print $1}' | cut -c-7 )
STORE_DIR="../storeParam"

POLITIC="Cingulata_BFV"
source defaultPolitic.sh
default_politic ${POLITIC} 
OUTPUT_DIR=${STORE_DIR}/${HEAD_ID}/${POLITIC}
nice parallel --verbose --header : --results ${OUTPUT_DIR} bash updateParam.sh {1} {2} {3} {4} {5} {6} ${HEAD_ID}/${POLITIC} ${PRIVATE_KEY_DISTRIB} ${SECU_RED} ${RELIN_VERSION} ${LOG2_ADVANTAGE} ::: mult_depth $(seq 20 -1 0) ::: min_secu 80 128 192 ::: reduction_cost_model "bkz_enum" "bkz_sieve" "core_sieve" "q_core_sieve" "paranoid_sieve" ::: modulus_level "bytesize" ::: method "min_modulus"  ::: plaintext_mod 2   && bash filterParam.sh ${OUTPUT_DIR} && echo "${HEAD_ID}" "${POLITIC}" "$(date)" >> "${STORE_DIR}/commit.log"


# For batching in SEAL, plaintext modulus has to be congruent to 1 modulo 2n (e.g 40961, 65537, 163841, 1032193).
POLITIC="SEAL_BFV"
source defaultPolitic.sh
default_politic ${POLITIC} 
OUTPUT_DIR=${STORE_DIR}/${HEAD_ID}/${POLITIC}
nice parallel --verbose --header : --results ${OUTPUT_DIR} bash updateParam.sh {1} {2} {3} {4} {5} {6} ${HEAD_ID}/${POLITIC} ${PRIVATE_KEY_DISTRIB} ${SECU_RED} ${RELIN_VERSION} ${LOG2_ADVANTAGE} ::: mult_depth $(seq 20 -1 0) ::: min_secu 80 128 192 ::: reduction_cost_model "bkz_enum" "bkz_sieve" "core_sieve" "q_core_sieve" "paranoid_sieve" ::: modulus_level "bytesize" ::: method  "min_modulus"  ::: plaintext_mod 65537 262144 && bash filterParam.sh ${OUTPUT_DIR} && echo "${HEAD_ID}" "${POLITIC}" "$(date)" >> "${STORE_DIR}/commit.log"

# In FV_NFLlib, we suppose here polynomial is stored with data of type uint64_t. Then ciphertext modulus bitsize is a multiple of 62. 
# Other valid choices are 14 and 30 for uint16_t and unnt32_t respectively. See doc/nfl.rst in NFL library.
POLITIC="FV_NFLlib"
source defaultPolitic.sh
default_politic ${POLITIC} 
OUTPUT_DIR=${STORE_DIR}/${HEAD_ID}/${POLITIC}
nice parallel --verbose --header : --results ${OUTPUT_DIR} bash updateParam.sh {1} {2} {3} {4} {5} {6} ${HEAD_ID}/${POLITIC} ${PRIVATE_KEY_DISTRIB} ${SECU_RED} ${RELIN_VERSION} ${LOG2_ADVANTAGE} ::: mult_depth $(seq 20 -1 0) ::: min_secu 80 128 192 ::: reduction_cost_model "bkz_enum" "bkz_sieve" "core_sieve" "q_core_sieve" "paranoid_sieve" ::: modulus_level "FV_NFLlib_uint64_size" ::: method "min_degree" ::: plaintext_mod 65537 262144 && bash filterParam.sh ${OUTPUT_DIR} && echo "${HEAD_ID}" "${POLITIC}" "$(date)" >> "${STORE_DIR}/commit.log"  



