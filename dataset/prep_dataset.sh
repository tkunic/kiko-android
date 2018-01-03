#!/bin/bash

set -e

command -v ffmpeg >/dev/null 2>&1 || { echo >&2 "ffmpeg not installed.  Aborting."; exit 1; }
command -v sox >/dev/null 2>&1 || { echo >&2 "sox not installed.  Aborting."; exit 1; }
command -v rename >/dev/null 2>&1 || { echo >&2 "rename not installed.  Aborting."; exit 1; }
command -v wget >/dev/null 2>&1 || { echo >&2 "wget not installed.  Aborting."; exit 1; }

URBANSOUND8K_TARBALL="./UrbanSound8K.tar.gz"
URBANSOUND8K_CLASSES="air_conditioner car_horn children_playing dog_bark drilling engine_idling gun_shot jackhammer siren street_music"
URBANSOUND8K_TMP="/tmp/UrbanSound8K"

# Speech Commands Dataset
SC_CLASSES="yes no up down left right on off stop go zero one two three four five six seven eight nine bed bird cat dog happy house marvin sheila tree wow"
SC_DATASET_URL="http://download.tensorflow.org/data/speech_commands_v0.01.tar.gz"
SC_DATASET_TARBALL="/tmp/speech_commands.tar.gz"
SC_DATASET_TMP="/tmp/speech_commands"
SAMPLING_RATE=16000

if [ -d ./class ]; then
  echo "DONE: ./class directory already exists."
else
  mkdir class
  if [ ! -f $URBANSOUND8K_TARBALL ]; then
    echo "ERROR: $URBANSOUND8K_TARBALL not found. Please fill out the form and download it here: https://serv.cusp.nyu.edu/projects/urbansounddataset/urbansound8k.html"
    exit 1
  fi

  echo "Extracting UrbanSound8K class files..."
  if [ ! -d $URBANSOUND8K_TMP ]; then
    tar -zxvf $URBANSOUND8K_TARBALL --directory $URBANSOUND8K_TMP
  fi

  echo "Copying UrbanSound8K class files..."
  i=0
  for urbansound8k_class in $URBANSOUND8K_CLASSES; do
    echo "Copying ${urbansound8k_class} class files..."
    mkdir class/${urbansound8k_class}/
    cp ${URBANSOUND8K_TMP}/audio/fold*/*-${i}-*-*.wav class/${urbansound8k_class}/
    i=$((i+1))
  done

  echo "Converting to mono, 16000 sampling rate..."
  for wavfile in class/*/*; do
    echo $wavfile
    ffmpeg -y -loglevel -8 -i $wavfile -ac 1 -af aresample=resampler=soxr -ar $SAMPLING_RATE $wavfile 2>&1 >/dev/null
  done

  echo "Renaming to ensure files get hashed to correct buckets..."
  rename -v 's/(\d+)-(\d+)-(\d+)-(\d+).wav/$1_nohash_$2_$3_$4.wav/' class/*/*

  echo "Preparing Speech Commands Dataset..."
  if [ ! -d ./class/speech ]; then
    mkdir ./class/speech
    if [ ! -f $SC_DATASET_TARBALL ]; then
      echo "Downloading and extracting Speech Commands Dataset..."
      wget $SC_DATASET_URL -O $SC_DATASET_TARBALL
      mkdir $SC_DATASET_TMP
      tar -zxvf $SC_DATASET_TARBALL --directory $SC_DATASET_TMP
    fi

    echo "Taking 50 samples from each of the 30 speech_commands classes..."
    for class_name in $SC_CLASSES; do
      cp `find ${SC_DATASET_TMP}/$class_name -name *wav | sort -R | head -n 50` class/speech
    done
    exit 1
  fi
fi
