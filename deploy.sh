#!/bin/sh

usage() {     
  echo "Usage: `basename $0` target_host token env sfx_monitored

  * target_host:   The host to deploy signaflx
  * token:         Token for the agent 
  * env:           Env to set for signalfx dimension
  * sfx_monitored: true or false - for agent dimension" 
} 

if [ $# -lt 3 ] 
then     
  usage     
  exit 1 
fi

target_host=$1
token=$2
env=$3
sfx_monitored=$4

package="https://github.com/signalfx/signalfx-agent/releases/download/v5.7.1/signalfx-agent-5.7.1.tar.gz"
config=
systemyaml=
INITSCRIPT="signalfx-agent"
CONFIG="agent.yaml"
SYSTEMYAML="system.yaml"

if [ -f $AGENT ] 
then
  echo -e "Getting SmartAgent"
  wget https://github.com/signalfx/signalfx-agent/releases/download/v5.7.1/signalfx-agent-5.7.1.tar.gz
fi
if [ -f $INITSCRIPT ] 
then
  echo -e "Getting INITSCRIPT"
  wget 
fi
if [ -f $CONFIG ] 
then
  echo -e "Getting CONFIG"
  wget 
fi
if [ -f $SYSTEMYAML ] 
then
  echo -e "Getting SYSTEMYAML"
  wget 
fi

echo -e "Setting variable in config file"
sed -i "s/TOKEN/${token}/g" $CONFIG
sed -i "s/ENVIRONMENT/${env}/g" $CONFIG
sed -i "s/SFXMONITORED/${sfx_monitored}/g" $CONFIG

echo -e "Uploading to target ${target_host}"
scp signalfx-agent-5.7.1.tar.gz $target_host:/tmp/

echo -e "Unpacking smartagent on target host"
ssh $target_host "tar -xzf /tmp/signalfx-agent-5.7.1.tar.gz --directory /opt"

echo -e "Copying init script to ${target_host}"
scp $INITSCRIPT $target_host:/etc/init.d/

echo -e "creating signalfx user on target"
ssh $target_host "useradd signalfx -d /opt/signalfx-agent -s /bin/false"

echo -e "Setting /opt/signalfx-agent permission"
ssh $target_host "chown -R signalfx:signalfx /opt/signalfx-agent"

echo -e "Creating confg dir"
ssh $target_host "mkdir -p /etc/signalfx/conf.d"

echo -e "Copying config files"
scp $CONFIG $target_host:/etc/signalfx
scp $SYSTEMYAML $target_host:/etc/signalfx/conf.d/

echo -e "Enabling auto start"
ssh $target_host "update-rc.d signalfx-agent start"

echo -e "Cleaning Conf File locally"
rm $CONFIG
rm $SYSTEMYAML  
rm $INITSCRIPT  
