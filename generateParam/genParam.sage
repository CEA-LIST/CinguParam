# -*- coding: utf-8 -*-
#
#    (C) Copyright 2017 CEA LIST. All Rights Reserved.
#    Contributor(s): Cingulata team (formerly Armadillo team)
#
#    This software is governed by the CeCILL-C license under French law and
#    abiding by the rules of distribution of free software.  You can  use,
#    modify and/ or redistribute the software under the terms of the CeCILL-C
#    license as circulated by CEA, CNRS and INRIA at the following URL
#    "http://www.cecill.info".
#
#    As a counterpart to the access to the source code and  rights to copy,
#    modify and redistribute granted by the license, users are provided only
#    with a limited warranty  and the software's author,  the holder of the
#    economic rights,  and the successive licensors  have only  limited
#    liability.
#
#    The fact that you are presently reading this means that you have had
#    knowledge of the CeCILL-C license and that you accept its terms.
#

  
"""@package genParam

[Disclaimer]
This script generates parameters for the Fan-Vercauteren cryptosystem following our variant of an algorithm described in G. Bonnoron PhD Thesis (algorithm 5.9, page 76). It employs HEAD commit of lwe-estimator (https://bitbucket.org/malb/lwe-estimator) . It is provided on an AS IS basis. If you need up-to-date security levels you should consider more recent complexity estimates for known attacks on RLWE.

[Short description]
This script is used to generate parameters for Fan-Vercauteren (FV for short) leveled homomorphic encryption following lwe-estimator (https://bitbucket.org/malb/lwe-estimator).

[First use] 
To use this script properly, type:
sage genParam.sage -h

This command describes input parameters and how to use them. It also gives default parameters

[Toy example] 
To use this script with default values, type:
sage genParam.sage

[Input/Output]
Input parameters are displayed on the standard output.
Generated parameters describes probability distributions and indicates moduli bitsize.
Output is a xml file in which generated parameters and input parameters are written.

[Additional info]
The script define two parameters sets. 
The first parameter set is used during key generation, encryption.
The second one is used during relinearisation.

Sources (chronological order): 

        [LP11] Lindner, Richard et Peikert, Chris. Better key sizes (and attacks) for LWE-based encryption. In : Cryptographers’ Track at the RSA Conference. Springer, Berlin, Heidelberg, 2011. p. 319-339.

        [FV12] Fan, Junfeng, and Frederik Vercauteren. "Somewhat Practical Fully Homomorphic Encryption." IACR Cryptology ePrint Archive 2012 (2012): 144.
        URL: https://eprint.iacr.org/2012/144.pdf

        [APS15] Martin R. Albrecht, Rachel Player and Sam Scott. On the concrete hardness of Learning with Errors.
        Journal of Mathematical Cryptology. Volume 9, Issue 3, Pages 169–203, ISSN (Online) 1862-2984,
        ISSN (Print) 1862-2976 DOI: 10.1515/jmc-2015-0016, October 2015

        [P16] Peikert, Chris. How (not) to instantiate ring-lwe. In : International Conference on Security and Cryptography for Networks. Springer, Cham, 2016. p. 411-430.

        [CCDG17] Melissa Chase, Hao Chen, Jintai Ding, Shafi Goldwasser, Sergey Gorbunov, Jeffrey Hoffstein, Kristin Lauter, Satya Lokam, Dustin Moody, Travis Morrison, Amit Sahai, Vinod Vaikuntanathan
        Security of Homomorphic Encryption (white paper)
        
        [B18] G Bonnoron A journey towards practical Fully Homomorphic Encryption (PhD thesis, 2018)

        [AC+18] Martin R. Albrecht and Benjamin R. Curtis and Amit Deo and Alex Davidson and Rachel Player and Eamonn W. Postlethwaite and Fernando Virdia and Thomas Wunderer
        Estimate all the {LWE, NTRU} schemes!
        



\author CEA-List, Embedded Real-Time System foundations Lab (DACLE/LaSTRE)
"""
load('https://bitbucket.org/malb/lwe-estimator/raw/HEAD/estimator.py')
import sys
import os
import argparse
import mpmath as mpm
from mpmath import mpf
from xml.dom import minidom
import numpy as np
sys.path.insert(0,"SEAL_BFV")
from generateCiphertextModulus import * # To define ciphertext moduli for SEAL BFV.
import colorama
from colorama import Fore, Style
import time

