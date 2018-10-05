#!/bin/bash

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
rm -f  *320* *384* *448* *512* *704*
