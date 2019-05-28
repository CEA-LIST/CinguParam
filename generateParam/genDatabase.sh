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
default_politic ${POLITIC} # To define PRV_KEY_DISTR and SECU_RED
OUTPUT_DIR=${STORE_DIR}/${HEAD_ID}/${POLITIC}
parallel --verbose --header : --results ${OUTPUT_DIR} bash updateParam.sh {1} {2} {3} {4} {5} {6} ${HEAD_ID}/${POLITIC} ${PRIVATE_KEY_DISTRIB} ${SECU_RED} ${RELIN_VERSION} ::: mult_depth $(seq 0 20) ::: min_secu 80 128 192 ::: reduction_cost_model "bkz_enum" "bkz_sieve" "core_sieve" "q_core_sieve" "paranoid_sieve" ::: modulus_level "bytesize" ::: method "min_modulus" "min_degree" ::: plaintext_mod 2 && bash renameParam.sh ${OUTPUT_DIR}
echo "${HEAD_ID}" "${POLITIC}" "$(date)" >> "${STORE_DIR}/commit.log"


POLITIC="SEAL_BFV"
source defaultPolitic.sh
default_politic ${POLITIC} # To define PRV_KEY_DISTR and SECU_RED
OUTPUT_DIR=${STORE_DIR}/${HEAD_ID}/${POLITIC}
# In SEAL 3.2, ciphertext size is always a multiple of 10. To check this property, this requires a particular setting  in CinguParam with customsize=10 and "min_degree" method.
parallel --verbose --header : --results ${OUTPUT_DIR} bash updateParam.sh {1} {2} {3} {4} {5} {6} ${HEAD_ID}/${POLITIC} ${PRIVATE_KEY_DISTRIB} ${SECU_RED} ${RELIN_VERSION} ::: mult_depth $(seq 0 20) ::: min_secu 80 128 192 ::: reduction_cost_model "bkz_enum" "bkz_sieve" "core_sieve" "q_core_sieve" ::: modulus_level "customsize" ::: method "min_degree" ::: plaintext_mod 2 40961 65537 163841 && bash renameParam.sh ${OUTPUT_DIR}
echo "${HEAD_ID}" "${POLITIC}" "$(date)" >> "${STORE_DIR}/commit.log"




