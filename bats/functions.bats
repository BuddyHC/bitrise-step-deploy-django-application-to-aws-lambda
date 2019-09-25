#!/usr/bin/env bats

source functions.sh

@test "convert input envs to lower case" {
    export INPUT_TEST_1="some value 1"
    export INPUT_TEST_2="some value 2"
    export OUTPUT_TEST="some other value"
    convert_input_envs_to_lower_case
    [ "$input_test_1" = "some value 1" ]
    [ "$input_test_2" = "some value 2" ]
    [ -z "$output_test" ]
}

@test "sanitize value" {
    result=$(sanitize "this-is_a value")
    [ "$result" = "this_is_a_value" ]
}

@test "get runtime version" {
    file="$BATS_TEST_DIRNAME/test_files/Pipfile"
    runtime=$(get_runtime "$file")
    [ "$runtime" = "python3.7" ]
}

@test "create zappa template json" {
    input_stage="test_stage"
    input_project_name="test_project"
    input_runtime="python3.7"
    input_django_settings="test.settings"
    file="$BATS_TMPDIR/bats-test-zappa-settings.json"

    create_zappa_settings_json_file "$file"

    [ -f $file ]
    [ "$(cat ${file} | jq -r .${input_stage}.project_name)" = "${input_project_name}" ]
    [ "$(cat ${file} | jq -r .${input_stage}.runtime)" = "${input_runtime}" ]
    [ "$(cat ${file} | jq -r .${input_stage}.django_settings)" = "${input_django_settings}" ]
    [ "$(cat ${file} | jq -r .${input_stage}.s3_bucket)" = "zappa-${input_project_name}" ]

    rm $file
}

@test "get status variable" {
    status=$(cat $BATS_TEST_DIRNAME/test_files/status.txt)
    api_gateway_url=$(get_status_variable "$status" "API Gateway URL")
    domain_url=$(get_status_variable "$status" "Domain URL")
    lambda_name=$(get_status_variable "$status" "Lambda Name")
    [ "$api_gateway_url" = "https://wbous3xxwh.execute-api.eu-central-1.amazonaws.com/testing" ]
    [ "$domain_url" = "NoneSupplied" ]
    [ "$lambda_name" = "test-deploy-django-zappa-testing" ]
}
