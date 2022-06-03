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

            cat GENERATED/ingress.tf >> GENERATED/${SG_NAME}_ingress.tf
            echo "" >> GENERATED/${SG_NAME}_ingress.tf

            rm GENERATED/ingress.tf
        fi
    else
        I=1
    fi
done < flow_matrix.csv

cp TEMPLATES/egress.template GENERATED/egress.tf

for SGROUP in $(ls GENERATED/*_ingress.tf | cut -d "/" -f2 | cut -d "_" -f1)
do
    cp TEMPLATES/security_group.template GENERATED/${SGROUP}.tf

    sed -i "s|<##SECURITY_GROUP##>|${SGROUP}|g" GENERATED/${SGROUP}.tf

    cat GENERATED/${SGROUP}_ingress.tf >> GENERATED/rules.tf
    cat GENERATED/egress.tf >> GENERATED/rules.tf

    # RULES_TEMP=$(<GENERATED/rules.tf)

    # sed -i "s|<##SECURITY_GROUP_RULES##>|${RULES_TEMP}|g" GENERATED/${SGROUP}.tf

    LTOWRITE=$(cat -n GENERATED/${SGROUP}.tf | grep "<##SECURITY_GROUP_RULES##>" | sed 's|\t| |g' | tr -s " " | cut -d" " -f2)

    echo $LTOWRITE

    sed -i "${LTOWRITE} r GENERATED/rules.tf" GENERATED/${SGROUP}.tf
    sed -i "s|<##SECURITY_GROUP_RULES##>||g" GENERATED/${SGROUP}.tf

    cat GENERATED/${SGROUP}.tf >> GENERATED/security_groups.tf

    # clean generated files
    rm GENERATED/${SGROUP}.tf
    rm GENERATED/${SGROUP}_ingress.tf
    rm GENERATED/rules.tf
done

rm GENERATED/egress.tf

