from __future__ import print_function # to be compatible with Python 2
from decomposeCiphertextModulusBitsize import *

def CiphertextModulus_dev(bitsize):
        dico_fork=decompose_fork (bitsize) # It contains bitsize decomposition into  a sum of small modulus bitsize (less than 60 bits) described as couples (small_modulus_bitsize, nr_occurences)
        print ("case",bitsize,":")
        print("\tparms.set_coeff_modulus({", sep='')
        for decomposition in sorted(dico_fork.items()):
                small_modulus_bitsize=decomposition[0]
                nr_occurences=decomposition[1]
                if nr_occurences>0: last_turn=decomposition
        for decomposition in sorted(dico_fork.items()):
                small_modulus_bitsize=decomposition[0]
                nr_occurences=decomposition[1]
                for i in range(nr_occurences):
                        print ("\t\tutil::global_variables::default_small_mods_",small_modulus_bitsize,"bit.at(",i,  sep='',end='') 
                        if decomposition==last_turn and i==nr_occurences-1:
                                print(")",end='')
                                print ("});")
                                print ("\tbreak;")
                                print ()
                        else:
                                print ("),")

                        
# for bitsize in range(coeff_size_min,coeff_size_max):
        # CiphertextModulus_dev(bitsize)
        
        
def CiphertextModulus_user(bitsize,debug=False):
        dico_fork=decompose_fork (bitsize) # It contains bitsize decomposition into couples (small_modulus_bitsize, nr_occurences)
        user_description=""
        if (debug):
            print ("case",bitsize,":")
        for decomposition in sorted(dico_fork.items()):
                small_modulus_bitsize=decomposition[0]
                nr_occurences=decomposition[1]
                if nr_occurences>0: last_turn=decomposition
        for decomposition in sorted(dico_fork.items()):
                small_modulus_bitsize=decomposition[0]
                nr_occurences=decomposition[1]
                for i in range(nr_occurences):
                        user_description+="default_small_mods_" + str(small_modulus_bitsize) + "bit(" + str(i)
                        if decomposition==last_turn and i==nr_occurences-1:
                                user_description += ")"
                        else:
                                user_description +="),"
        return user_description


# for bitsize in range(coeff_size_min,coeff_size_max):
        # print (CiphertextModulus_user(bitsize,True))
        
        
