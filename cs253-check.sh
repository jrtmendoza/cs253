#!/bin/bash 

source ./cs253-vars.sh

function bar_delim () {
     echo "===================================================================================================="
}

function verify_hash () { 
   
     chksum1=$(sha256sum $1 | cut -d " " -f 1)
     chksum2=$(sha256sum $2 | cut -d " " -f 1)
     
     if [[ "${chksum1}" == "${chksum2}" ]] ; then 
	 echo ${chksum1} $1 
	 echo ${chksum2} $2
     fi 
}

if [ ! -d enc ] && [ ! -d data ] ; then 
     printf "\nPlease run cs253-encrypt.sh first before executing this script.\n\n" 
     exit 1
fi 


if [ ! -d dec ] ; then 
     mkdir dec
fi
   
if [ ! -f ${LENA_ecb_d} ] ; then 
     printf "\nAttempting to decrypt LENA image using AES-256-ECB with key ${AES_KEY}...\n" 
     openssl enc -aes-128-ecb -d -in ${LENA_ecb} -out ${LENA_ecb_d} -K ${AES_KEY}
     printf "\$ openssl enc -aes-128-ecb -d -in ${LENA_ecb} -out ${LENA_ecb_d} -K ${AES_KEY}\n"
     printf "OK.\n\n"
     printf "Verifying if the decrypted image is identical to the original ${LENA}...\n"
     verify_hash ${LENA} ${LENA_ecb_d}
     printf "OK.\n"
     if [ $? -eq 0 ] ; then 
	printf "\nThe hashes of the original LENA image ${LENA} and decrypted ${LENA_ecb_d} match!\n\n"
        bar_delim
     fi 
fi 

if [ ! -f ${LENA_cbc_d} ] ; then
     printf "\nAttempting to decrypt LENA image using AES-256-CBC with key ${AES_KEY} and iv ${AES_IV}... \n"
     openssl enc -aes-128-cbc -d -in ${LENA_cbc} -out ${LENA_cbc_d} -K ${AES_KEY} -iv ${AES_IV}
     printf "\$ openssl enc -aes-128-cbc -d -in ${LENA_cbc} -out ${LENA_cbc_d} -K ${AES_KEY} -iv ${AES_IV}\n"
     printf "OK.\n\n"
     printf "Verifying if the decrypted image is identical to the original ${LENA}...\n"
     verify_hash ${LENA} ${LENA_cbc_d}
     printf "OK.\n"
     if [ $? -eq 0 ] ; then
        printf "\nThe hashes of the original LENA image ${LENA} and decrypted ${LENA_cbc_d} match!\n\n"
        bar_delim
     fi
fi


if [ ! -f ${LENA_rsa_d} ] ; then 
     printf "\nAttempting to decrypt ${LENA_rsa} using RSA keys and AES-128-CBC... \n"
     printf "Decrypt the text file containing the secret key used for encrypting the LENA image.\n"
     openssl rsautl -decrypt -inkey ${PRIV_RSA_KEY} -in ${SECRET_ENC} -out ${SECRET_DEC} -passin pass:${PASSPHRASE}
     printf "\$ openssl rsautl -decrypt -inkey ${PRIV_RSA_KEY} -in ${SECRET_ENC} -out ${SECRET_DEC} -passin pass:${PASSPHRASE}\n"
     openssl enc -aes-128-cbc -d -in ${LENA_rsa} -out ${LENA_rsa_d} -pass file:${SECRET_DEC}
     printf "\$ openssl enc -aes-128-cbc -d -in ${LENA_rsa} -out ${LENA_rsa_d} -pass file:${SECRET_DEC}\n"
     printf "OK.\n\n" 
     printf "Verifying if the decrypted image is identical to the original ${LENA}...\n"
     verify_hash ${LENA} ${LENA_rsa_d}
     printf "OK.\n"
     if [ $? -eq 0 ] ; then
        printf "\nThe hashes of the original LENA image ${LENA} and decrypted ${LENA_rsa_d} match!\n\n"
	bar_delim
     fi
fi

if [ -f ${LENA_sign} ] && [ -f ${PUB_ECDSA_KEY} ] ; then 
     printf "\nAttempting to verify the digital signature ${LENA_sign} on ${LENA} usin ${PUB_ECDSA_KEY}...\n"
     printf "\$ openssl dgst -sha256 -verify ${PUB_ECDSA_KEY} -signature ${LENA_sign} ${LENA}\n"
     openssl dgst -sha256 -verify ${PUB_ECDSA_KEY} -signature ${LENA_sign} ${LENA}
     printf "\n"
fi  
