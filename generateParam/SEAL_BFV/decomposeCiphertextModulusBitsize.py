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



# Our fork of SEAL v3.1 stores 64 hardcoded primes of size [30,60].
# It permits to decompose any ciphertext modulus q with suitable bitsize for cryptographic use.

def decompose_fork(q):
        q_m=q%30
        q_m60=q%60
        q_d=q//60
        dico={}
        for i in range(30,61):
                dico[str(i)]=0
        if q_m60>=30: dico["30"]=1        
        if q_m == 0:
                dico["60"]=q_d
        else:
                q_m30=q%30
                dico["60"]=q_d-2
                dico["40"]=1
                dico["50"]=1
                dico[str(30+q_m)]=dico[str(30+q_m)]+1                
        return dico
    

# Official SEAL v3.1 stores 64 hardcoded primes of size 30, 40, 50, 60.
# If ciphertext modulus q is not a multiple of 10, it is not possible to decompose it.
# During parameter selection with CinguParam, bitsize(q) is determined, it is necessary to respect i. 
# One solution is proposed in our fork. It is available in our fork of SEAL v3.1 (see more info below).

def decompose_seal(q):
        q_down=(q//10)*10
        q_up=q_down+10
        q=q_up if (q-q_down>=q_up-q) else q_down # closest multiple of 10
        q_m=q%60
        q_d=q//60
        dico={}
        if q_m == 0:
                dico["30"]=0
                dico["40"]=0
                dico["50"]=0
                dico["60"]=q_d
        elif q_m==10 :
                dico["30"]=1
                dico["40"]=0
                dico["50"]=2
                dico["60"]=q_d-2
        elif q_m==20:
                dico["30"]=0
                dico["40"]=1
                dico["50"]=2
                dico["60"]=q_d-2
        elif q_m==30:
                dico["30"]=0
                dico["40"]=0
                dico["50"]=3
                dico["60"]=q_d-2
        elif q_m==40:
                dico["30"]=0
                dico["40"]=1
                dico["50"]=0
                dico["60"]=q_d
        elif q_m==50:
                dico["30"]=0
                dico["40"]=0
                dico["50"]=1
                dico["60"]=q_d
        return dico






# Define decomposition of ciphertext moduli for SEAL.B/FV official version as well as our fork.

q_min=180
q_max=700

for i in range(q_min,q_max):
        dico_seal=decompose_seal (i)
        debug=True
        if debug==False:
            if dico_seal: print (i, dico_seal)
            

for i in range(q_min,q_max):
        dico_fork=decompose_fork (i)
        debug=False
        if debug==True:
            if dico_fork:
                    print (i)
            i_bis=0 # i_bis is a recomposition of i         
            for x in sorted(dico_fork.items()) :
                    if (x[1] != 0):
                            print (x)
                            i_bis+=int(x[0])*x[1]
            if i!=i_bis:
                    print ("Error during decomposition/recomposition of ciphertext modulus q.")
                    break
