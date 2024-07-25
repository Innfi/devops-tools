#!/bin/zsh
INPUT=(input file)
PATTERN=(search pattern)

cat $INPUT | jq '.[] | .$PATTERN' | sort | unique
