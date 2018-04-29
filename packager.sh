#!/usr/bin/env bash
. cmn.sh
. cfg.sh

MONTH=""
YEAR=""
HELPREQUESTED=false

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
  if [[ $HELPREQUESTED == "true" ]]
  then
    echo "usage: $0 -y <year> -m <month>"
    exit 2
  fi

  if [[ ! -d $TARGETDIR ]]
  then
    echo "target dir does not exist !"
    exit 11
  fi
  checkDir $TARGETDIR "TARGETDIR"
  checkDir $ACCOUNT_DIR "ACCOUNT_DIR"
  checkDir $INVOICE_BASE "INVOICE_BASE"
  checkDir $OUT_INVOICE_DIR "OUT_INVOICE_DIR"
  checkDir $IN_INVOICE_DIR "IN_INVOICE_DIR"
  checkDir $CHARGE_BASEDIR "CHARGE_BASEDIR"
}

function checkDir() {
  if [[ 2 -gt $# ]]
  then
    echo "$0:${FUNCNAME[0]} variable not provided"
    exit 100
  fi

  if [[ ! -d $1 ]]
  then
    echo "$2 does not exist! $1"
    exit 11
  fi
}


if [[ "$BASH_ENV" == "UNIT_TEST" ]]
then
  echo "running unit tests on $BASH_SOURCE through ${0##*/}"
  parseArgs -h
  assertTrue $HELPREQUESTED "help requested not properly set"
  parseArgs -m 11 -y 2017
  assertString $YEAR "2017" "year not set"
  assertString $MONTH "11" "month not set"
  assertInt 3 3 "wrong response by checkParameter"
  parseArgs
  assertTrue $HELPREQUESTED "help requested not properly set on no arg"
  echo "test on $BASH_SOURCE ok"
  exit 0
fi


function inInvoice() {
  echo "packaging incoming invoices"
  local inInvoiceDir=${TARGETDIR}/"pieces-comptables/${YEAR}-${MONTH}/entrant"
  mkdir -p $inInvoiceDir
  cp ${IN_INVOICE_DIR}/${YEAR}${MONTH}*.pdf ${OUT_INVOICE_DIR}/${YEAR}-${MONTH}*.jpg $inInvoiceDir
}


function charge() {
  echo "packaging charges"
  local NDF_DIR=${TARGETDIR}/"pieces-comptables/${YEAR}-${MONTH}/entrant/notes-de-frais"
  checkDir ${CHARGE_BASEDIR}/${YEAR}-${MONTH} "ndf source dir"

  echo "packaging charges: add extension"
  extension-adder.sh ${CHARGE_BASEDIR}/${YEAR}-${MONTH} "jpg"

  echo "packaging charges: move to new folder"
  mkdir -p ${NDF_DIR}
  cp ${CHARGE_BASEDIR}/${YEAR}-${MONTH}/*.jpg ${NDF_DIR}

  echo "packaging charges: reduce images size"
  for file in $(find ${NDF_DIR})
  do
    convert ${file} -resize 50% ${file}
  done

  echo "packaging charges: create synthesis"
  echo "jour;categorie;type;montant" > ${NDF_DIR}/synthese.csv
  ls -1 ${NDF_DIR}/*.jpg | xargs -n 1 basename | awk -F"\." '{print $1}'| awk -F"-" '{print $1"_"$2"_"$3"_"$4}' | awk -F"_" '{print $3"-"$2"-"$1";"$4";"$5";"$6}' >> ${NDF_DIR}/synthese.csv

  if [[ $(wc -l ${NDF_DIR}/synthese.csv | cut -d " " -f 1) -lt 2 ]]
  then
    echo "ERROR: no charge found! Generated report does not contain data."
    exit 11
  fi
}

function outInvoice() {
  echo "packaging outgoing invoices"
  local outInvoiceDir=${TARGETDIR}/"pieces-comptables/${YEAR}-${MONTH}/sortant"
  mkdir -p $outInvoiceDir
  cp ${OUT_INVOICE_DIR}/${YEAR}-${MONTH}*.pdf ${OUT_INVOICE_DIR}/${YEAR}-${MONTH}*.jpg $outInvoiceDir
}

function accountDetails() {
  echo "packaging account details"

  if [[ $(ls ${ACCOUNT_DIR}/${YEAR}${MONTH}* | wc -l | cut -d " " -f 1) -lt 1 ]]
  then
    echo "ERROR: no account details found!"
    echo "scanned pattern: ${ACCOUNT_DIR}/${YEAR}${MONTH}*"
    exit 12
  fi

  local outAccountDir=${TARGETDIR}/"pieces-comptables/${YEAR}-${MONTH}/releves"
  mkdir -p $outAccountDir
  cp ${ACCOUNT_DIR}/${YEAR}${MONTH}* $outAccountDir
}

function myZip() {
  echo "zipping"
  rm ${YEAR}-${MONTH}-pieces-comptables.zip
  cd ${TARGETDIR}
  zip -b /tmp -rm ${TARGETDIR}/${YEAR}-${MONTH}-pieces-comptables.zip pieces-comptables/${YEAR}-${MONTH}
  cd -
}


parseArgs $*
validateConfiguration
echo "TARGETDIR:$TARGETDIR"
echo "YEAR:$YEAR"
echo "MONTH:$MONTH"

inInvoice
charge
outInvoice
accountDetails
myZip
echo "done"
