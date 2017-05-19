#!/bin/bash    

source ./cs253-vars.sh

if [ ! -d nec ] && [ ! -d data ] ; then 
     mkdir enc data
fi

# 1. PREPARE LENA IMAGE
# Download Lena image if not present
if [ ! -f ${LENA} ]; then 
     printf "\nDownloading file from http://www.ece.rice.edu/~wakin/images/lena512color.tiff...\n"
     printf "\$ curl -o ${LENA} http://www.ece.rice.edu/~wakin/images/lena512color.tiff\n\n"
     curl -o ${LENA} http://www.ece.rice.edu/~wakin/images/lena512color.tiff
     printf "DONE.\n\n"
fi

# 2. SYMMETRIC ENCRYPTION
# Perform symmetric encryption using AES-128-ECB on the LENA image
if [ ! -f ${LENA_ecb} ] ; then 
     printf "Encrypting LENA image with AES-128-ECB...\n"
     openssl enc -aes-128-ecb -e -in ${LENA} -out ${LENA_ecb} -K ${AES_KEY}
     printf "\$ openssl enc -aes-128-ecb -e -in ${LENA} -out ${LENA_ecb} -K ${AES_KEY}\n"
     printf "DONE.\n\n"
fi 

# Perform symmetric encryption using AES-128-CBC on the image
if [ ! -f ${LENA_cbc} ] ; then 
     printf "Encrypting LENA image with AES-128-CBC...\n"
     openssl enc -aes-128-cbc -e -in ${LENA} -out ${LENA_cbc} -K ${AES_KEY} -iv ${AES_IV}
     printf "\$ openssl enc -aes-128-cbc -e -in ${LENA} -out ${LENA_cbc} -K ${AES_KEY} -iv ${AES_IV}\n"
     printf "DONE.\n\n"
fi 

# 3. HASHING 
# Perform hashing on the LENA image
if [ ! -f ${LENA_hash} ] ; then 
     printf "Generating SHA-1, SHA-256, and SHA-512 for LENA...\n"
     printf "\$ openssl dgst -sha1 ${LENA}\n"
     openssl dgst -sha1 ${LENA} | tee ${LENA_hash}
     printf "\$ openssl dgst -sha256 ${LENA} >> ${LENA_hash}\n"
     openssl dgst -sha256 ${LENA} | tee -a ${LENA_hash}
     printf "\$ openssl dgst -sha512 ${LENA} >> ${LENA_hash}\n"
     openssl dgst -sha512 ${LENA} | tee -a ${LENA_hash}
     printf "DONE.\n\n"
fi 

# 4.  PUBLIC KEY ENCRYPTION
#  Generate RSA private key 
if [ ! -f ${PRIV_RSA_KEY} ] ; then
     printf "Create RSA keypair...\n"
     printf "Generating RSA private key...\n"
     printf "\$ openssl genrsa -aes256 -out ${PRIV_RSA_KEY} -passout pass:${PASSPHRASE} 2048\n"
     openssl genrsa -aes256 -out ${PRIV_RSA_KEY} -passout pass:${PASSPHRASE} 2048
     openssl rsa -in ${PRIV_RSA_KEY} -text -noout -passin pass:${PASSPHRASE}
     printf "DONE.\n\n"
fi 
# 4.b Extract RSA public key
if [ ! -f ${PUB_RSA_KEY} ] ; then 
     printf "Extracting RSA public key...\n"
     printf "\$ openssl rsa -in ${PRIV_RSA_KEY} -outform PEM -pubout -out ${PUB_RSA_KEY} -passin pass:${PASSPHRASE}\n"
     openssl rsa -in ${PRIV_RSA_KEY} -outform PEM -pubout -out ${PUB_RSA_KEY} -passin pass:${PASSPHRASE}
     openssl rsa -in ${PUB_RSA_KEY} -pubin -text -noout -passin pass:${PASSPHRASE}
     printf "DONE.\n\n"
fi 
# 4.c Encrypt LENA using RSA
# Not possible to directly encrypt large files 
# Normal practice is to encrypt the keyfile containing the passphrase using AES
if [ ! -f ${SECRET_FILE} ] ; then 
     printf "Generating a 1024 bit random key...\n"
     printf "openssl rand -base64 128 > ${SECRET_FILE}\n"
     openssl rand -base64 128 | tee ${SECRET_FILE} 
     printf "DONE.\n\n"
fi 

if [ ! -f ${SECRET_ENC} ] ; then 
     printf "Encrypting secret keyfile using RSA-2048 public key...\n"
     printf "openssl rsautl -encrypt -inkey ${PUB_RSA_KEY} -pubin -in ${SECRET_FILE} -out ${SECRET_ENC}\n"
     openssl rsautl -encrypt -inkey ${PUB_RSA_KEY} -pubin -in ${SECRET_FILE} -out ${SECRET_ENC} 
     printf "DONE.\n\n"
fi

if [ ! -f ${LENA_rsa} ] ; then 
     printf "Encrypting LENA image with AES-128-cbc using secret plaintext key...\n"
     openssl enc -aes-128-cbc -e -in ${LENA} -out ${LENA_rsa} -pass file:${SECRET_FILE}
     printf "\$ openssl enc -aes-128-cbc -e -in ${LENA} -out ${LENA_rsa} -pass file:${SECRET_FILE}\n"
     printf "DONE.\n\n"
fi

#openssl rsautl -encrypt -inkey ${PUB_RSA_KEY} -pubin -in ${LENA} -out ${LENA_rsa} 

# 4.d Digital signing using ECDSA
if [ ! -f ${PRIV_ECDSA_KEY} ] ; then 
     printf "Create ECDSA keypair...\n"
     printf "Generating ECDSA private key...\n"
     printf "\$ openssl ecparam -genkey -name secp384r1 -noout -out ${PRIV_ECDSA_KEY}\n"
     openssl ecparam -genkey -name secp384r1 -noout -out ${PRIV_ECDSA_KEY} 
     openssl ec -in ${PRIV_ECDSA_KEY} -text -noout
     printf "DONE.\n\n" 
fi 
     
if [ ! -f ${PUB_ECDSA_KEY} ] ; then 
     printf "Extracting ECDSA public key...\n"
     printf "\$ openssl ec -in ${PRIV_ECDSA_KEY} -pubout -out ${PUB_ECDSA_KEY}\n"
     openssl ec -in ${PRIV_ECDSA_KEY} -pubout -out ${PUB_ECDSA_KEY}
     openssl ec -in ${PUB_ECDSA_KEY} -pubin -text -noout
     printf  "DONE.\n\n"
fi

if [ ! -f ${LENA_sign} ] ; then 
     printf "Digitally sign the SHA-256 digest of the LENA image...\n"
     printf "\$ openssl dgst -sha256 -sign ${PRIV_ECDSA_KEY} ${LENA}\n"
     openssl dgst -sha256 -sign ${PRIV_ECDSA_KEY} ${LENA} > ${LENA_sign}
     openssl dgst -sha256 -hex -sign ${PRIV_ECDSA_KEY} ${LENA}
     hexdump ${LENA_sign}
     printf "DONE.\n\n"
fi 

sleep 1
