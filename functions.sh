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

# Gets the Python runtime version from `Pipfile`
#
# string path to `Pipfile`
get_runtime () {
    python_version=$(cat $1 | grep python_version | grep -o '[0-9].[0-9]') # TODO: version number could be more versatile
    echo "python${python_version}"
}

# Creates zappa settings json file
#
# e.g.: create_zappa_settings_json_file_shell "zappa_settings.json"
create_zappa_settings_json_file () {
    # TODO: Replace the Python based zappa settings template with something more sophesticated and not requiring Python installed?
    sed \
    -e "s/\${\$input_stage}/"$input_stage"/" \
    -e "s/\${\$input_project_name}/"$input_project_name"/" \
    -e "s/\${\$input_runtime}/"$input_runtime"/" \
    -e "s/\${\$input_django_settingse}/"$input_django_settings"/" \
    > $1 << END
{
    "$input_stage": {
        "project_name": "$input_project_name",
        "runtime": "$input_runtime",
        "django_settings": "$input_django_settings",
        "s3_bucket": "zappa-$input_project_name",
        "exclude": [
            "__pycache__",
            ".git/*",
            ".gitignore",
            ".python-version",
            "LICENSE",
            "README.md",
            "requirements.txt",
            "zappa_settings.json"
        ]
    }
}
END
    echo $1
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