#!/bin/bash
# Runs Preproc_ses7.submit for all IDS listed in test file idfile.txt

echo "Submitting jobs for ID list from idfile.txt"
echo

while read id; do
  if [[ ! -z "$id" ]];
  then 
  subject_id="${id}"
  #subject_id="$(id)"
  echo "Submitting job for Subject ID ${subject_id}"
  sbatch Preproc_ses.submit $subject_id
  fi
done <idfile.txt