#######
# Read config file with name=value pairs, ConfigParse module

class _Parameters:
        def __init__(self):
                None
    
        def __getitem__(self, key):
                return self.__dict__[key]

        def updateParams(self, params_dict):
                self.__dict__.update(params_dict)

        def _parse_param(self, xmldoc, paramName):
                a = xmldoc.getElementsByTagName(paramName)
                if len(a) > 0:
                        self.__dict__[paramName] = float(a[0].firstChild.data)
      
        def parseXml(self, xmlStr):
                xmldoc = minidom.parseString(xmlStr)
                for key in self._params_defaults.keys():
                        self._parse_param(xmldoc, key)

class _ParametersGenerator:
        def __init__(self, params):
                self._eps_exp = params['eps_exp'] # Exponent of adversary's advantage (i.e. success probability) to have samples out of bound
                self.prv_key_distr = params['prv_key_distr'] # Distribution is described by bounds and optionally Hamming weight of the private key
                self._h = params['prv_key_distr'][1] if isinstance(params['prv_key_distr'][0],tuple) else -1 # Hamming weight of the private key. -1 means weight is not indicated in prv_key_distr.
                self._lambda_p = params['lambda_p'] # Security level
                # Estimated security _lambda_p is greater than desired/minimal/required security level given in CLI.   
                self.t = params['plaintext_modulus'] 
                self.L = params['mult_depth'] # Circuit multiplicative depth
                self.relin_version = params['relin_version']
                if (self.relin_version == 1):
                    self.dbc = params['dbc']
                elif (self.relin_version == 2):
                    self.k = params['relin_k']
                self.method = params['method']
                self.omega = params['omega'] # basis during gadget decomposition, bigger relinearisation key but smaller error growth with omega = 32 rather than 64
                self.customsize = params['customsize']
                self.reduction_cost_model = params['reduction_cost_model'] # BKZ reduction cost model
                self.modulus_level = params['modulus_level'] # incremented function during computation of ciphertext modulus q
                if  self.modulus_level == "bitsize" and self.method == "min_degree":
                    sys.exit() # This setting slowdowns parameter generation because of numerous calls to LWE-Estimator. 
                self.security_reduction = params['security_reduction'] 
                mpm.mp.prec = 128
                self.comp_init_params()

        def write(self):
                print (Fore.YELLOW + "Attack cost computed with lwe-estimator \nHEAD commit ID = " + os.popen("git ls-remote https://bitbucket.org/malb/lwe-estimator.git HEAD | awk '{print $1}' | cut -c-7").read().rstrip('\n') + Style.RESET_ALL)
                order = ['reduction_cost_model', '_lambda_p','security_reduction' ,'L','n', 'log2_q' , 'sigma', 't','prv_key_distr','nr_samples','relin_version']
                for flag in order:
                        for key,val in self.__dict__.items():
                                if (flag == key):        
                                        if (key in ['reduction_cost_model','_lambda_p','L','sigma','log2_q']): 
                                                print ('\t{0} = {1}'.format(Describe(key), val))  
                                        elif (key in ['security_reduction','n','L','t','prv_key_distr','nr_samples','relin_version']):
                                                print ('\t{0} = {1}'.format(key, val))
                                            
        def comp_init_params(self):
                self._alfa = self._comp_alfa(self._eps_exp)
                self._beta = self._comp_beta(self._eps_exp)

        def _round_up(self, a, dps):
                m = mpm.power(10, dps)
                return mpm.ceil(a * m) / m

        def _comp_alfa(self, eps_exp):
                eps = mpm.power(2, eps_exp)
                alfa = mpm.sqrt(mpm.ln(1 / eps) / mpm.pi)
                alfa = self._round_up(alfa, 3)
                return alfa

        def _comp_beta(self, eps_exp):
                eps = mpm.power(2, eps_exp)
                beta = mpm.erfinv(1-eps) * mpm.sqrt(2)
                return beta

        def _comp_error_bound(self, beta, sigma):
                return mpm.ceil(beta * sigma)

        def _comp_sigma_k(self, sigma, q, k):
                sigma_k = mpm.power(self._alfa, 1-mpm.sqrt(k))
                sigma_k *= mpm.power(q, k-mpm.sqrt(k))
                sigma_k *= mpm.power(sigma, mpm.sqrt(k))
                sigma_k = mpm.ceil(sigma_k)
                return sigma_k

        def __getitem__(self, key):
                return self.__dict__[key]
                
        def comp_params(self):
                t = self.t # plaintext modulus
                min_secu_level = self._lambda_p
                mult_depth = self.L
                prv_key_distr = self.prv_key_distr
                beta = self._beta # defined on page 3 in [FV12]
                security_reduction = self.security_reduction
                relin_version = self.relin_version
                method = self.method
                if relin_version == 1:
                    param_set = ChooseParam(method,t,min_secu_level,prv_key_distr,beta,security_reduction,relin_version,\
                                            mult_depth,reduction_cost_model=self.reduction_cost_model,omega=self.omega,customsize=self.customsize,modulus_level=self.modulus_level,dbc=self.dbc)
                elif relin_version == 2:
                    param_set = ChooseParam(method,t,min_secu_level,prv_key_distr,beta,security_reduction,relin_version,\
                                            mult_depth,reduction_cost_model=self.reduction_cost_model,omega=self.omega,customsize=self.customsize,modulus_level=self.modulus_level)
                self.n = param_set[0]
                self.poly_degree_log2 = int(np.log2(param_set[0]))
                self.cyclotomic_poly_index = param_set[0]*2
                self._lambda_p = param_set[1][0]
                self.log2_q = param_set[1][1]
                self.q = param_set[2]
                self.alpha = param_set[3] # noise rate
                self.nr_samples = param_set[4] # number of LWE samples            
                self.sigma = mpf(self.alpha*self.q) # noise Gaussian width
                self.error_bound = self._comp_error_bound(self._beta, self.sigma)
                if (self.relin_version == 1):
                    self._comp_relin_v1_params()
                elif (self.relin_version == 2):
                    self._comp_relin_v2_params()
                            
        def _comp_relin_v1_params(self):
                # l = floor(log_T(q)) in [FV12] and T = 2**dbc
                self.l = int(self.log2_q/self.dbc)
                        
        def _comp_relin_v2_params(self):
                self.log2_p = int(self.log2_q) * (self.k-1)
                self.log2_pq = int(self.log2_q) * self.k
                self.q = mpm.power(2,self.log2_q)
                self.sigma_k = mpf(self._comp_sigma_k(self.sigma, self.q, self.k))
                self.log2_sigma_k = ceil(log(self.sigma_k)/log(2))
                self.B_k = self._comp_error_bound(mpm.power(self._beta, mpm.sqrt(self.k)), self.sigma_k)
                self.pq = mpm.power(2,self.log2_pq)
                self.alpha_k = self.sigma_k/self.pq

        def mpf2intstr(self, mpf):
                prec = int(mpm.nstr(mpf, 0).split('e')[-1]) + 1
                mpf_str = mpm.nstr(mpf, prec)
                mpf_int_str = mpf_str.split('.')[0]
                return mpf_int_str

        def mpf2str(self, mpf):
                prec = int(mpm.nstr(mpf, 0).split('e')[-1]) + 3
                mpf_str = mpm.nstr(mpf, prec)
                return mpf_str
                
        def createPolynomialRingNode(self, doc):
                def createCoeffNode(doc, value, degree):
                        coeff = doc.createElement("coeff")

                        v = doc.createElement("value")
                        v.appendChild(doc.createTextNode(str(int(value))))
                          
                        d = doc.createElement("degree")
                        d.appendChild(doc.createTextNode(str(int(degree))))

                        coeff.appendChild(v)
                        coeff.appendChild(d)

                        return coeff

                def createPolyNode(doc, poly):
                        cfs = doc.createElement("coeffs")
                        for degree, coeff in poly.dict().items():
                                cfs.appendChild(createCoeffNode(doc, coeff, degree))
                        return cfs    
    
                pr = doc.createElement("polynomial_ring")
                mp = doc.createElement("cyclotomic_polynomial")

                #write cyclotomic polynomial index
                on = doc.createElement("index")
                on.appendChild(doc.createTextNode(str(int(2 * 2 ** self.poly_degree_log2))))
                mp.appendChild(on)

                pr.appendChild(mp)

                return pr

        def createPlaintextNode(self, doc):
                pt = doc.createElement("plaintext")
                cm = doc.createElement("coeff_modulo")

                cm.appendChild(doc.createTextNode(str(int(self.t))))
                pt.appendChild(cm)

                return pt
                
                
        def createNormalDistributionNode(self, doc, **kwargs):
                nd = doc.createElement("normal_distribution")
                 
                for arg_name in kwargs:
                    sn = doc.createElement(arg_name)
                    nd.appendChild(sn)
                    sn.appendChild(doc.createTextNode(kwargs[arg_name]))
                               
                return nd        
  
        def createCiphertextNode(self, doc):
                ct = doc.createElement("ciphertext")
                cm = doc.createElement("coeff_modulo_log2")
                ct.appendChild(cm)

                cm.appendChild(doc.createTextNode(str(int(self.log2_q))))

                ct.appendChild(self.createNormalDistributionNode(doc, sigma=self.mpf2str(self.sigma), bound=self.mpf2str(self.error_bound)))

                return ct
  
        def createLinearizationNode(self, doc):
                ln = doc.createElement("linearization")
                n = doc.createElement("version")
                ln.appendChild(n)
                n.appendChild(doc.createTextNode(str(int(self.relin_version))))
                if (self.relin_version == 1): 
                    n = doc.createElement("decomposition_bit_count")
                    ln.appendChild(n)
                    n.appendChild(doc.createTextNode(str(int(self.dbc))))
                elif (self.relin_version == 2):    
                    n = doc.createElement("coeff_modulo_log2")
                    ln.appendChild(n)
                    n.appendChild(doc.createTextNode(str(int(self.log2_p))))
                    ln.appendChild(self.createNormalDistributionNode(doc, sigma_k=self.mpf2intstr(self.sigma_k), bound_k=self.mpf2intstr(self.B_k)))
                return ln
                
        def createPrivateKeyNode(self, doc):
                skn = doc.createElement("secret_key")
                n = doc.createElement("hamming_weight")
                skn.appendChild(n)

                n.appendChild(doc.createTextNode(str(int(self._h))))
                return skn
    
        def createExtraNode(self,doc):
                en =  doc.createElement("extra") 

                n = doc.createElement("estimated_secu_level")
                en.appendChild(n)
                n.appendChild(doc.createTextNode(str(int(self._lambda_p))))

                n = doc.createElement("security_reduction")
                en.appendChild(n)
                n.appendChild(doc.createTextNode(self.security_reduction))
                
                n = doc.createElement("prv_key_distr")
                en.appendChild(n)
                n.appendChild(doc.createTextNode(str(self.prv_key_distr)))
                
                n = doc.createElement("n")
                en.appendChild(n)
                n.appendChild(doc.createTextNode(str(int(self.n))))                

                n = doc.createElement("nr_samples")
                en.appendChild(n)
                n.appendChild(doc.createTextNode(str(int(self.nr_samples))))  
                
                n = doc.createElement("alpha")
                en.appendChild(n)
                n.appendChild(doc.createTextNode(str(self.alpha)))

                n = doc.createElement("q_CINGULATA_BFV")
                en.appendChild(n)
                n.appendChild(doc.createTextNode(str(2)+"**"+str(self.log2_q)))
                
                n = doc.createElement("q_bitsize_SEAL_BFV")
                en.appendChild(n)
                n.appendChild(doc.createTextNode(str(CiphertextModulus(self.log2_q))))
                
                n = doc.createElement("t")
                en.appendChild(n)
                n.appendChild(doc.createTextNode(str(int(self.t))))                

                n = doc.createElement("modulus_level")
                en.appendChild(n)
                n.appendChild(doc.createTextNode(self.modulus_level))

                n = doc.createElement("method")
                en.appendChild(n)
                n.appendChild(doc.createTextNode(self.method))
                
                n = doc.createElement("bkz_reduction_cost_model")
                en.appendChild(n)
                n.appendChild(doc.createTextNode(eval(self.reduction_cost_model).__name__))
                return en      
      
      
        def getXml(self):
                doc = minidom.Document()

                params = doc.createElement("fhe_params")

                params.appendChild(self.createPolynomialRingNode(doc))
                params.appendChild(self.createPlaintextNode(doc))    
                params.appendChild(self.createCiphertextNode(doc))    
                params.appendChild(self.createLinearizationNode(doc))    
                params.appendChild(self.createPrivateKeyNode(doc))    
                params.appendChild(self.createExtraNode(doc))

                doc.appendChild(params)    

                return doc

