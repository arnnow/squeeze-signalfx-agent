# Deploy signalfx agent to Old Debian Squeeze OS

I needed that to deploy to some old server not managed by our puppet environment.

The script take some args to configure signalfx.
This need to be launch from a server from which you hav access to the targeted server.

```
$ ./deploy.sh 
Usage: deploy.sh target_host token env sfx_monitored

  * target_host:   The host to deploy signaflx
  * token:         Token for the agent 
  * env:           Env to set for signalfx dimension
  * sfx_monitored: true or false - for agent dimension
```
