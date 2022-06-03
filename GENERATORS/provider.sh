#!/bin/bash


# Faire un terraform apply

source /var/jenkins_home/.aws_credentials

cp TEMPLATES/provider.template GENERATED/provider.tf
sed -i "s|<##ACCESS_KEY##>|${ACCESS_KEY}|g" GENERATED/provider.tf
sed -i "s|<##SECRET_KEY##>|${SECRET_KEY}|g" GENERATED/provider.tf