class colors:
        MAGENTA = '\033[95m'
        BLUE = '\033[94m'
        GREEN = '\033[92m'
        YELLOW = '\033[93m'
        RED = '\033[91m'
        DEFAULT = '\033[0m'
        
def NoiseGaussianWidth(n,security_reduction):
    if (security_reduction == "yes"):    
        noise_Gaussian_width = RR(2*sqrt(n))                                  # Regev reduction, see [P16,pages 3,18]
    elif (security_reduction == "no"):
        noise_Gaussian_width = RR(8/sqrt(2*pi))                               # [CCDG17, page 16], practical choice
    return noise_Gaussian_width

def NrSamples(n,q,relin_version,dbc=None): # Scheme assumption: BFV is secure when the adversary has the relinearization/evaluation key.
    if relin_version == 1: # memory costly
        l = floor(log(q)/(log(2)*dbc), bits=1000)
        return (l+2)*n # l+1 LWE samples encoding the secret key are contained in the evaluation key, the public key is one LWE sample of the secret key (pessimistic approach). 
    elif relin_version == 2: # time costly
        return n # We do not consider the evaluation key parameters which involves a modulus switching (optimistic approach).

def log2(x):
    return ceil(log(x)/log(2)) 

def ScaleFactor(modulus_level,customsize):
    if (modulus_level == "bitsize"):
            scale_factor = 2
    elif (modulus_level == "bytesize"):
            scale_factor = 2**8            
    elif (modulus_level == "customsize"):
            scale_factor = 2**customsize
    elif (modulus_level == "wordsize"):
            scale_factor = 2**64
    return scale_factor
    
