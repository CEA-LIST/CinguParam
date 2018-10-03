 #!/bin/bash
 
 commit_id=$(git ls-remote https://bitbucket.org/malb/lwe-estimator.git HEAD | awk '{print $1}'  | cut -c-7 )
 number_file=$(ls ../databaseParam/$commit_id | wc -l)
 input_file="${commit_id}_estimate_lwe"
 output_file="${commit_id}_sorted_attack_cost"
 
#empty output file
cp /dev/null $output_file

#sort attack estimation cost into ascending order
 for i in $(seq 1 $number_file)
 do
        ranking=$(sed -n $((4*i-2)),$((4*i))p $input_file | tr '^' ':' | tr '.'  ':' | cut -f 1,4 -d: | sort  -n -t: -k2,2)
        filename=$(sed -n $((4*i-3))p $input_file)
        echo $ranking $filename   >>  $output_file        
done

#think to human reader :-)
cat $output_file | sed "s/ /    /g"   | column -t | sort -n -k4 > tmp  
mv tmp $output_file



