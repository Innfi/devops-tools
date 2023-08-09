#!/bin/zsh
git branch|grep -Ev 'main|dev|prod'|xargs git branch -D
