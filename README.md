# This Week In Helm Chart

This Helm chart can be used to parameterize and install the system in a cluster of Google's Kubernetes implementation, GKE. It is Kubernetes, so in theory much of this 
should work on other Kubernetes distributions, but it has only been tested on Google Cloud GKE. 

There's a script in the root of the directory that demonstrates its use. A few things are worth mentioning: 

*  The script `install.sh` demonstrates  that you'll need to think of a prefix that gets used all throughout the system to configure 
  things like the Kubernetes namespace into which to install the system. This prefix is also used when naming all the Kubernetes infrastructure, 
  so you have two levels of isolation: namespace, and resource name. 
* This Helm chart assumes that you've got some Google Cloud External IPs configured. Assuming you've specified a prefix - `$NS` in the `install.sh` script,
  it looks for `${NS}-twi-studio-ip` and  `${NS}-twi-api-ip`. The `install.sh` script builds these for you if they don't already exist. 
* You'll also need to point a domain to these two External IPs. Use an A Name reocrd to map `bookmark-api.YOUR_DOMAIN` to the IP indicated by `${NS}-twi-api-ip`, 
  and  use an A Name record to map `studio.YOUR_DOMAIN` to the IP indicated by `${NS}-twi-studio-ip`.
* This Helm chart assumes that you've configured a Redis and a PostgreSQL instance and that you have the connection information in the various environment variables used in `install.sh`.

For an up-to-date example, please consult `install.sh`. Here's what using only the Helm chart looks like: 

```shell

helm upgrade --values ./values.yaml  \
 --set twi.prefix=$NS   \
 --set twi.domain=$TWI_DOMAIN  \
 --set twi.postgres.username=$DB_USER  \
 --set twi.postgres.password=$DB_PW  \
 --set twi.postgres.host=$DB_HOST  \
 --set twi.postgres.schema=$DB_DB  \
 --set twi.redis.host=$REDIS_HOST \
 --set twi.redis.password=$REDIS_PW \
 --set twi.redis.port=$REDIS_PORT \
 --set twi.ingest.tags.ingest=$INGEST_TAG \
 --set twi.ingest.tags.ingested=$INGESTED_TAG \
 --set twi.pinboard.token=$PINBOARD_TOKEN \
 --set twi.twitter.client_key=${TWITTER_CLIENT_KEY} \
 --set twi.twitter.client_key_secret=${TWITTER_CLIENT_KEY_SECRET} \
 --set twi.ingest.feed.mappings="$( cat $HOME/Desktop/feed-mappings.json | base64 )" \
 --set twi.ingest.twitter.mappings="$( cat $HOME/Desktop/ttd-twitter-mappings.json | base64 )" \
 --namespace $NS  \
 twi-${NS}-helm-chart . 

```

