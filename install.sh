#!/usr/bin/env bash 

source $HOME/Desktop/ttd-env.sh

NS=$TWI_NS

function create_ip(){
    IPN=$1
    gcloud compute addresses list --format json | jq '.[].name' -r | grep $IPN || gcloud compute addresses create $IPN --global
}


function init(){
    create_ip ${NS}-twi-studio-ip 
    create_ip ${NS}-twi-api-ip 
    kubectl get ns/$NS || kubectl create namespace ${NS} 
}

# TODO restore the following three lines!
init 



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
 --set twi.feed.ingest.mappings="$( cat $HOME/Desktop/feed-mappings.json | base64 )" \
 --namespace $NS  \
 twi-${NS}-helm-chart . 

kubectl create job --from=cronjob/ttd-twi-twitter-ingest-cronjob ttd-twi-twitter-ingest-cronjob-${RANDOM} -n $NS 
kubectl create job --from=cronjob/ttd-twi-bookmark-ingest-cronjob ttd-twi-bookmark-ingest-cronjob-${RANDOM} -n $NS 
kubectl create job --from=cronjob/ttd-twi-feed-ingest-cronjob ttd-twi-feed-ingest-cronjob-${RANDOM} -n $NS 

#  --generate-name . 
#  --dry-run \
#  --debug \