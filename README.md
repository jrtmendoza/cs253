Code repository for the final project on CS253 Computer Security handled by Dr. Susan Pancho-Festin

# Cryptography Exercises using OpenSSL 
1. To get started, clone the repository: 

$ git clone https://github.com/jrtmendoza/cs253.git

2. Set up the environment by executing first ./make 

3. Execute the cs253-encrypt
 
$ bash ./cs253-encrypt.sh

The script requires Internet connectivity to run. Two directories will be created on the same directory where the script is called. The first routine will download the LENA image from a remote URL and execute the commands needed for the OpenSSL exercises specified in the project requirements. 

4. Verify the correctness of the encryption procedure by running ./cs253-check.sh
