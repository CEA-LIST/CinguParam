#!/bin/bash

# estimated secu can be much greater than minimal security required.
# lb_estimated_secu is the highest multiple of 64 lower than estimated secu
# example : 128 is the minimum required, 203 is estimated with lwe-estimator, 192 is a lower bound on estimated secu in xml filename

if [ $# -eq 0 ]
then
        echo -e "Usage: `basename $0` [min_secu] [commit_id]"" \nTo replace [min_secu] by [lb_estimated_secu] in xml filename." 
        exit 0
fi

min_secu=$1
commit_id=$2

echo "renameParam"  
cd ../storeParam/$commit_id/
for file in *$min_secu*
do
        estimated_secu=$(xmllint --xpath 'fhe_params/extra/estimated_secu_level/text()' $file)
        lb_estimated_secu=$((estimated_secu/64*64))
        echo $lb_estimated_secu
        mv "$file" "${file/$min_secu/$lb_estimated_secu}"
done


# to remove gen_method from xml filename
mmv \*_wordsizeinc "#1"
mmv -d \*_bitsizeinc "#1" # the flag -d serves to force overwrite. Indeed, we do not favour a generation method.

# to replace lower bound secu 64 by 80 in filename
if [ $min_secu -ge 80 -a  $min_secu -lt 128 ]
then
        mmv  \*_64 "#1_80"
fi

# to remove unrelevant parameter set
rm -f  *320* *384* *448* *512* *704*
