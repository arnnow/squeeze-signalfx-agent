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
AGENT="signalfx-agent-5.7.1.tar.gz"
INITSCRIPT="signalfx-agent"
CONFIG="agent.yaml"
SYSTEMYAML="system.yaml"

if [ ! -f $AGENT ] 
then
  echo -e "\033[0;31m Getting SmartAgent\033[0m"
  wget https://github.com/signalfx/signalfx-agent/releases/download/v5.7.1/signalfx-agent-5.7.1.tar.gz
fi
if [ ! -f $INITSCRIPT ] 
then
  echo -e "\033[0;31m Getting INITSCRIPT\033[0m"
  wget https://raw.githubusercontent.com/arnnow/squeeze-signalfx-agent/master/signalfx-agent
fi
if [ ! -f $CONFIG ] 
then
  echo -e "\033[0;31m Getting CONFIG\033[0m"
  wget https://raw.githubusercontent.com/arnnow/squeeze-signalfx-agent/master/agent.yaml
fi
if [ ! -f $SYSTEMYAML ] 
then
  echo -e "\033[0;31m Getting SYSTEMYAML\033[0m"
  wget https://raw.githubusercontent.com/arnnow/squeeze-signalfx-agent/master/system.yaml
fi

echo -e "\033[0;31m Setting variable in config file\033[0m"
sed -i "s/TOKEN/${token}/g" $CONFIG
sed -i "s/ENVIRONMENT/${env}/g" $CONFIG
sed -i "s/SFXMONITORED/${sfx_monitored}/g" $CONFIG

echo -e "\033[0;31m Uploading to target ${target_host}\033[0m"
scp signalfx-agent-5.7.1.tar.gz $target_host:/tmp/

echo -e "\033[0;31m Unpacking smartagent on target host\033[0m"
ssh $target_host "tar -xzf /tmp/signalfx-agent-5.7.1.tar.gz --directory /opt"

echo -e "\033[0;31m Copying init script to ${target_host}\033[0m"
scp $INITSCRIPT $target_host:/etc/init.d/
ssh $target_host "chmod +x /etc/init.d/signalfx-agent"

echo -e "\033[0;31m creating signalfx user on target\033[0m"
ssh $target_host "useradd signalfx -d /opt/signalfx-agent -s /bin/false"

echo -e "\033[0;31m Setting /opt/signalfx-agent permission\033[0m"
ssh $target_host "chown -R signalfx:signalfx /opt/signalfx-agent"

echo -e "\033[0;31m Creating confg dir\033[0m"
ssh $target_host "mkdir -p /etc/signalfx/conf.d"

echo -e "\033[0;31m Copying config files\033[0m"
scp $CONFIG $target_host:/etc/signalfx
scp $SYSTEMYAML $target_host:/etc/signalfx/conf.d/

echo -e "\033[0;31m Enabling auto start\033[0m"
ssh $target_host "update-rc.d signalfx-agent start"

echo -e "\033[0;31m Cleaning Conf File locally\033[0m"
rm $CONFIG
rm $SYSTEMYAML  
rm $INITSCRIPT   
