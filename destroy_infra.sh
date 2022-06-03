#!/bin/bash

# Récupérer le client-id pour faire un terraform destroy
# depuis le bon dossier.

bash ./GENERATORS/check_env.sh
echo "Finished check env"
cd /var/jenkins-home/archi/${CLIENT_ID}
terraform destroy
echo "Terraform destroyed for client : {$CLIENT_ID}"