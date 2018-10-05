#include <string>
#include <iostream>
#include <stdexcept>
#include <stdio.h>
#include <boost/filesystem.hpp>
#include <omp.h>


/** 
 * Goal:
 * generate xml files containing parameter set when HEAD of lwe-estimator is updated.
 * Usage : 
 * g++ -fopenmp -o updateParam updateParam.cpp -lboost_filesystem -lboost_system && ./updateParam 
**/
 
using namespace std;
using namespace boost::filesystem;


/** The function <exec> enables to use the result of an external program in a C(++) program **/
string exec(const char* cmd) {
        char buffer[128];
        std::string result = "";
        FILE* pipe = popen(cmd, "r");
        if (!pipe) throw std::runtime_error("popen() failed!");
        try {
        while (!feof(pipe)) {
            if (fgets(buffer, 128, pipe) != NULL)
                result += buffer;
        }
        } catch (...) {
        pclose(pipe);
        throw;
        }
        pclose(pipe);
        return result;
}

int main()
{
        /** Creation of the directory named [commit-id], the HEAD of the lwe-estimator **/
        string output_dir;
        string commit_id=exec("bash -c \"git ls-remote https://bitbucket.org/malb/lwe-estimator.git HEAD | awk '{print $1}' | cut -c-7 | cut -z -f1 -d$'\n'\"");
        output_dir.append("../storeParam/").append(commit_id);
        create_directories(output_dir);


        /** Estimation of secure parameter against primal-uSVP using lwe-estimator HEAD
        * These parameters are stored in xml files stored in the directory storeParam
        * The filename is determined by input parameters : <multiplicative depth>, <BKZ reduction model cost>, <minimal security>, <generation method>
        **/

        string gen_param_script="../generateParam/genParam.sage";
        int max_mult_depth=20;        
        vector <int> min_secu;
        min_secu.push_back(80);
        min_secu.push_back(128);
        min_secu.push_back(192);
        vector <string> model; // bkz_model_cost more precisely
        model.push_back("bkz_enum");
        model.push_back("bkz_sieve");
        model.push_back("core_sieve");
        model.push_back("q_core_sieve");
        vector <string>  gen_method;//the method impacts on the step between parameter q (in Fan-Vercautren scheme) during security estimation of parameter sets.  
        gen_method.push_back("wordsizeinc"); 
        gen_method.push_back("bitsizeinc"); //q=2*q  with this method, we merely increment bitsize of q at each iteration
        
        
        string xml_param[min_secu.size()][gen_method.size()][model.size()][max_mult_depth];


        omp_set_num_threads(omp_get_max_threads());

        #pragma omp parallel 
        {
        #pragma omp for collapse(4)
        for (int num_min_secu=0;num_min_secu<min_secu.size();num_min_secu++)
        {
                for (int num_gen_method=0;num_gen_method<gen_method.size(); num_gen_method++)
                {
                    for (int num_model=0; num_model<model.size(); num_model++)
                    {
                        for (int mult_depth=1;mult_depth<=max_mult_depth;mult_depth++)
                        {
                            xml_param[num_min_secu][num_gen_method][num_model][mult_depth-1].append(output_dir).append("/").append(to_string(mult_depth)).append("_").append(model[num_model]).append("_").append(to_string(min_secu[num_min_secu])).append("_").append(gen_method[num_gen_method]);
                            char cmd_line[512];
                            sprintf(cmd_line,"sage %s --mult_depth %i --output_xml %s --model %s --gen_method %s --lambda_p %i",gen_param_script.c_str(), mult_depth, xml_param[num_min_secu][num_gen_method][num_model][mult_depth-1].c_str(), model[num_model].c_str(), gen_method[num_gen_method].c_str(),min_secu[num_min_secu]);
                            printf ("[%s]\n",cmd_line);
                            system((char *)cmd_line);
                        }
                    }
                }
        }
        }
        
        /** 
         * modify filename by replacing required minimal security by approximated security (80,128,192,256)
         * currently, it is necessary because a gap can exist between required minimum security and estimated minimum security.
        **/
        char rename_xml[512];
        for (int num_min_secu=0;num_min_secu<min_secu.size();num_min_secu++)
        {
                memset(rename_xml, 0, sizeof rename_xml);        
                sprintf(rename_xml,"bash renameParam.sh %i %s",min_secu[num_min_secu],commit_id.c_str());
                system((char *)rename_xml);
        }
        return 0;
}
