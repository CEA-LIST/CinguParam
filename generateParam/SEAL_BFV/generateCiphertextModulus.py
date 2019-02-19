from decomposeCiphertextModulusBitsize import *


def CiphertextModulus(bitsize):
        dico_fork=decompose_fork (bitsize) # It contains bitsize decomposition into couples (small_modulus_bitsize, nb_occurences)
        print ("case",bitsize,":")
        print("\tparms.set_coeff_modulus({", sep='')
        for decomposition in sorted(dico_fork.items()):
                small_modulus_bitsize=decomposition[0]
                nb_occurences=decomposition[1]
                if nb_occurences>0: last_turn=decomposition
        for decomposition in sorted(dico_fork.items()):
                small_modulus_bitsize=decomposition[0]
                nb_occurences=decomposition[1]
                for i in range(nb_occurences):
                        print ("\t\tutil::global_variables::small_mods_",small_modulus_bitsize,"bit.at(",i,  sep='',end='')
                        if decomposition==last_turn and i==nb_occurences-1:
                                print (")});")
                                print ("\tbreak;")
                                print ()
                        else:
                                print ("),")

                        
for bitsize in range(coeff_size_min,coeff_size_max):
        CiphertextModulus(bitsize)
