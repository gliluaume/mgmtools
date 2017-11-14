#!/usr/bin/env bash

. cmn.sh
. cfg.sh

MONTH=""
YEAR=""

HELPREQUESTED=false

function help() {
  "usage: $0 -y <year> -m <month>"
}

function parseArgs() {
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
  if [[ $HELPREQUESTED -eq true ]]
  then
    return 0
  fi

  if [[ ! -d $TARGETDIR ]]
  then
    echo "target dir does not exist !"
    exit 11
  fi
}

function run() {
  if [[ HELPREQUESTED ]]
  then
    help
    return 4
    echo "hola"
    exit 12
  fi
}

echo "bashenv $BASH_ENV"
if [[ "$BASH_ENV" == "UNIT_TEST" ]]
then
  echo "running unit tests on $BASH_SOURCE through ${0##*/}"
  parseArgs -h
  assertTrue $HELPREQUESTED "help requested not properly set"
  parseArgs -m 11 -y 2017
  assertString $YEAR "2017" "year not set"
  assertString $MONTH "11" "month not set"
  assertInt 3 3 "wrong response by checkParameter"
  echo "test on $BASH_SOURCE ok"
  exit 10
fi

parseArgs $*

echo "TARGETDIR:$TARGETDIR"
echo "YEAR:$YEAR"
echo "MONTH:$MONTH"


function inInvoice() {
  echo "packaging incoming invoices"
  local inInvoiceDir=${TARGETDIR}/"pieces-comptables/${YEAR}-${MONTH}/entrant"
  mkdir -p $inInvoiceDir
  cp ${IN_INVOICE_DIR}/${YEAR}${MONTH}*.pdf ${OUT_INVOICE_DIR}/${YEAR}${MONTH}*.jpg $inInvoiceDir
}


function charge() {
  echo "packaging charges"
  local NDF_DIR=${TARGETDIR}/"pieces-comptables/${YEAR}-${MONTH}/entrant/notes-de-frais"
  mkdir -p ${NDF_DIR}
  cp ${CHARGE_BASEDIR}/${YEAR}-${MONTH}/*.jpg ${NDF_DIR}
  echo "jour;categorie;type;montant" > ${NDF_DIR}/synthese.csv
  ls -1 ${NDF_DIR}/*.jpg | xargs -n 1 basename | awk -F"\." '{print $1}'| awk -F"-" '{print $1"_"$2"_"$3"_"$4}' | awk -F"_" '{print $3"-"$2"-"$1";"$4";"$5";"$6}' >> ${NDF_DIR}/synthese.csv
}

function outInvoice() {
  echo "packaging outgoing invoices"
  local outInvoiceDir=${TARGETDIR}/"pieces-comptables/${YEAR}-${MONTH}/sortant"
  mkdir -p $outInvoiceDir
  cp ${OUT_INVOICE_DIR}/${YEAR}-${MONTH}*.pdf ${OUT_INVOICE_DIR}/${YEAR}-${MONTH}*.jpg $outInvoiceDir
}

function accountDetails() {
  echo "packaging account details"
  local outAccountDir=${TARGETDIR}/"pieces-comptables/${YEAR}-${MONTH}/releves"
  mkdir -p $outAccountDir
  cp ${ACCOUNT_DIR}/${YEAR}${MONTH}* $outAccountDir
}

function myZip() {
  echo "zipping"
  rm ${YEAR}-${MONTH}-pieces-comptables.zip
  cd ${TARGETDIR}
  zip -b /tmp -r ${TARGETDIR}/${YEAR}-${MONTH}-pieces-comptables.zip pieces-comptables/${YEAR}-${MONTH}
  cd -
}

inInvoice
charge
outInvoice
accountDetails
myZip
echo "done"
