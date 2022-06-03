#!/bin/bash

CLIENT_ID=$1

echo -n "Creating Network Things..."

cp TEMPLATES/network.template GENERATED/01-network.tf

sed -i "s|<##CLIENT_ID##>|${CLIENT_ID}|g" GENERATED/01-network.tf


