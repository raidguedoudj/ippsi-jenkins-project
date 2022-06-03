#!/bin/bash

I=0
while read line
do
    if [ $I -gt 0 ]
    then
        if [ ! -z $line ]
        then
            INSTANCE_NAME=$(echo $line | cut -d";" -f1)
            SUBNET_NAME=$(echo $line | cut -d";" -f2)
            USER_DATA=$(echo $line | cut -d";" -f3)
            SGROUP=$(echo $line | cut -d";" -f4)
            PUBIP=$(echo $line | cut -d";" -f5)

            cp TEMPLATES/instance.template GENERATED/${INSTANCE_NAME}-instance.tf

            sed -i "s|<##INSTANCE_NAME##>|${INSTANCE_NAME}|g" GENERATED/${INSTANCE_NAME}-instance.tf
            sed -i "s|<##SUBNET_NAME##>|${SUBNET_NAME}|g" GENERATED/${INSTANCE_NAME}-instance.tf
            sed -i "s|<##USER_DATA##>|${USER_DATA}|g" GENERATED/${INSTANCE_NAME}-instance.tf
            sed -i "s|<##SECURITY_GROUP##>|${SGROUP}|g" GENERATED/${INSTANCE_NAME}-instance.tf
            sed -i "s|<##PUBLIC_IP##>|${PUBIP}|g" GENERATED/${INSTANCE_NAME}-instance.tf
        fi
    else
        I=1
    fi
done < instances_matrix

cat GENERATED/*-instance.tf >> GENERATED/instances.tf

rm GENERATED/*-instance.tf


