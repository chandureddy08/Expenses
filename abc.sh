#!/bin/bash

COURSE="DevOps from current script"
echo "Before calling other script ,Course: $COURSE"
echo "Process id of current shell script: $$"

#./xyz.sh

source ./xyz.sh

echo "After calling other script ,Course: $COURSE"