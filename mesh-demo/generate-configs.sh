#!/bin/sh



# This script is used to generate a set of ActiveMQ Artemis configuration files
# which are then used by the brokers for inbound/outbound message routing
# If you want to extend the demo, you can use this script to customise the config.

function configure_broker_outgoing_addresses() {
  IFS=',' read -a addresses <<< ${other_addresses}
  local outgoing_addresses

  for address in ${addresses[@]}; do
    outgoing_addresses="${outgoing_addresses}\n\n\
        <address name=\"${address}\">\n\
          <multicast>\n\
            <queue name=\"${address}\"/>\n\
          </multicast>\n\
        </address>"
  done

  sed -i "s|<!-- ### OUTGOING_ADDRESSES ### -->|${outgoing_addresses}|" $broker_config_file
}

function configure_broker_incoming_addresses() {
  IFS=',' read -a addresses <<< ${this_address}
  local incoming_addresses

  for address in ${addresses[@]}; do
    incoming_addresses="${incoming_addresses}\n\n\
        <divert name=\"uni-diver-${address}\">\n\
           <address>${address}</address>\n\
           <forwarding-address>AppIncomingWorkQueue</forwarding-address>\n\
           <exclusive>true</exclusive>\n\
        </divert>"
  done

  sed -i "s|<!-- ### INCOMING_ADDRESSES ### -->|${incoming_addresses}|" $broker_config_file
}

function configure_broker_name() {
  sed -i "s|### LOCAL_BROKER_NAME ###|${broker_name}|" $broker_config_file
}

function configure_router_local_connector() {
  local broker_connector

  broker_connector="connector {\n\
    name: ${local_broker_connector}\n\
    host: ${local_broker_host}\n\
    port: ${local_broker_port}\n\
    role: route-container\n\
    saslMechanisms: plain\n\
    saslUsername: ${local_broker_username}\n\
    saslPassword: ${local_broker_password}\n\
}"

  sed -i "s|## LOCAL_BROKER_CONNECTOR ##|${broker_connector}|" $qdrouterd_config_file
}

function configure_router_mesh_connector() {
  local mesh_connector

  mesh_connector="connector {\n\
    name: mesh-routing-tier\n\
    host: ${mesh_router_host}\n\
    port: ${mesh_router_port}\n\
    role: inter-router\n\
    saslMechanisms: ANONYMOUS\n\
}"

  sed -i "s|## MESH_ROUTER_CONNECTOR ##|${mesh_connector}|" $qdrouterd_config_file
}


function configure_router_autolinks_in() {
  local autolinks_in
  IFS=',' read -a addresses <<< ${other_addresses}

  for address in ${addresses[@]}; do
    autolinks_in="${autolinks_in}\n\n\
autoLink {\n\
    addr: ${address}\n\
    connection: ${local_broker_connector}\n\
    direction: in\n\
    phase: 0\n\
    externalAddr: ${address}::${address}\n\
}"
  done

  sed -i "s|## AUTOLINKS_IN ##|${autolinks_in}|" $qdrouterd_config_file
}

function configure_router_autolinks_out() {
  local autolinks_out

  # An OUT autolink directs messages into the local Broker
  IFS=',' read -a addresses <<< ${this_address}

  for address in ${addresses[@]}; do
    autolinks_out="${autolinks_out}\n\n\
autoLink {\n\
    addr: ${address}\n\
    connection: ${local_broker_connector}\n\
    direction: out\n\
    phase: 0\n\
}\n"
  done

  sed -i "s|## AUTOLINKS_OUT ##|${autolinks_out}|" $qdrouterd_config_file
}

function configure_router_waypoint() {
  sed -i "s|## WAYPOINT ##|address {\n\
    pattern: ${waypoint}\n\
    waypoint: yes\n\
}|" $qdrouterd_config_file
}


generated_configs_dir=.generated-configs


# Delete dir if it already exists
if [ -d "$generated_configs_dir" ]; then rm -Rf $generated_configs_dir; fi
mkdir -p $generated_configs_dir

