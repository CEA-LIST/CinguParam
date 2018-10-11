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

# estimated secu can be much greater than minimal security required.
# approximated_secu is the highest multiple of 64 lower than (estimated secu + 8)
# example : 128 is the minimum required, 203 is estimated with lwe-estimator, 192 is the approximation on estimated secu in xml filename
# approximation 64 for estimation in interval [56 120], 128 for [120 184], 192 for [184 248], 256 for [248 312]

if [ $# -eq 0 ]
then
        echo -e "Usage: `basename $0` [min_secu] [commit_id]"" \nTo replace [min_secu] by [approximated_secu] in xml filename." 
        exit 0
fi

min_secu=$1
commit_id=$2
tolerance=8 # example: if the security estimation is 120 bits (resp. 119) and the tolerance is 8 bits, then our approximation is 128 bits (resp. 80).

echo "renameParam"  
cd ../storeParam/$commit_id/
for file in *$min_secu*
do
        estimated_secu=$(xmllint --xpath 'fhe_params/extra/estimated_secu_level/text()' $file)
        approximated_secu=$(((estimated_secu+tolerance)/64*64)) 
        echo $approximated_secu
        mv "$file" "${file/$min_secu/$approximated_secu}"
done


# to remove gen_method from xml filename
mmv -d \*_wordsizeinc "#1"
mmv -d \*_bitsizeinc "#1" # the flag -d serves to force overwrite. Indeed, we do not favour a generation method.

# to replace approximated secu 64 by 80 in filename when it is relevant
if [ $min_secu -ge 80 -a  $min_secu -lt $((128-tolerance)) ]
then
        mmv -d \*_64 "#1_80"
fi

# to remove unrelevant parameter set
rm -f  *320* *384* *448* *512* *576* *640* *704* *768*
