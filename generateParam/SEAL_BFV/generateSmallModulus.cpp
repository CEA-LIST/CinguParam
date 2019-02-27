/*
    (C) Copyright 2018 CEA LIST. All Rights Reserved.
    Contributor(s): Cingulata team (formerly Armadillo team)
 
    This software is governed by the CeCILL-C license under French law and
    abiding by the rules of distribution of free software.  You can  use,
    modify and/ or redistribute the software under the terms of the CeCILL-C
    license as circulated by CEA, CNRS and INRIA at the following URL
    "http://www.cecill.info".
 
    As a counterpart to the access to the source code and  rights to copy,
    modify and redistribute granted by the license, users are provided only
    with a limited warranty  and the software's author,  the holder of the
    economic rights,  and the successive licensors  have only  limited
    liability.
 
    The fact that you are presently reading this means that you have had
    knowledge of the CeCILL-C license and that you accept its terms.
*/

// g++  generateSmallModulus.cpp -o generateSmallModulus -lgmpxx -lgmp && ./generateSmallModulus
#include "zout.hpp"
#include <gmpxx.h>
#include <typeinfo>
#include <cxxabi.h>
#include <iomanip>
using namespace std;


int main (void)
{
        mpz_class n, iteration, min_iteration, max_iteration, factor;
        mpz_ui_pow_ui (n.get_mpz_t(), 2, 17);
        int max_nb_factor(64);
        int counter;
        unsigned int exponent;
        cout << showbase // show the 0x prefix
         << internal // fill between the prefix and the number
         << setfill('0'); // fill with 0s        
        for (int bitsize=20;bitsize<=60;bitsize++)
        {
                counter=0;
                exponent=bitsize-19;
                //cout << "extern const std::vector<SmallModulus> default_small_mods_" << bitsize << "bit;" << endl;  // to complete src/seal/util/globals.h in SEAL v3.1, without Boost dependency, but longer.
                cout << "const vector<SmallModulus> small_mods_" << bitsize << "bit={"  ;
                mpz_ui_pow_ui (max_iteration.get_mpz_t(), 2, exponent+1); 
                max_iteration--;
                mpz_ui_pow_ui (min_iteration.get_mpz_t(), 2, exponent);
                
                for (iteration=max_iteration;iteration>=min_iteration ;iteration--)
                {
                                factor=1+iteration*2*n;
                                if (mpz_probab_prime_p(factor.get_mpz_t(),50))
                                {
                                        if (counter!=0)
                                                cout << ", " ;
                                        if (counter % 4 == 0)
                                                cout << endl;
                                        counter++;
                                        cout << std::hex <<factor << dec;
                                        if (counter == max_nb_factor)
                                        {
                                                break;
                                        }
                                }
                }
                
                cout << endl << "}" << endl;
        }
        return 0;
}    
