#!/bin/sh

set -ebuo pipefail

cd $BITRISE_STEP_SOURCE_DIR

source functions.sh

: ${input_runtime:=$(get_runtime "./test-project/Pipfile")}
docker-compose build --build-arg input_runtime=${input_runtime} zappa
docker-compose run --rm zappa

# --- Export Environment Variables for other Steps:
# You can export Environment Variables for other Steps with
#  envman, which is automatically installed by `bitrise setup`.

status=$(docker-compose run --rm zappa status)
api_gateway_url=$(get_status_variable "${status}" "API Gateway URL")
domain_url=$(get_status_variable "${status}" "Domain URL")
lambda_name=$(get_status_variable "${status}" "Lambda Name")

# Envman can handle piped inputs, which is useful if the text you want to
# share is complex and you don't want to deal with proper bash escaping:
#  cat file_with_complex_input | envman add --KEY EXAMPLE_STEP_OUTPUT
# You can find more usage examples on envman's GitHub page
#  at: https://github.com/bitrise-io/envman

envman add --key API_GATEWAY_URL --value "${api_gateway_url}"
echo ::set-output name=API_GATEWAY_URL::"${api_gateway_url}"

envman add --key DOMAIN_URL --value "${domain_url}"
echo ::set-output name=DOMAIN_URL::"${domain_url}"

envman add --key LAMBDA_NAME --value "${lambda_name}"
echo ::set-output name=LAMBDA_NAME::"${lambda_name}"

#
# --- Exit codes:
# The exit code of your Step is very important. If you return
#  with a 0 exit code `bitrise` will register your Step as "successful".
# Any non zero exit code will be registered as "failed" by `bitrise`.
