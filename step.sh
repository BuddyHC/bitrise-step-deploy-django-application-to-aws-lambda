#!/bin/sh

set -ebuo pipefail

# A compability trick converting `INPUT_` prefixed environment variable names in the lower case form.
for var in $(awk 'BEGIN{for(v in ENVIRON) print v}' | grep '^INPUT_')
do
    var_lower_case=$(echo $var | tr '[:upper:]' '[:lower:]')
    value=$(printenv $var)
    declare "$var_lower_case=$value"
done

get_runtime () {
    python_version=$(cat ${input_app_dir}/Pipfile | grep python_version | grep -o '[0-9].[0-9]') #todo: version number could be more versatile
    echo "python${python_version}"
}

: ${input_runtime:=$(get_runtime)}
docker-compose build --build-arg input_runtime=${input_runtime} zappa
docker-compose run --rm zappa

# --- Export Environment Variables for other Steps:
# You can export Environment Variables for other Steps with
#  envman, which is automatically installed by `bitrise setup`.

status=$(docker-compose run --rm zappa status)
api_gateway_url=$(echo "${status}" | grep "API Gateway URL" | xargs | cut -d':' -f2,3 | tr -d ' \r')
domain_url=$(echo "${status}" | grep "Domain URL" | xargs | cut -d':' -f2,3 | tr -d ' \r')

# Envman can handle piped inputs, which is useful if the text you want to
# share is complex and you don't want to deal with proper bash escaping:
#  cat file_with_complex_input | envman add --KEY EXAMPLE_STEP_OUTPUT
# You can find more usage examples on envman's GitHub page
#  at: https://github.com/bitrise-io/envman

envman add --key API_GATEWAY_URL --value "${api_gateway_url}"
echo ::set-output name=API_GATEWAY_URL::"${api_gateway_url}"

envman add --key DOMAIN_URL --value "${domain_url}"
echo ::set-output name=DOMAIN_URL::"${domain_url}"

#
# --- Exit codes:
# The exit code of your Step is very important. If you return
#  with a 0 exit code `bitrise` will register your Step as "successful".
# Any non zero exit code will be registered as "failed" by `bitrise`.
