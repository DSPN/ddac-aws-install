#!/usr/bin/env bash
# 1st param are seed nodes
# 2nd param is cluster name
# 3rd param is the private ip of node
seed="$1"
cluster_name="$2"
node_ip="$3"

# cassandra.yaml settings for an initial cluster deployment
# currently these are not coming from ARM UI but could in future
# snitch of choice for Azure
endpoint_snitch="GossipingPropertyFileSnitch"
# DataStax recommends using 8 vnodes (tokens). 
# This distributes the workload between systems with a ~10% variance and has minimal impact on performance.
num_tokens=64
# Adjusts the sensitivity of the failure detector on an exponential scale. 
phi_convict_threshold=12
# when initializing a fresh cluster without data, add auto_bootstrap: false.
auto_bootstrap="false"
# This parameter is designed for use with large partitions. 
# The database throttles compaction to this rate across the entire system
compaction_throughput_mb_per_sec=64
# When set to true, causes fsync to force the operating system to flush 
# the dirty buffers at the set interval trickle_fsync_interval_in_kb
trickle_fsync=true

# backup original
file1="/usr/share/dse/conf/cassandra.yaml"
backup1="$file1.bak"
cp $file1 $backup1

# 2 seed nodes spread across 2 fault domains
sed -i 's/seeds: "127.0.0.1"/seeds: "'"$seed"'"/' "$file1"
# cluster name from ARM UI
sed -i "s/cluster_name: 'Test Cluster'/cluster_name: '$cluster_name'/" "$file1"
# private IP of vm generated from cli metadata server call
sed -i 's/listen_address: localhost/listen_address: '"$node_ip"'/' "$file1"
# private IP of vm generated from cli metadata server call
sed -i 's/rpc_address: localhost/rpc_address: '"$node_ip"'/' "$file1"
# private IP of vm generated from cli metadata server call
sed -i 's/native_transport_address: localhost/native_transport_address: '"$node_ip"'/' "$file1"
# see above
sed -i 's/num_tokens: 256/num_tokens: '"$num_tokens"'/' "$file1"
# see above
sed -i 's/compaction_throughput_mb_per_sec: 16/compaction_throughput_mb_per_sec: '"$compaction_throughput_mb_per_sec"'/' "$file1"
# see above
sed -i 's/trickle_fsync: false/trickle_fsync: '"$trickle_fsync"'/' "$file1"
# see above
sed -i 's/endpoint_snitch: SimpleSnitch/endpoint_snitch: '"$endpoint_snitch"'/' "$file1"
# see above
echo "auto_bootstrap: $auto_bootstrap" >> "$file1"
echo "phi_convict_threshold: $phi_convict_threshold" >> "$file1"
echo "data_file_directories:" >> "$file1"
echo "- /var/lib/cassandra/data" >> "$file1"
echo "commitlog_directory: /var/lib/cassandra/commitlog" >> "$file1"
echo "saved_caches_directory: /var/lib/cassandra/saved_caches" >> "$file1"
echo "hints_directory: /var/lib/cassandra/hints" >> "$file1"
echo "cdc_raw_directory: /var/lib/cassandra/cdc_raw" >> "$file1"


chown cassandra $file1
chgrp cassandra $file1
echo "dse-vm-cassandra-props ------> exit status $?"
