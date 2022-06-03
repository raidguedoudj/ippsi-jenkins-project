#!/bin/bash

# Récupérer le client-id pour faire un terraform destroy
# depuis le bon dossier.

bash ./GENERATORS/check_env.sh
echo "Finished check env"
git clone ${ARCHI_GIT_URL} /var/jenkins_home/archi
cd /var/jenkins_home/archi/${CLIENT_ID}
terraform destroy -auto-approve
echo "Terraform destroyed for client : {$CLIENT_ID}"
