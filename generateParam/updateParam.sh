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
INCR_FUNC=$4 
METHOD=$5 
DIR_NAME=$6
PLAINTEXT_MOD=$7
PRV_KEY_DISTR=$8
# Two possible forms: a,b or a,b,h -- Private key coefficients are in the interval [a,b]. The integer h indicates the Hamming weight (number of non-zero coefficient) of the private key. 
# Example: the ternary distribution (,1,0,1) is obtained with PRV_KEY_DISTR=" -1",1
SECU_RED=$9 
# Either "yes", Gaussian width depends on the polynomial degree, as required in Regev quantum security-reduction proof or "no", Gaussian width is set at  aproximately 8/sqrt(2*Pi), it is estimated sufficient by a large part of the community, in 2019, and it improves performance.
RELIN_VERSION=${10} # Version 1 and 2 are presented in [BFV12].


FILE_NAME="../storeParam/$DIR_NAME/${MULT_DEPTH}_${COST_MODEL}_${REQUIRED_SECU}_${PLAINTEXT_MOD}_${INCR_FUNC}_${METHOD}"
echo "FILE_NAME = "${FILE_NAME}
sage ../generateParam/genParam.sage --output_xml "${FILE_NAME}" --mult_depth  "$MULT_DEPTH"  --lambda_p "$REQUIRED_SECU" --reduction_cost_model "$COST_MODEL"  --scale_name "$INCR_FUNC" \
                                    --plaintext_modulus ${PLAINTEXT_MOD} --prv_key_distr "${PRV_KEY_DISTR}" --security_reduction ${SECU_RED} \
                                    --relin_version ${RELIN_VERSION} --method ${METHOD}

