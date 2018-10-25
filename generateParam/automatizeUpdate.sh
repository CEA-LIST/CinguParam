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

#activate and enable cron service on ArchLinux
#systemctl enable --now cronie

#edit crontab
#crontab -e

#add the following line to execute the following script each Saturday at 6am.
#0 10 * * 6 bash [PUT THE RIGHT DIRECTORY]/generateParam/automatizeUpdate.sh

HEAD_COMMIT=$(git ls-remote https://bitbucket.org/malb/lwe-estimator.git HEAD | awk '{print $1}' | cut -c-7 )
BASEDIR=$(dirname "$0")
cd "$BASEDIR" || exit
if [ ! -d "../storeParam/$HEAD_COMMIT" ]
then 
        echo "$HEAD_COMMIT" "$(date)" >> ../storeParam/commit.log
        parallel  --header : --results ../storeParam/$HEAD_COMMIT bash updateParam.sh {1} {2} {3} {4} $HEAD_COMMIT ::: mult_depth $(seq 20) ::: min_secu 80 128 192 ::: model "bkz_enum" "bkz_sieve" "core_sieve" "q_core_sieve" ::: gen_method "wordsizeinc" "bitsizeinc" 
fi


