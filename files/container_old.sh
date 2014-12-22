#!/bin/bash
## Updates docker image and removes old containers
name=$1
image=$(echo "$2" | grep -oP '.*(?=:)')
version=$(echo "$2" | grep -oP '(?<=:).*')

function print_usage() {
  echo "container_old.sh container_name image:version"
  exit 1
}

if [ -x $name ]; then
  echo "No name provided"
  print_usage
fi

if [ -x $image ]; then
  echo "No image provided"
  print_usage
fi

if [ -x $version ]; then
  echo "No version provided"
  print_usage
fi

function debug () {
  return
  echo $1
}

docker pull $image:$version

docker inspect $name >/dev/null 2>&1
if [ "$?" == "0" ]; then
  debug "container exists!"
  imageid=$(docker images | grep "^$image\s" | grep "\s$version\s" | awk '{ print $3 }')
  debug $imageid
  if [[ -n $imageid ]]; then
    debug "we have an image"
    cimageid=$(docker inspect --format "{{ .Image }}" $name)
    debug $cimageid
    if [[ -n $cimageid ]]; then
      debug "we have a container image"
      uptodate=$(echo $cimageid | grep $imageid)
      if [[ -n $uptodate ]]; then
        debug "uptodate"
        exit 0
      fi
    fi
  fi
else
  exit 0
fi

echo "CONTAINER OLD"
docker stop $name
docker wait $name
docker rm $name
