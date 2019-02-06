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
    

# From now, we modify filename by replacing required minimal security by approximated security (80,128,192,256).
# It is preferable because a gap exist between required minimum security and estimated minimum security.
# estimated secu can be much greater than required minimal security.
# example : 128 is the minimum required, 203 is estimated with lwe-estimator, 192 is the approximation on estimated secu in xml filename
# approximation 80 for estimation in interval [80 120], 128 for [120 184], 192 for [184 248], 256 for [248 312]

DIR_NAME=$1
LIST_SECU="${@:2}"
TOLERANCE=8 # example: if the security estimation is 120 bits (resp. 119) and the tolerance is 8 bits, then our approximation is 128 bits (resp. 80).

cd "${DIR_NAME}/" || exit
        

for REQUIRED_SECU in ${LIST_SECU}
do
        for FILE in *${REQUIRED_SECU}*
        do
                ESTIMATED_SECU=$(xmllint --xpath 'fhe_params/extra/estimated_secu_level/text()' ${FILE})
                if [ ${ESTIMATED_SECU} -ge 80 ] && [ ${ESTIMATED_SECU} -lt $((128-TOLERANCE)) ]
                then 
                        APPROXIMATED_SECU=80
                else
                        APPROXIMATED_SECU=$(((ESTIMATED_SECU+TOLERANCE)/64*64))
                fi
                mv   "${FILE}" "${FILE/${REQUIRED_SECU}/${APPROXIMATED_SECU}}" 2>&1 >/dev/null

        done
done
    
# to remove gen_method from xml filename
mmv   \*_wordsizeinc "#1"
mmv -d \*_bitsizeinc "#1" # the flag -d serves to force overwrite. 

# to remove most unpractical parameter sets
rm -f -- *320* *384* *448* *512* *576* *640* *704* *768*

# to remove extra files generated by parallel
rm -rf gen_method
