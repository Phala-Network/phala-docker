#!/bin/bash

# Require jq to be installed:
#  brew install jq
#  apt install jq

ENDPOINT='http://127.0.0.1:8000'

function req {
  rand_number=$((RANDOM))
  data="${2}"
  if [ -z "${data}" ]; then
    data='{}'
  fi
  curl -sgX POST -H "Content-Type: application/json" "${ENDPOINT}/${1}" \
       -d "{\"input\":${data}, \"nonce\": {\"id\": ${rand_number}}}" \
       | tee /tmp/req_result.json | jq '.payload|fromjson'
  echo
}

function query {
	contract_id="${1}"
	payload="${2}"
	rand_number=$((RANDOM))

	query_body_json=$(echo "{\"contract_id\":${contract_id},\"nonce\":${rand_number},\"request\":${payload}}" | jq '. | tojson' -c)
	query_payload_json=$(echo "{\"Plain\":${query_body_json}}" | jq '. | tojson')
	query_data="{\"query_payload\":${query_payload_json}}"
	req 'query' "${query_data}"
}

case $1 in
init)
  init
;;
query)
  shift 1
  query "$@"
;;
list-tx)
  query 5 '"VerifiedTransactions"'
;;
*)
  req "$@"
;;
esac