def MinCorrectModulus(n,t,noise_Gaussian_width,beta,prv_key_distr,mult_depth=10,cryptosystem="BFV",omega=32,customsize=64,modulus_level="bitsize"):  
# max_circuit_noise is an upper bound on the noise after evaluating a circuit of given multiplicative depth, neglicting homomorphic additions
# max_correctness_noise is an upper bound on the noise to guarantee correct decryption
    q = q_init
    first_pass = True
    B_key = prv_key_distr[0][1] if isinstance(prv_key_distr[0],tuple) else prv_key_distr[1] # Upper bound on prv_key_distr
    scale_factor=ScaleFactor(modulus_level,customsize)
    while first_pass or  (max_circuit_noise>=max_correctness_noise):
        first_pass = False      
        Delta = floor(q/t)
        l = ceil(log(q)/log(omega), bits=1000)
        B_error = ceil(beta * noise_Gaussian_width)                                             
        max_encryption_noise = B_error*(1+2*n*B_key)
        C = 2*n*(4+n*B_key)
        D = n^2*B_key*(B_key+4)+n*omega*l*B_error
        max_circuit_noise = C^mult_depth*max_encryption_noise+mult_depth*C^(mult_depth-1)*D
        max_correctness_noise = (Delta*(1+t)-q)/2
        q *= scale_factor
    q /= scale_factor
    return q

       
    
