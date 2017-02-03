#!/bin/bash

# mercury-job-create.sh - set up skeleton Mercury job directory
# AC - 2017-02-03

printf "\033[1mEnter jobname\033[0m (e.g. M16-012-ABC-Organisation): "
read jobname
jobname=$(echo $jobname | tr ' ' '-')
mkdir $jobname
cd $jobname
mkdir recon scans exploits proof
pwd
tree
