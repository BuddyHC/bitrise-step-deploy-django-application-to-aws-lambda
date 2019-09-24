#!/usr/bin/env bash

set -ebuo pipefail

zappa_settings () {
        [[ -z "${DJANGO_SETTINGS-}" ]] && export DJANGO_SETTINGS=$(python -c "from zappa.utilities import detect_django_settings; print(detect_django_settings()[0])")
        [[ -z "${STAGE-}" ]] && export STAGE="production"
        python > zappa_settings.json << END
from string import Template
from os import environ as env

t = '''{
    "$STAGE": {
        "project_name": "$PROJECT_NAME",
        "runtime": "$RUNTIME",
        "django_settings": "$DJANGO_SETTINGS"
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
        exec pipenv run zappa "${@:2}" $STAGE
        ;;
    deploy)
        zappa_init
        zappa_settings
        DATABASE_URL=postgresql://fakeuser:fakepass@fakehost/fakedb?sslmode=require SECRET_KEY=fakesecret pipenv run python manage.py collectstatic --noinput # TODO: Allow Django collectstatic command to be run without ENV variables set when run locally.
        pipenv run zappa deploy $STAGE || pipenv run zappa update $STAGE # TODO: Implement a smarter check if Zappa needs to run deploy or update
        # TODO: Run Django migrations after deployment
        ;;
    undeploy)
        zappa_settings
        (yes || true) | zappa undeploy $STAGE
        ;;
    status)
        zappa_settings
        zappa status $STAGE # TODO: Provide Zappa status in better parseable format.
        ;;
    *)
        exec "$@"
        ;;
esac
