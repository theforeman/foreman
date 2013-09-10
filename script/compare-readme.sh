#!/bin/bash
# To find issues (#1234 format) which are not mentioned in last two readme
# files. Example:
#
# script/compare-readme.sh HEAD~30 path/1.2/1.3_release_notes.md \
#     path/1.2/1.2_release_notes.md
#
HASH=$1
README1=$2
README2=$3

for ISS in $(git log HEAD...$HASH | grep -Eo '#[0-9]+' | sort -u); do
  if ! grep -q "$ISS" "$README1"; then
    if ! grep -q "$ISS" "$README2"; then
      echo $(git log --grep "$ISS" --oneline)
    fi
  fi
done
