#!/usr/bin/env bash
. cmn.sh
. cfg.sh

MONTH=""
YEAR=""
HELPREQUESTED=false

# TODO put in cmn.sh
function parseArgs() {
  if [[ $# -lt 1 ]]; then
    HELPREQUESTED=true
  fi

  while [[ $# -gt 0 ]]
  do
    local key="$1"
    case $key in
      -h|--help)
      HELPREQUESTED=true
      shift
      ;;
      -m|--month)
      MONTH="$2"
      shift
      shift
      ;;
      -y|--year)
      YEAR="$2"
      shift
      shift
      ;;
      *)
      echo "ignore $1"
      shift
      ;;
    esac
  done
}

function validateConfiguration() {
  [[ -z $MONTH ]] && echo "month is required!" && HELPREQUESTED=true
  [[ -z $YEAR ]] && echo "year is required!" && HELPREQUESTED=true

  if [[ $HELPREQUESTED == "true" ]]
  then
    echo "usage: $0 -y <year> -m <month>"
    exit 2
  fi

  checkDir $RENT_BASEDIR "RENT_BASEDIR"
}

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

days=(31 28 31 30 31 30 31 31 30 31 30 31)

function getDate {
  index=$((10#$1 - 1))
  echo "le 18 "${month[$index]}" "$2
}

function getPeriod {
  index=$((10#$1 - 1))
  echo "1 "${month[$index]}" "$2" au "${days[$index]}" "${month[$index]}" "$2
}


if [[ "$BASH_ENV" == "UNIT_TEST" ]]
then
  echo "running unit tests on $BASH_SOURCE through ${0##*/}"
  fail=0
  [ "$(getDate 01 2019)" != "le 1 janvier 2019" ] && echo "getDate fail" && fail=1
  [ "$(getDate 12 2039)" != "le 1 décembre 2039" ] && echo "getDate fail" && fail=1
  [ "$(getPeriod 07 2019)" != "1 juillet 2019 au 31 juillet 2019" ] && echo "getPeriod fail" && fail=1

  if [[ $fail -eq 1 ]]
  then
    echo "test suite failed"
    exit 1
  fi

  echo "test on $BASH_SOURCE ok"
  exit 0
fi

# main
parseArgs $*
# validateConfiguration

amount=0
charges=0
if [[ "$YEAR$MONTH" > "201908" ]]
then
  charges=80
  amount=520
  street="32, avenue de la République"
else
  charges=50
  amount=350
  street="8, domaine de Château Gaillard"
fi
totalAmount=$(($amount + $charges))

date=$(getDate $MONTH $YEAR)
period=$(getPeriod $MONTH $YEAR)

outfilename=$RENT_BASEDIR/${YEAR}${MONTH}18-fourniture-loyer-${amount}00.pdf
echo "out:$outfilename, date:$date, period:$period"
sed -e "s/§DATE§/$date/g" quittance.tex -e "s/§PERIOD§/$period/g" -e "s/§TOTALAMOUNT§/$totalAmount/g" -e "s/§CHARGES§/$charges/g" -e "s/§AMOUNT§/$amount/g"  -e "s/§STREET§/$street/g" > tmp.tex
pdflatex tmp.tex
mv tmp.pdf $outfilename
rm -f tmp.*