def MinSecureDegree(q,min_secu_level,prv_key_distr,reduction_cost_model,relin_version,security_reduction,dbc=None):
    n = n_init
    first_pass = True
    while first_pass or (estimated_secu_level<min_secu_level):
            first_pass=False
            noise_rate = NoiseGaussianWidth(n,security_reduction)/RR(q)
            nr_samples = NrSamples(n,q,relin_version,dbc)
            estimated_secu_level = SecurityLevel(n,q,noise_rate,nr_samples,current_model=reduction_cost_model,prv_key_distr=prv_key_distr)
            n *= 2
    n /= 2
    return n,estimated_secu_level,noise_rate
    
    
# selection of BKZ (lattice reduction) cost model 
bkz_enum = BKZ.enum    #https://bitbucket.org/malb/lwe-estimator.git   In April 2018, BKZ.enum is reduction_default_cost in lwe-estimator.
bkz_sieve = BKZ.sieve
core_sieve =  lambda beta, d, B: ZZ(2)**RR(0.292*beta)   #https://estimate-all-the-lwe-ntru-schemes.github.io/docs/        aka BKZ.ADPS16, mode="classical" [Becker Ducas Laarhoven Gama]
q_core_sieve =  lambda beta, d, B: ZZ(2)**RR(0.265*beta) #https://estimate-all-the-lwe-ntru-schemes.github.io/docs/        aka BKZ.ADPS16, mode="quantum" [Laarhoven Thesis]
paranoid_sieve =  lambda beta, d, B: ZZ(2)**RR(0.2075*beta) #called paranoid in LWE-Estimator and "best plausible" in New Hope paper


