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
PARAM_DIR="../storeParam"
PLAINTEXT_MODULUS=2 
CONF=Cingulata_BFV # More info on possible values (Cingulata_BGV, SEAL_BFV) in defaultParam.sh.

source defaultParam.sh

default_param ${CONF} 

parallel  --header : --results ${PARAM_DIR}/${HEAD_ID} bash updateParam.sh {1} {2} {3} {4} ${HEAD_ID} ${PLAINTEXT_MODULUS} ${PRIVATE_KEY_DISTRIB} ${SECURITY_REDUCTION} ::: mult_depth $(seq 20) ::: min_secu 80 128 192 ::: model "bkz_enum" "bkz_sieve" "core_sieve" "q_core_sieve" ::: gen_method "wordsizeinc" "bitsizeinc" && bash renameParam.sh ${PARAM_DIR}/${HEAD_ID} 80 128 192
