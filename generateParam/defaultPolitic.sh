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

default_politic()
{
        POLITIC=$1
        if [ ${POLITIC} = "Cingulata_BFV" ]
        then
               PRIVATE_KEY_DISTRIB='0,1,63'
               SECU_RED="yes"   # pessimitic view, it impacts on Gaussian noise width, in this case it depends on n
               RELIN_VERSION=2  # optimistic view, relinearization parameters with modulus switching are not taken into account during parameter selection
               LOG2_ADVANTAGE=-64      # used to obtain a noise distribution within statistical distance 2^{-64} from a Gaussian distribution
                
        elif  [ ${POLITIC} = "SEAL_BFV" ]
        then
                PRIVATE_KEY_DISTRIB='" -1",1'
                SECU_RED="no"   # optimistic view, in this case, Gaussian noise width=3.2
                RELIN_VERSION=1 # pessimistic view, consider evaluation key contains extra LWE samples even if there are not real ones, there are ones with extra noise depending on the square of the secret key
                LOG2_ADVANTAGE=-28
     
        elif  [ ${POLITIC} = "FV_NFLlib" ]
        then
                PRIVATE_KEY_DISTRIB="normal" # same as noise distribution, i.e,  a truncated Gaussian distribution
                SECU_RED="no"   
                RELIN_VERSION=1 
                LOG2_ADVANTAGE=-128
        else
             echo "ERROR Choose a correct value (i.e. Cingulata_BFV, SEAL_BFV or FV_NFLlib) for POLITIC variable."
             exit 1   
        fi
}
