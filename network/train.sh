#!/bin/bash

source "../dataset/class/classes.sh"

CLASS_DIR="../dataset/class/"
if [ ! -d $CLASS_DIR ]; then
  echo "ERROR: Class directory at $CLASS_DIR not found!"
  exit 1
fi

python train.py \
  --data_url= \
  --data_dir=$CLASS_DIR \
  --wanted_words=$WANTED_CLASSES \
