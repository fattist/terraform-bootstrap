#!/usr/bin/env sh
# USAGE: ./scripts/service.sh -e<environment> -r<account>.dkr.ecr.<region>.amazonaws.com -s<service>

required() {
  for var in $1 $2
  do
    if [[ -z "$var" ]]; then
      echo "MISSING VARIABLE"; exit 1;
    fi
  done
}

gradle_handler() {
  npx grunt decrypt --env=$1
  cd ..
  gradle clean build
  cd -
}

packer_handler() {
  packer build -var IMAGE_NAME=svc-$SVC -var IMAGE_VERSION=local -var SPRING_PROFILES=$1 packer/svc/$SVC.json
}

tag() {
  docker tag svc-$SVC:local $2/$1-$3-$SVC:latest
}

push() {
  docker push $2/$1-$3-$SVC:latest
}

handler() {
  ORG="ftx"

  required $ENV $REPO
  gradle_handler $ENV
  packer_handler $ENV
  tag $ENV $REPO $ORG
  npx grunt login --env=$ENV
  push $ENV $REPO $ORG
}

while getopts ":e:r:s:" opt; do
  case $opt in
    e) ENV="$OPTARG"
    ;;
    r) REPO="$OPTARG"
    ;;
    s) SVC="$OPTARG"
    ;;
  esac
done

handler