# Set up some variables
broker_tpl_file=broker.xml.tpl
qdrouterd_tpl_file=qdrouterd.conf.tpl
waypoint=acme.corp
local_broker_connector=local-amq-broker


# Create broker config file for central
broker_config_file=$generated_configs_dir/broker.central.xml
qdrouterd_config_file=$generated_configs_dir/qdrouterd.central.conf
broker_name=central-broker
other_addresses=acme.corp.sydney,acme.corp.london,acme.corp.singapore
this_address=acme.corp.central
local_broker_host=central-broker-amqp
local_broker_port=5672
local_broker_username=amq-demo-user
local_broker_password=password
#mesh_router_host=amq-interconnect.amq-router001.svc.cluster.local
# TODO update this if we're going to deploy in different namespaces
mesh_router_host=mesh-router
mesh_router_port=55672
cp $broker_tpl_file $broker_config_file
cp $qdrouterd_tpl_file $qdrouterd_config_file
configure_broker_name
configure_broker_outgoing_addresses
configure_broker_incoming_addresses
configure_router_local_connector
configure_router_mesh_connector
configure_router_waypoint
configure_router_autolinks_in
configure_router_autolinks_out



# Create broker config file for singapore
broker_config_file=$generated_configs_dir/broker.singapore.xml
qdrouterd_config_file=$generated_configs_dir/qdrouterd.singapore.conf
broker_name=singapore-broker
other_addresses=acme.corp.central,acme.corp.london,acme.corp.sydney
this_address=acme.corp.singapore
local_broker_host=singapore-broker-amqp
local_broker_port=5672
local_broker_username=amq-demo-user
local_broker_password=password
#mesh_router_host=amq-interconnect.amq-router001.svc.cluster.local
# TODO update this if we're going to deploy in different namespaces
mesh_router_host=mesh-router
mesh_router_port=55672
cp $broker_tpl_file $broker_config_file
cp $qdrouterd_tpl_file $qdrouterd_config_file
configure_broker_name
configure_broker_outgoing_addresses
configure_broker_incoming_addresses
configure_router_local_connector
configure_router_mesh_connector
configure_router_waypoint
configure_router_autolinks_in
configure_router_autolinks_out




# Create broker config file for london
broker_config_file=$generated_configs_dir/broker.london.xml
qdrouterd_config_file=$generated_configs_dir/qdrouterd.london.conf
broker_name=london-broker
other_addresses=acme.corp.central,acme.corp.singapore,acme.corp.sydney
this_address=acme.corp.london
local_broker_host=london-broker-amqp
local_broker_port=5672
local_broker_username=amq-demo-user
local_broker_password=password
#mesh_router_host=amq-interconnect.amq-router001.svc.cluster.local
# TODO update this if we're going to deploy in different namespaces
mesh_router_host=mesh-router
mesh_router_port=55672
cp $broker_tpl_file $broker_config_file
cp $qdrouterd_tpl_file $qdrouterd_config_file
configure_broker_name
configure_broker_outgoing_addresses
configure_broker_incoming_addresses
configure_router_local_connector
configure_router_mesh_connector
configure_router_waypoint
configure_router_autolinks_in
configure_router_autolinks_out


# Create broker config file for sydney
broker_config_file=$generated_configs_dir/broker.sydney.xml
qdrouterd_config_file=$generated_configs_dir/qdrouterd.sydney.conf
broker_name=sydney-broker
other_addresses=acme.corp.central,acme.corp.london,acme.corp.singapore
this_address=acme.corp.sydney
local_broker_host=sydney-broker-amqp
local_broker_port=5672
local_broker_username=amq-demo-user
local_broker_password=password
#mesh_router_host=amq-interconnect.amq-router001.svc.cluster.local
# TODO update this if we're going to deploy in different namespaces
mesh_router_host=mesh-router
mesh_router_port=55672
cp $broker_tpl_file $broker_config_file
cp $qdrouterd_tpl_file $qdrouterd_config_file
configure_broker_name
configure_broker_outgoing_addresses
configure_broker_incoming_addresses
configure_router_local_connector
configure_router_mesh_connector
configure_router_waypoint
configure_router_autolinks_in
configure_router_autolinks_out
