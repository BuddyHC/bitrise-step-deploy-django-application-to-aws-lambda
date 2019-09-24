#!/bin/bash

set -ebuo pipefail

get_runtime () {
    PYTHON_VERSION=$(cat ${APP_DIR}Pipfile | grep python_version | grep -o '[0-9].[0-9]') #todo: version number could be more versatile
    echo "python${PYTHON_VERSION}"
}

export RUNTIME=$(get_runtime)
docker-compose build --build-arg RUNTIME=${RUNTIME} zappa
docker-compose run --rm zappa

# --- Export Environment Variables for other Steps:
# You can export Environment Variables for other Steps with
#  envman, which is automatically installed by `bitrise setup`.

export STATUS=$(docker-compose run --rm zappa status)
export API_GATEWAY_URL=$(echo "${STATUS}" | grep "API Gateway URL" | xargs | cut -d':' -f2,3 | tr -d ' \r')
export DOMAIN_URL=$(echo "${STATUS}" | grep "Domain URL" | xargs | cut -d':' -f2,3 | tr -d ' \r')

# Envman can handle piped inputs, which is useful if the text you want to
# share is complex and you don't want to deal with proper bash escaping:
#  cat file_with_complex_input | envman add --KEY EXAMPLE_STEP_OUTPUT
# You can find more usage examples on envman's GitHub page
#  at: https://github.com/bitrise-io/envman

envman add --key API_GATEWAY_URL --value "${API_GATEWAY_URL}"
envman add --key DOMAIN_URL --value "${DOMAIN_URL}"

#
# --- Exit codes:
# The exit code of your Step is very important. If you return
#  with a 0 exit code `bitrise` will register your Step as "successful".
# Any non zero exit code will be registered as "failed" by `bitrise`.

