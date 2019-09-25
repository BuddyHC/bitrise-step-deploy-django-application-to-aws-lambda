ARG input_runtime=python3.7
FROM lambci/lambda:build-${input_runtime}

# A trick to inherit the `input_runtime` variable defined before the `FROM` step
ARG input_runtime
ENV input_runtime=${input_runtime}

WORKDIR /var/task

RUN pip install --upgrade pip && pip install zappa pipenv lambda-packages

# TODO: Install additional OS packages depending only on the needs
RUN yum install -y mysql56-devel

COPY entrypoint.sh /usr/bin/entrypoint.sh

ENTRYPOINT [ "/usr/bin/entrypoint.sh" ]
CMD ["deploy"]