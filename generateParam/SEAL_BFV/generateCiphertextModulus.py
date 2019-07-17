from __future__ import print_function # to be compatible with Python 2
from decomposeCiphertextModulusBitsize import *



def CiphertextModulus(bitsize):
        dico=decompose (bitsize) # It contains bitsize decomposition into  a sum of small modulus bitsize (less than 60 bits) described as couples (small_modulus_bitsize, nr_occurences)
        user_description=""
        for decomposition in sorted(dico.items()):
                small_modulus_bitsize=decomposition[0]
                nr_occurences=decomposition[1]
                if nr_occurences>0: last_turn=decomposition
        user_description+="{"      
        for decomposition in sorted(dico.items()):
                small_modulus_bitsize=decomposition[0]
                nr_occurences=decomposition[1]
                for i in range(nr_occurences):
                        user_description+=small_modulus_bitsize
                        if decomposition!=last_turn or i!=nr_occurences-1:
                            user_description+=","
        user_description+="}"
        return user_description

                        
# for bitsize in range(coeff_size_min,coeff_size_max):
        # CiphertextModulus(bitsize)
        
