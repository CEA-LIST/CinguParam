#!/bin/bash

    #(C) Copyright 2018 CEA LIST. All Rights Reserved.
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

MULT_DEPTH=$1
REQUIRED_SECU=$2
COST_MODEL=$3
MOD_LEVEL=$4  # bitsize, bytesize, SEAL_3.2_size, FV_NFLlib_uint16_size, FV_NFLlib_uint32_size, FV_NFLlib_uint64_size, wordsize
METHOD=$5 # min_degree or min_modulus
PLAINTEXT_MOD=$6
DIR_NAME=$7
PRV_KEY_DISTR=$8
# For uniform distribution in the interval [a,b], use : a,b or a,b,h -- Private key coefficients are in the interval [a,b]. The integer h indicates the Hamming weight (number of non-zero coefficient) of the private key. 
# Example: PRV_KEY_DISTR=" -1",1
SECU_RED=$9 
# Either "yes", Gaussian width depends on the polynomial degree, as required in Regev quantum security-reduction proof or "no", Gaussian width is set at  aproximately 8/sqrt(2*Pi), it is estimated sufficient by a large part of the community, in 2019, and it improves performance.
RELIN_VERSION=${10} # Version 1 and 2 are presented in [BFV12].
LOG2_ADVANTAGE=${11}
POLITIC=$(echo "${DIR_NAME}" | awk -F'[/]' '{print $2}') 

FILE_NAME="../storeParam/$DIR_NAME/${MULT_DEPTH}_${COST_MODEL}_${REQUIRED_SECU}_${PLAINTEXT_MOD}_${MOD_LEVEL}_${METHOD}"
echo "FILE_NAME = "${FILE_NAME}
sage ../generateParam/genParam.sage --output_xml "${FILE_NAME}" --mult_depth  "${MULT_DEPTH}"  --lambda_p "${REQUIRED_SECU}" --reduction_cost_model "${COST_MODEL}"  --modulus_level "${MOD_LEVEL}" \
                                    --plaintext_modulus ${PLAINTEXT_MOD} --prv_key_distr "${PRV_KEY_DISTR}" --security_reduction ${SECU_RED} \
                                    --relin_version ${RELIN_VERSION} --log2_advantage ${LOG2_ADVANTAGE} --method ${METHOD} --politic ${POLITIC}

