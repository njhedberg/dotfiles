#!/bin/sh

COUNT=`lsusb | grep -c "TypeMatrix 2030 USB Keyboard"`

if [ $COUNT -ne 0 ]
then
  # If a TypeMatrix keyboard is found, set US layout because hardware
  # Dvorak mode is used.
  echo "TypeMatrix keyboard found."
  setxkbmap -layout us -option compose:ralt
else
  echo "TypeMatrix keyboard not found."
  setxkbmap -layout dvorak -option compose:ralt
fi
