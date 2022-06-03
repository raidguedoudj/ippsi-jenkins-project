#!/bin/bash

# Suppression du dossier du job précédent s'il existe

# Créer un dossier avec un nom unique basé sur le client-id

rm -rf /var/jenkins_home/archi
git clone ${ARCHI_GIT_URL} /var/jenkins_home/archi

mkdir GENERATED/

# Appeler check_env.sh
bash ./GENERATORS/check_env.sh
echo "Finished check_env"
# Appeler provider.sh
bash ./GENERATORS/provider.sh
echo "Finished provider"
# Appeler network.sh
bash ./GENERATORS/network.sh ${CLIENT_ID}
echo "Finished network"
# Appeler security_groups.sh
bash ./GENERATORS/security_groups.sh ${CLIENT_ID}
echo "Finished security_groups"
# Appeler instances.sh
bash ./GENERATORS/instances.sh
echo "Finished instances"

# Remplacer le INFRA_NAME dans tous les fichiers générés
find GENERATED/ -type f -name '*.tf' -exec sed -i "s|<##INFRA_NAME##>|${INFRA_NAME}|g" {} \;
echo "Finished INFRA_NAME"

# Faire un terraform apply

if [[ -d /var/jenkins_home/archi/${CLIENT_ID} ]]; then
    rm -rf /var/jenkins_home/archi/${CLIENT_ID}
else
    mkdir /var/jenkins_home/archi/${CLIENT_ID}
fi

mv GENERATED/*.tf /var/jenkins_home/archi/${CLIENT_ID}/

cp -r SCRIPTS/ /var/jenkins_home/archi/${CLIENT_ID}/

cd /var/jenkins_home/archi/${CLIENT_ID}/

terraform init
terraform apply -auto-approve

git add .
git commit -m "Added architecture of client : #${CLIENT_ID}"
git push

rm -rf /var/jenkins_home/archi


