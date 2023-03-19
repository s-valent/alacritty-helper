#!/bin/zsh -l

eval '$@'
printf "\n\e[0;30m[Finished]"
read -sk
