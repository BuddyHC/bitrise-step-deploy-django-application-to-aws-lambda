#!/usr/bin/env sh

# A compability trick converting `INPUT_` prefixed environment variable names in the lower case form.
convert_input_envs_to_lower_case () {
    for var in $(awk 'BEGIN{for(v in ENVIRON) print v}' | grep '^INPUT_')
    do
        var_lower_case=$(echo $var | tr '[:upper:]' '[:lower:]')
        value=$(printenv $var)
        export "$var_lower_case=$value"
    done
}

get_runtime () {
    python_version=$(cat $1 | grep python_version | grep -o '[0-9].[0-9]') #todo: version number could be more versatile
    echo "python${python_version}"
}

# Creates zappa settings json file
#
# e.g.: $(create_zappa_settings_json_file "zappa_settings.json"
create_zappa_settings_json_file () {
    python > $1 << END
from string import Template
from os import environ as env

t = '''{
    "$input_stage": {
        "project_name": "$input_project_name",
        "runtime": "$input_runtime",
        "django_settings": "$input_django_settings",
        "s3_bucket": "zappa-$input_project_name"
    }
}'''

s = Template(t)

print(s.safe_substitute(env))
END
# TODO: Replace the Python based zappa settings template with something more sophesticated?
}

# Sanitizes a variable to be only within allowed characters of [a-zA-Z0-9_]
#
# e.g.: $(sanitize "$variable")
#
# string variable to be sanitized
sanitize () {
    var=${1//[ -\/]/_}
    echo ${var//[^a-zA-Z0-9_]/}
}

# Parses Zappa status for variables
#
# e.g.: $(get_status_variable "$status" "API Gateway URL")
#
# string status
# string variable name
get_status_variable ()
{
    echo $(echo "${1}" | grep "${2}" | xargs | cut -d':' -f2,3 | tr -d ' \r')
}