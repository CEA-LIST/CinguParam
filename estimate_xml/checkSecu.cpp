#include <string>
#include <iostream>
#include <stdexcept>
#include <stdio.h>
#include <stdlib.h>
#include <boost/filesystem.hpp>
#include <dirent.h>
#include <limits.h> /* PATH_MAX */
#include <float.h>
#include "pugixml.hpp"
#include <string>
 
using namespace std;
using namespace boost::filesystem;
using namespace pugi;


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
        /** Read content of the directory named [commit-id], the HEAD of the lwe-estimator **/
        string output_dir;
        string commit_id=exec("bash -c \"git ls-remote https://bitbucket.org/malb/lwe-estimator/raw/HEAD/estimator.py HEAD | awk '{print $1}' | cut -c-7 | cut -z -f1 -d$'\n'\"");
        output_dir.append("../xml/").append(commit_id);
        char *real_path = realpath(output_dir.c_str(), NULL);
        DIR *dir;
        struct dirent *ent;
        char cmd_line[512];
                
        if (real_path != NULL)
        {
                dir = opendir (real_path);
                while ((ent = readdir (dir)) != NULL)
                {
                        if (ent->d_name[0] != '.') // to ignore . and .. directories
                        {
                                cout << ent->d_name << endl;
                                string filename=string(real_path)+"/"+string(ent->d_name);
                                xml_document doc;
                                xml_parse_result result = doc.load_file(filename.c_str());
                                if (result.status != status_ok) 
                                {
                                        cout << "[ERROR] could not parse " << filename.c_str() << endl;
                                        exit(0);
                                }
                                                                
                                xml_node params = doc.child("fhe_params");

                                if (!params) {
                                        cerr << "Error parsing file '" << filename
                                        << "' in method FheParams::readXml" << endl;
                                        exit(0);
                                }


                                int n                       = params.child("extra").child("n").text().as_int();
                                string q                    = params.child("extra").child("q").text().as_string();
                                double alpha                = params.child("extra").child("alpha").text().as_double();
                                string reduction_cost_model = params.child("extra").child("bkz_reduction_cost_model").text().as_string();
                                int m=n;
                                
                                sprintf(cmd_line,"sage -c \"load('https://bitbucket.org/malb/lwe-estimator/raw/HEAD/estimator.py');"
                                "ring_operations=estimate_lwe(%i,%.*g,%s,m=%i,secret_distribution=((0,1),63), reduction_cost_model=%s) \" "
                                ,n,DBL_DIG,alpha,q.c_str(),m,reduction_cost_model.c_str());
                                system((char *)cmd_line);
                        }
                }
                closedir (dir);
                free(real_path);
        }
        else
        {
          perror ("The directory with given commit-id does not exist. You could generate parameter set first.");
          return EXIT_FAILURE;               
        }
        return 0;
}