bkz_enum.__name__ = "BKZ.enum"
bkz_sieve.__name__ = "BKZ.sieve"
core_sieve.__name__ = "lambda beta, d, B: ZZ(2)**RR(0.292*beta)"
q_core_sieve.__name__ = "lambda beta, d, B: ZZ(2)**RR(0.265*beta)"
paranoid_sieve.__name__ = "lambda beta, d, B: ZZ(2)**RR(0.2075*beta)"
# beta: block size, d: LWE dimension, B: bit-size of entries        


    
def ChooseParam(method,t,min_secu_level,prv_key_distr,beta,security_reduction,relin_version,\
                mult_depth=10,cryptosystem="BFV",reduction_cost_model=core_sieve,omega=32,customsize=64,modulus_level="bitsize",dbc=None):
    first_pass = True
    if method == "min_modulus":
        n=n_init
        while first_pass or (estimated_secu_level<min_secu_level):
            first_pass = False
            noise_Gaussian_width=NoiseGaussianWidth(n,security_reduction)
            q = MinCorrectModulus(n,t,noise_Gaussian_width,beta,prv_key_distr,mult_depth,cryptosystem,omega,customsize,modulus_level)  # for fixed n, log2_q is minimized
            noise_rate = noise_Gaussian_width/RR(q)
            nr_samples = NrSamples(n,q,relin_version,dbc)
            estimated_secu_level = SecurityLevel(n,q,noise_rate,nr_samples,current_model=reduction_cost_model,prv_key_distr=prv_key_distr)
            n = 2*n
        n = n/2
    elif method == "min_degree":
        q=q_init            
        B_key = prv_key_distr[0][1] if isinstance(prv_key_distr[0],tuple) else prv_key_distr[1] # Upper bound on prv_key_distr   
        scale_factor=ScaleFactor(modulus_level,customsize)     
        while first_pass or  (max_circuit_noise>=max_correctness_noise):
            first_pass = False
            n,estimated_secu_level,noise_rate = MinSecureDegree(q,min_secu_level,prv_key_distr,reduction_cost_model,relin_version,security_reduction,dbc)
            Delta = floor(q/t)
            l = ceil(log(q)/log(omega), bits=1000)                               # [CCDG17, page 16], practical choice
            B_error = ceil(beta * NoiseGaussianWidth(n,security_reduction)/RR(q))          
            max_encryption_noise = B_error*(1+2*n*B_key)
            C = 2*n*(4+n*B_key)
            D = n^2*B_key*(B_key+4)+n*omega*l*B_error
            max_circuit_noise = C^mult_depth*max_encryption_noise+mult_depth*C^(mult_depth-1)*D
            max_correctness_noise = (Delta*(1+t)-q)/2             
            q = q*scale_factor
        q = q/scale_factor
    nr_samples = NrSamples(n,q,relin_version,dbc)
    return n,(estimated_secu_level,floor(log(q)/log(2), bits=1000)),q, noise_rate,nr_samples 
        
        
          

def Describe(x):
        return {
                bkz_enum:    "BKZ.enum",
                bkz_sieve:   "BKZ.sieve",
                core_sieve:  "Core-Sieve",    # aka BKZ.ADPS16, classical mode
                q_core_sieve:"Q-Core-Sieve",  # aka BKZ.ADPS16, quantum mode   
                paranoid_sieve:"Paranoid Sieve", # aka BKZ.ADPS16, paranoid mode  
                '_lambda_p':"security level",
                'L':"multiplicative depth",
                'sigma':"noise Gaussian width", 
                'sigma_k':"relin. v2 noise Gaussian width",
                'log2_sigma_k':"log_2(relin. v2 noise Gaussian width)", 
                'reduction_cost_model':"BKZ cost model", 
                'log2_q':"log_2(q)",  
        }.get(x, "42")   # default value


