#!/bin/bash

# Suppression du dossier du job précédent s'il existe

# Créer un dossier avec un nom unique basé sur le client-id

git clone ${ARCHI_GIT_URL} /var/jenkins_home/archi

mkdir GENERATED/

# Appeler check_env.sh
bash ./GENERATORS/check_env.sh
# Appeler provider.sh
bash ./GENERATORS/provider.sh
# Appeler network.sh
bash ./GENERATORS/network.sh ${CLIENT_ID}
# Appeler security_groups.sh
bash ./GENERATORS/security_groups.sh ${CLIENT_ID}
# Appeler instances.sh
bash ./GENERATORS/instances.sh

# Remplacer le INFRA_NAME dans tous les fichiers générés
find GENERATED/ -type f -name '*.tf' -exec sed -i 's|<##INFRA_NAME##>|${INFRA_NAME}|g' {} \;

# Faire un terraform apply

if [[ -d /home/archi/${CLIENT_ID} ]]; then
    rm -rf /home/archi/${CLIENT_ID}
else
    mkdir /home/archi/${CLIENT_ID}
fi

mv GENERATED/*.tf /home/archi/${CLIENT_ID}/

cd /home/archi/${CLIENT_ID}/

# terraform init
# terraform apply -auto-approve

# cd /home/archi

# git add .
# git commit ...
# rm -rf /home/archi

