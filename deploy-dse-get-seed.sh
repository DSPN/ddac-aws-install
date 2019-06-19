#!/usr/bin/env bash
# cluster name, datacenter name and seed nodes from ARM
echo "deploy-dse-get-seed $1 $2 $3 $4"
region=$1
dbtable=$2
cluster_name=$3
dc=$4

privip1=`aws dynamodb scan --region "$1" --table-name "$2" --scan-filter '{
        "node-type":{
            "AttributeValueList":[ {"S":"seednode1"} ],
            "ComparisonOperator": "EQ"
        }
    }' | jq '.Items[0]["private-ip"]["S"]'`

privip2=`aws dynamodb scan --region "$1" --table-name "$2" --scan-filter '{
        "node-type":{
            "AttributeValueList":[ {"S":"seednode2"} ],
            "ComparisonOperator": "EQ"
        }
    }' | jq '.Items[0]["private-ip"]["S"]'`
seeds="${privip1//\"}","${privip2//\"}"

# create directories and soft links on mounted storage
/home/ddac/dse-vm-dir-creations.sh &
dir_process_id=$!
wait $dir_process_id

echo "dse-init.sh $cluster_name $dc $seeds"

/home/ddac/dse-init.sh $cluster_name $dc $seeds &
dse_init_process_id=$!
wait $dse_init_process_id
echo "deploy-dse ------> exit status $?"
