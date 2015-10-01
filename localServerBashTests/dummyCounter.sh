#!/bin/bash

# dummyCounter - counts to <x> & wait <y> seconds before each echo

# debug
echo "counting up to $1 and waiting $2 seconds before each echo"

for (( i=1; i<=$1; i++ ))
do
  echo "Welcome $i times"
  sleep $2
done
