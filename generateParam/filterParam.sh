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
    


DIR_NAME=$1
LIST_SECU="80 128 192 256"
TOLERANCE=8 # example: if the security estimation is 120 bits (resp. 119) and the tolerance is 8 bits, then our approximation is 128 bits (resp. 80).

cd "${DIR_NAME}/" || exit


# From now, we modify filename by replacing required minimal security by approximated security (80,128,192,256).
# It is preferable because a gap exist between required minimum security and estimated minimum security.
# estimated secu can be much greater than required minimal security.
# example : 128 is the minimum required, 203 is estimated with lwe-estimator, 192 is the approximation on estimated secu in xml filename
# approximation 80 for estimation in interval [80 120], 128 for [120 184], 192 for [184 248], 256 for [248 312]
        
# replace estimated_secu by approximated secu
for REQUIRED_SECU in ${LIST_SECU}
do
    for FILE in *${REQUIRED_SECU}*
    do
        [ -f $FILE ] || break
        ESTIMATED_SECU=$(xmllint --xpath 'fhe_params/extra/estimated_secu_level/text()' ${FILE})
        [[ -z "${ESTIMATED_SECU}" ]] &&  exit
        if [ ${ESTIMATED_SECU} -ge 80 ] && [ ${ESTIMATED_SECU} -lt $((128-TOLERANCE)) ]
        then
                APPROXIMATED_SECU=80
        else
                APPROXIMATED_SECU=$(((ESTIMATED_SECU+TOLERANCE)/64*64))
        fi
        mv  "${FILE}" "${FILE/${REQUIRED_SECU}/${APPROXIMATED_SECU}}" 2>&1 >/dev/null
    done
done

# remove most unpractical parameter sets
rm -f -- *_320_* *_384_* *_448_* *_512_* *_576_* *_640_* *_704_* *_768_*


# filter pair to keep better memory parameter set
FILTER_FILE=../filters_results
echo $DIR_NAME >> $FILTER_FILE
nb_pair=0 # A pair is two files with same name but different generation methods "min_modulus" and "min_degree" (e.g 12_bkz_enum_80_2_bytesize_min_degree and 12_bkz_enum_80_2_bytesize_min_modulus)
nb_file_modulus=$(find . -type f \( -name "*_modulus"  \) | wc -l)
nb_file_degree=$(find . -type f \( -name "*_degree"  \) | wc -l)
echo "Before filter between methods min_modulus and min_degree:" >> $FILTER_FILE
echo nb_file_modulus=$nb_file_modulus >> $FILTER_FILE
echo nb_file_degree=$nb_file_degree >> $FILTER_FILE

for file_degree in $(find . -type f \( -name "*_degree"  \))
do 
    file_prefix=$(echo ${file_degree} | sed 's/_degree//') 
    file_modulus=$(echo ${file_prefix}_modulus) 
    if test -f ${file_modulus}
    then
        nb_pair=$((nb_pair+1))
        n_modulus=$(xmllint --xpath 'fhe_params/extra/n/text()' ${file_modulus}) 
        n_degree=$(xmllint --xpath 'fhe_params/extra/n/text()' ${file_degree}) 
        log_q_modulus=$(xmllint --xpath 'fhe_params/ciphertext/coeff_modulo_log2/text()' ${file_modulus}) 
        log_q_degree=$(xmllint --xpath 'fhe_params/ciphertext/coeff_modulo_log2/text()' ${file_degree})
        mem_modulus=$((n_modulus*log_q_modulus)) # memory, number of bits to store ciphertext polynomial
        mem_degree=$((n_degree*log_q_degree))
        if [ $mem_modulus -gt $mem_degree ] # We keep file with better memory perf
        then 
            rm -v $file_modulus
        else
            rm -v $file_degree
        fi
    fi 
done

echo "Pair are two parameter sets with same mult_depht, approximated secu level and model cost, obtained respectively with min_modulus and min_degree modulus." >> $FILTER_FILE
echo nb_pair=$nb_pair >> $FILTER_FILE
echo "After filter, we keep the better parameter set between the two, in terms of memory management." >> $FILTER_FILE
nb_file_modulus=$(grep -d skip min_modulus *| wc -l)
nb_file_degree=$(grep -d skip min_degree * | wc -l)
echo nb_file_modulus=$nb_file_modulus >> $FILTER_FILE
echo nb_file_degree=$nb_file_degree >> $FILTER_FILE


