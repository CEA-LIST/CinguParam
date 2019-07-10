# -*- coding: utf-8 -*-
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
    #economic rights,  and the successive licensors  have only limited
    #liability.

    #The fact that you are presently reading this means that you have had
    #knowledge of the CeCILL-C license and that you accept its terms.



# It permits to decompose any ciphertext modulus q with suitable bitsize for cryptographic use.
# coeff_size = log2(q)

def decompose(coeff_size):
        dico={}
        if coeff_size<=60:
                dico[str(coeff_size)]=1
                return dico
        coeff_size_m=coeff_size%30
        coeff_size_m60=coeff_size%60
        coeff_size_d=coeff_size//60
        for i in range(30,61):
                dico[str(i)]=0
        if coeff_size_m60>=30: dico["30"]=1        
        if coeff_size_m == 0:
                dico["60"]=coeff_size_d
        else:
                coeff_size_m30=coeff_size%30
                dico["60"]=coeff_size_d-2
                dico["40"]=1
                dico["50"]=1
                dico[str(30+coeff_size_m)]=dico[str(30+coeff_size_m)]+1
        if dico["60"]==-1:
                dico["30"]=dico["30"]+1
                dico["40"]=dico["40"]-1
                dico["50"]=dico["50"]-1 
                dico["60"]=0                                    
        return dico
    





# Define decomposition of ciphertext moduli for SEAL v3.3 with B/FV cryptosystem

coeff_size_min=54
coeff_size_max=1025
debug=False
            

for i in range(coeff_size_min,coeff_size_max):
        dico=decompose (i)
        if debug==True:
            if dico:
                    print (i)
            i_bis=0 # i_bis is a recomposition of i         
            for x in sorted(dico.items()) :
                    if (x[1] != 0):
                            print (x)
                            i_bis+=int(x[0])*x[1]
            if i!=i_bis:
                    print ("Error during decomposition/recomposition of ciphertext modulus coeff_size.")
                    break

