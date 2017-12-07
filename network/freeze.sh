#!/bin/bash

source "../dataset/class/classes.sh"

python freeze.py \
  --start_checkpoint=/tmp/speech_commands_train/conv.ckpt-18000 \
  --output_file=/tmp/my_frozen_graph.pb \
  --wanted_words=$WANTED_CLASSES \
