#!/usr/bin/env bash
. cmn.sh
. cfg.sh

# Todo move to cmn.sh
month=("janvier"
  "février"
  "mars"
  "avril"
  "mai"
  "juin"
  "juillet"
  "août"
  "septembre"
  "octobre"
  "novembre"
  "décembre"
)

function getPeriod {
  index=$((10#$1 - 1))
  echo ${month[$index]} $2
}

period=$(getPeriod $1 $2)

sed "s/§period§/$period/" template-mail.txt