# shorten xml filename
mmv -d \*_min_degree "#1"               &>/dev/null
mmv -d \*_min_modulus "#1"              &>/dev/null # TOIMPROVE: before renaming, remove worst parameter set between min_modulus and min_degree
mmv -d \*_wordsize "#1"                 &>/dev/null
mmv -d \*_bitsize "#1"                  &>/dev/null
mmv -d \*_bytesize "#1"                 &>/dev/null
mmv -d \*_SEAL_3.2_size "#1"            &>/dev/null
mmv -d \*_FV_NFLlib_uint64_size "#1"    &>/dev/null


# remove extra files generated by parallel
rm -rf method

### Filter parameter sets to remove inconsistent parameter set (i.e. if with same multiplicative depth, BKZ cost model, plaintext modulus, we have two parameter sets whose one with biggest ciphertext modulus for smallest approximated security level, then we remove it). It happens when different parameter generation method are used (e.g min_degree and min_modulus)

for file in *
do
    # first determine a set of triples (depth_model_pt_modulus)
    depth=$(echo "${file}" | awk -F'[_]' '{print $1}')  # print multiplicative depth
    model=$(echo "${file}" | sed 's/[0-9]//g' | sed 's/^_//' | sed 's/_$// ' | sed 's/_$// ') # print bkz reduction cost model
    pt_modulus=$(echo "${file}" | awk -F'[_]' '{print $NF}') # print plaintext modulus
    triple=${depth}_${model}_${pt_modulus}
    triple_list+=("${triple}")
    triple_set=($(printf "%s\n" "${triple_list[@]}" | sort -u))
done



# each subset contain files with same triple (depth_model_pt_modulus) and different security levels 
count=0 # to count unconsistent paramset
for triple in "${triple_set[@]}"
do
    
    file_subset=()
    file_subset+=($(echo ${triple} | sed 's/\(.*\)_/\1_*_/'))
    sorted_subset=()
    sorted_subset+=($(echo ${file_subset[@]} | tr " " "\n" | sort -V | tr "\n" " ")) # alphanumerical sort
    if [ ${#sorted_subset[@]} -gt 1 ]
    then
        for file in "${sorted_subset[@]}"
        do
            secu=$(echo "${file}" | awk -F'[_]' '{print $((NF-1))}') # print approximated security
            #echo ${file}
        done
        for index in $(seq $((${#sorted_subset[@]}-1)))
        do
            min_file=${sorted_subset[index-1]} 
            max_file=${sorted_subset[index]}
            min_secu=$(echo "${min_file}" | awk -F'[_]' '{print $((NF-1))}') 
            max_secu=$(echo "${max_file}" | awk -F'[_]' '{print $((NF-1))}') 
            min_n=$(xmllint --xpath 'fhe_params/extra/n/text()' ${min_file}) 
            max_n=$(xmllint --xpath 'fhe_params/extra/n/text()' ${max_file}) 
            min_log_q=$(xmllint --xpath 'fhe_params/ciphertext/coeff_modulo_log2/text()' ${min_file}) 
            max_log_q=$(xmllint --xpath 'fhe_params/ciphertext/coeff_modulo_log2/text()' ${max_file})
            min_mem=$((min_n*min_log_q)) # memory, number of bits to store ciphertext polynomial
            max_mem=$((max_n*max_log_q)) 
            if [ $min_mem -gt $max_mem ] # inconsistency condition :  bigger parameter and lower security
            then
                #echo ${#sorted_subset[@]} # number of files with same triple
                #echo ${sorted_subset[index-1]} ${sorted_subset[index]} # first file have minimal secu
                #echo "secu: " $min_secu $max_secu
                #echo "n: "$min_n $max_n
                #echo "log2(q): " $min_log_q $max_log_q
                echo "rm -v "${min_file}
                count=$((count+1))
                rm -v ${min_file}
            fi
        done
    fi
done 

if [ ${count} -gt 0 ]
then
    echo "Filter: ${count} detected and removed inconsistent parameter set(s)" >> $FILTER_FILE
fi

echo "" >> $FILTER_FILE