def SecurityLevel(n,q,alpha,nr_samples, current_model,prv_key_distr):
        ring_operations=primal_usvp(n, alpha, q, prv_key_distr, m=nr_samples, success_probability=0.99, reduction_cost_model=eval(current_model))["rop"] 
        #success_probability for the primal uSVP attack  
        secu_level= floor(log(ring_operations)/log(2))
        return secu_level    

def DistributionInfo(s):
    try: 
        minimum, maximum,Hamming_weight= map(int, s.split(','))
        return (minimum, maximum),Hamming_weight
    except:
            try:
                minimum, maximum=map(int, s.split(','))
                return minimum, maximum
            except:
                raise argparse.ArgumentTypeError("Distribution must be under the form:  Minimum,Maximum,(optionally Hamming weight of private key)")

#######
# Parse command line arguments
parser = argparse.ArgumentParser(
        description='Generate parameters (XML file) for FV homomorphic encryption scheme',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
        argument_default=argparse.SUPPRESS)

groupFile = parser.add_argument_group("configuration file input")
groupFile.add_argument('-c', '--config_file', help='Configuration file (XML)', type = argparse.FileType('r'))

        
groupArgs = parser.add_argument_group("command line input", "has priority over configuration file")
groupArgs.add_argument('--prv_key_distr', help='Private key distribution', default = ((0,1),63), type = DistributionInfo)
groupArgs.add_argument('--lambda_p', help='Security level', default = 128, type = int)
groupArgs.add_argument('--plaintext_modulus', help='Plaintext base', default = 2, type = int)
groupArgs.add_argument('--mult_depth', help='Multiplicative depth', default = 5, type = int)
groupArgs.add_argument('--eps_exp', help='Epsilon exponent', default = -64, type = int)
groupArgs.add_argument('--omega', help='Basis during gadget decomposition', default = 32, type = int)
groupArgs.add_argument('--modulus_level',help='Scale function of ciphertext modulus',default="bitsize", type = str, choices=["bitsize","bytesize","customsize","wordsize"]) 
# bitsize is slower but permits to increase database, customsize can be needed to be compatible with certain cryptosystem implementation (e.g Microsoft SEAL)
groupArgs.add_argument('--customsize',help='Ciphertext modulus bitsize increment',default=10, type = int) # Small increment value means slow and tight generation, especially with flag "min_degree". 
groupArgs.add_argument('--reduction_cost_model',help='BKZ cost model',default="bkz_sieve", type = str)
groupArgs.add_argument('--security_reduction',help='Parameters compatibility with Regev security reduction', default="yes", choices=["yes","no"], type = str)
# This string is either "no", then Gaussian width is set to 3.19. Or "yes" to use parameters compatible with Regev quantum security reduction proof.
groupArgs.add_argument('--relin_version',help='BFV relinearisation method', default = 1, type = int, choices = [1,2]) # This refers to the two methods in [FV12].
groupArgs.add_argument('--dbc',help='Decomposition bit count for the relin. v1', default = 60, type = int, choices = range(1, 61)) 
groupArgs.add_argument('--relin_k', help='Parameter k for the relin. v2', default = 4, type = int, choices=[4,5])
groupArgs.add_argument('--method',help='Minimize {degree,modulus} with fixed {modulus,degree}.', default="min_degree", choices=["min_modulus","min_degree"],type = str) 


groupOut = parser.add_argument_group("output")
groupOut.add_argument('--output_xml', help='Output parameters file', default = "fhe_params.xml", type = str)

try:
        values = parser.parse_args(sys.argv[1:])
except IOError as msg:
        parser.error(str(msg))

#Build parameters object
params = _Parameters()
if 'config_file' in values:
        params.parseXml(values.config_file.readlines())
params.updateParams(values.__dict__)
                           

#Generate homomorphic encryption scheme parameters
paramsGen = _ParametersGenerator(params)

n_init=2048
q_init=2**60 # For compatibility with SEAL v3.2, initial size is the smallest multiple of 10. It is greater than 54 (see [B18] p.76) for security>80 and to enable at least one homomorphic multiplication.

param_set=paramsGen.comp_params()

paramsGen.write()
xmlStr = paramsGen.getXml().toprettyxml()


f = open(params.output_xml, "w")
f.write(xmlStr)
f.close()





