#!/bin/bash

I=0
while read line
do
    if [ $I -gt 0 ]
    then
        if [ ! -z $line ]
        then
            SG_NAME=$(echo $line | cut -d";" -f1)
            PORT=$(echo $line | cut -d";" -f2)
            FROM_PORT=$(echo $PORT | cut -d"-" -f1)
            TO_PORT=$(echo $PORT | cut -d"-" -f2)

            if [ -z $TO_PORT ]
            then
                TO_PORT=$FROM_PORT
            fi

            PROTOCOL=$(echo $line | cut -d";" -f3)
            TYPE=$(echo $line | cut -d";" -f4)
            SOURCE=$(echo $line | cut -d";" -f5)

            cp TEMPLATES/ingress.template GENERATED/ingress.tf

            sed -i "s|<##FROM_PORT##>|${FROM_PORT}|g" GENERATED/ingress.tf
            sed -i "s|<##TO_PORT##>|${TO_PORT}|g" GENERATED/ingress.tf
            sed -i "s|<##PROTOCOL##>|${PROTOCOL}|g" GENERATED/ingress.tf

            if [ "$TYPE" == "SG" ]
            then
                SG_TYPE="security_groups"
                SG_BLOCK="\$\{aws_security_group.${SOURCE}.id\}"
            else
                SG_TYPE="cidr_blocks"
                SG_BLOCK="${SOURCE}"
            fi

            sed -i "s|<##SG_TYPE##>|${SG_TYPE}|g" GENERATED/ingress.tf
            sed -i "s|<##SG_BLOCK##>|${SG_BLOCK}|g" GENERATED/ingress.tf

            cat GENERATED/ingress.tf >> GENERATED/${SG_NAME}-ingress.tf
            echo "" >> GENERATED/${SG_NAME}-ingress.tf

            rm GENERATED/ingress.tf
        fi
    else
        I=1
    fi
done < flow_matrix.csv

cp TEMPLATES/egress.template GENERATED/egress.tf

for SGROUP in $(ls *-ingress.tf)
do
    cp TEMPLATES/security_group.template GENERATED/${SGROUP}.tf

    cat GENERATED/${SGROUP}-ingress.tf >> GENERATED/rules.tf
    cat GENERATED/egress.tf >> GENERATED/rules.tf

    RULES_TEMP=$(<GENERATED/rules.tf)

    sed -i "s|<##SECURITY_GROUP_RULES##>|${RULES_TEMP}|g" GENERATED/${SGROUP}.tf
    cat GENERATED/${SGROUP}.tf >> GENERATED/security_groups.tf

    rm GENERATED/${SGROUP}.tf
done

