#!/bin/bash
# Runs firstlevel_ses5.submit for all IDS listed in test file idfile.txt

echo "Submitting jobs for ID list from idfile.txt"
echo

while read id; do
  if [[ ! -z "$id" ]];
  then 
  subject_id="${id}"
  #subject_id="$(id)"
  echo "Submitting job for Subject ID ${subject_id}"
  sbatch firstlevel_ses7.submit $subject_id
  fi
done <idfile.txt
