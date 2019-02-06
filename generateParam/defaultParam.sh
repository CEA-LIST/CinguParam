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

default_param()
{
        POLITIC=$1
        if [ ${POLITIC} = "Cingulata_BFV" ]
        then
               PRIVATE_KEY_DISTRIB='0,1,63' 
               SECURITY_REDUCTION="yes"
                
        elif  [ ${POLITIC} = "SEAL_BFV" ]
        then
                PRIVATE_KEY_DISTRIB='" -1",1'
                SECURITY_REDUCTION="no"
        else
             echo "ERROR Choose a correct value (i.e. Cingulata_BFV or SEAL_BFV) for POLITIC variable."
             exit 1   
        fi
}
