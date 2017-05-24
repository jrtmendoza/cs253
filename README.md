Code repository for the final project on CS253 Computer Security handled by Dr. Susan Pancho-Festin

# Cryptography Exercises using OpenSSL 
1. To get started, clone the repository: 

$ git clone https://github.com/jrtmendoza/cs253.git

2. Set up the working directory

cd cs253 ; ./make clean

3. Execute the cs253-encrypt
 
$ bash ./cs253-encrypt.sh

The script requires Internet connectivity to run. Two directories will be created on the same directory where the script is called. The first routine will download the LENA image from a remote URL and execute the commands needed for the OpenSSL exercises specified in the project requirements.  The code is written in bash and tested on Ubuntu 16.04 64-bit Desktop. The routines in the script make use of other command line tools aside from OpenSSL to perform some verification functions. 

4. Verify the output 

$ bash ./cs253-check.sh
