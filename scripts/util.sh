#! /bin/bash

get_string() {
  result=$(echo $1 | cut -d" " -f $2)
  result=$(echo $result | sed -e 's/^[[:space:]]*//' | sed -e 's/[[:space:]]*$//')
  echo $result
}


