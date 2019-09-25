#!/usr/bin/env bash

set -ebuo pipefail

zappa_settings () {
        # AWS settings
        export AWS_ACCESS_KEY_ID=$input_aws_access_key_id
        export AWS_SECRET_ACCESS_KEY=$input_aws_secret_access_key
        export AWS_DEFAULT_REGION=$input_aws_default_region

        [[ -z "${input_django_settings-}" ]] && export input_django_settings=$(python -c "from zappa.utilities import detect_django_settings; print(detect_django_settings()[0])")
        [[ -z "${input_stage-}" ]] && export input_stage="production"
        python > zappa_settings.json << END
from string import Template
from os import environ as env

t = '''{
    "$input_stage": {
        "project_name": "$input_project_name",
        "runtime": "$input_runtime",
        "django_settings": "$input_django_settings"
    }
}'''

s = Template(t)

print(s.safe_substitute(env))
END
# TODO: Replace the Python based zappa settings template with something more sophesticated?
}

zappa_init () {
        export PIPENV_VENV_IN_PROJECT=true
        pipenv run pipenv install --deploy
        pipenv run pip install zappa Werkzeug
        export VIRTUAL_ENV=.venv
        # TODO: Get rid of `Courtesy Notice: Pipenv found itself running within a virtual environment, so it will automatically use that environment, instead of creating its own for any project. You can set PIPENV_IGNORE_VIRTUALENVS=1 to force pipenv to ignore that environment and create its own instead. You can set PIPENV_VERBOSITY=-1 to suppress this warning.`
}

case $1 in
    bash)
        exec "$@"
        ;;
    zappa)
        zappa_init
        zappa_settings
        exec pipenv run zappa "${@:2}" $input_stage
        ;;
    deploy)
        zappa_init
        zappa_settings
        DATABASE_URL=postgresql://fakeuser:fakepass@fakehost/fakedb?sslmode=require SECRET_KEY=fakesecret pipenv run python manage.py collectstatic --noinput # TODO: Allow Django collectstatic command to be run without ENV variables set when run locally.
        pipenv run zappa deploy $input_stage || pipenv run zappa update $input_stage # TODO: Implement a smarter check if Zappa needs to run deploy or update
        # TODO: Could API Gateway 30 second timeout be avoided with Django migration (see: https://github.com/Miserlou/Zappa#django-management-commands) ?
        zappa manage $input_stage migrate || true
        ;;
    undeploy)
        zappa_settings
        (yes || true) | zappa undeploy $input_stage
        ;;
    status)
        zappa_settings
        zappa status $input_stage # TODO: Provide Zappa status in better parseable format.
        ;;
    *)
        exec "$@"
        ;;
esac
