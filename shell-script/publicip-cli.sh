#!/bin/bash
apk add --update bind-tools
dig +short myip.opendns.com @resolver1.opendns.com
