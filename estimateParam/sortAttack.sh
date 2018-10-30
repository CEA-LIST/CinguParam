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

 commit_id=$(git ls-remote https://bitbucket.org/malb/lwe-estimator.git HEAD | awk '{print $1}'  | cut -c-7 )
 number_file=$(ls ../storeParam/"$commit_id" | wc -l)
 input_file="${commit_id}_estimate_lwe"
 output_file="${commit_id}_sorted_attack_cost"
 
#empty output file
cp /dev/null "$output_file"

#sort attack estimation cost into ascending order
 for i in $(seq 1 "$number_file")
 do
        ranking=$(sed -n $((4*i-2)),$((4*i))p "$input_file" | tr '^' ':' | tr '.'  ':' | cut -f 1,4 -d: | sort  -n -t: -k2,2)
        filename=$(sed -n $((4*i-3))p "$input_file")
        echo $ranking $filename   >>  "$output_file"        
done

#think to human reader :-)
cat "$output_file" | sed "s/ /    /g"   | column -t | sort -n -k4 > tmp  
mv tmp "$output_file"



