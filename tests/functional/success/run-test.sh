#!/bin/bash
#!/bin/bash


## Supress output from pushd and popd
pushd () {
    command pushd "$@" > /dev/null
}

popd () {
    command popd "$@" > /dev/null
}

project='python_project'

expected=(
  "[main]	INFO	profile include tests: None"
  "[main]	INFO	profile exclude tests: None"
  "[main]	INFO	cli include tests: None"
  "[main]	INFO	cli exclude tests: None"
  "[main]	INFO	running on Python 3.7.3"
  "Run started:"
  "Test results:"
  ">> Issue: [B501:request_with_no_cert_validation] Requests call with verify=False disabling SSL certificate checks, security issue."
  "Severity: High   Confidence: High"
  "Location: python_project/functional.py:48"
  "More Info: https://bandit.readthedocs.io/en/latest/plugins/b501_request_with_no_cert_validation.html"
  "47"
  "48	        response_auth = requests.post(endpoint, data=body_auth, verify=False)"
  "49"
  ""
  "--------------------------------------------------"
  ">> Issue: [B501:request_with_no_cert_validation] Requests call with verify=False disabling SSL certificate checks, security issue."
  "Severity: High   Confidence: High"
  "Location: python_project/functional.py:62"
  "More Info: https://bandit.readthedocs.io/en/latest/plugins/b501_request_with_no_cert_validation.html"
  "61	                                            data=data,"
  "62	                                            verify=False)"
  "63	        return response_set_search.text"
  "64"
  "65	    def get_search(session_key, sid, num_retries=10):"
  "66	        session_key_format = 'Splunk {0}'.format(session_key)"
  ""
  "--------------------------------------------------"
  ">> Issue: [B501:request_with_no_cert_validation] Requests call with verify=False disabling SSL certificate checks, security issue."
  "Severity: High   Confidence: High"
  "Location: python_project/functional.py:74"
  "More Info: https://bandit.readthedocs.io/en/latest/plugins/b501_request_with_no_cert_validation.html"
  "73	                                                   headers=header_auth,"
  "74	                                                   verify=False)"
  "75"
  "76	                if response_get_search.status_code == 200:"
  "77	                    return response_get_search.text"
  ""
  "--------------------------------------------------"
  ">> Issue: [B410:blacklist] Using lxml.html to parse untrusted XML data is known to be vulnerable to XML attacks. Replace lxml.html with the equivalent defusedxml package."
  "Severity: Low   Confidence: High"
  "Location: python_project/scanners/nessus.py:6"
  "More Info: https://bandit.readthedocs.io/en/latest/blacklists/blacklist_imports.html#b410-import-lxml"
  "5	import logging"
  "6	import lxml.html"
  "7	from lxml.etree import XPath"
  ""
  "--------------------------------------------------"
  ">> Issue: [B410:blacklist] Using XPath to parse untrusted XML data is known to be vulnerable to XML attacks. Replace XPath with the equivalent defusedxml package."
  "Severity: Low   Confidence: High"
  "Location: python_project/scanners/nessus.py:7"
  "More Info: https://bandit.readthedocs.io/en/latest/blacklists/blacklist_imports.html#b410-import-lxml"
  "6	import lxml.html"
  "7	from lxml.etree import XPath"
  "8	import uuid"
  ""
  "--------------------------------------------------"
  ""
  "Code scanned:"
  "Total lines of code: 869"
  "Total lines skipped (#nosec): 0"
  ""
  "Run metrics:"
  "Total issues (by severity):"
  "Undefined: 0.0"
  "Low: 2.0"
  "Medium: 0.0"
  "High: 3.0"
  "Total issues (by confidence):"
  "Undefined: 0.0"
  "Low: 0.0"
  "Medium: 0.0"
  "High: 5.0"
  "Files skipped (2):"
  "python_project/cloudutils/openstack.py (syntax error while parsing AST from file)"
  "python_project/util.py (syntax error while parsing AST from file)"
  ""
)

errors=0
echo "Running tests on project $project in $(dirname $0)/$project"
pushd $(dirname $0)
if [[ -f "${project}.zip" ]]; then
  echo "Removing leftover zipfile ${project}.zip"
  rm -f "${project}.zip"
fi
zip -qr "${project}".zip $project/*
results=$(curl -s -F "files=@${project}.zip" http://127.0.0.1:8080/function/piedpiper-pybandit-function)
while read -r line ; do
  found=false
  for i in "${!expected[@]}"; do
    if [[ "${line}" == "${expected[i]}" ]]; then
	  unset 'expected[i]'
	  found=true
	  break
	elif [[ "${line}" =~ ^[Run\ started*] ]]; then
	  unset 'expected[i]'
	  found=true
	  break
	fi
  done
  if [[ "${found}" == false ]]; then
    echo "Match not found for line ${line}"
	errors=$((errors+1))
  fi
done <<< "${results}"
if [[ "${#expected[@]}" -ne 0 ]]; then
  echo "Not all expected results found. ${#expected[@]} leftover"
  for line in "${expected[@]}"; do
    echo "Not found: "
	echo "${line}"
  done
  errors=$((errors+1))
fi
if [[ -f "${project}.zip" ]]; then
  echo "Removing leftover zipfile ${project}.zip"
  rm -f "${project}.zip"
fi
popd


if [[ "${errors}" == 0 ]]; then
    echo "Test ran successfully";
    exit 0;
else
    echo "Test failed";
	exit 1;
fi

