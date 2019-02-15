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
                //cout << "extern const std::vector<SmallModulus> small_mods_" << bitsize << "_bit;" << endl;  // to complete src/seal/util/globals.h in SEAL v3.1, without Boost dependency, but longer.
                cout << "const vector<SmallModulus> small_mods" << bitsize << "_bit={"  ;
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
