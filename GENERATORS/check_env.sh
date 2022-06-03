#!/bin/bash

FLAG=0

which terraform > /dev/null 2>&1 || FLAG=1

if [ $FLAG -eq 0 ]
then
    echo "Environment is ready."
    exit 0
else
    echo "Environment is not ready (Terraform missing)."
    sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
    sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
    sudo apt-get update && sudo apt-get install terraform
    FLAG=0
    which terraform > /dev/null 2>&1 || FLAG=1
    if [ $FLAG -eq 0 ]
    then
        echo "Environment is now ready !"
        exit 0
    else
        echo "Failed to install Terraform..."
        exit 1
    fi
fi


which git > /dev/null 2>&1 || FLAG=1

if [ $FLAG -eq 0 ]
then
    echo "Environment [git] is ready."
    exit 0
else
    echo "Environment [git] is not ready (Git missing)."
    sudo apt-get update && sudo apt-get install -y git

    FLAG=0
    which git > /dev/null 2>&1 || FLAG=1
    if [ $FLAG -eq 0 ]
    then
        echo "Environment [git] is now ready !"
        exit 0
    else
        echo "Failed to install Git..."
        exit 1
    fi
fi
