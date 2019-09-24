ARG RUNTIME=python3.7
FROM lambci/lambda:build-${RUNTIME}

# A trick to inherit the `RUNTIME` variable defined before the `FROM` step
ARG RUNTIME
ENV RUNTIME=${RUNTIME}

WORKDIR /var/task

RUN pip install --upgrade pip && pip install zappa pipenv

COPY entrypoint.sh /usr/bin/entrypoint.sh

ENTRYPOINT [ "/usr/bin/entrypoint.sh" ]
CMD ["deploy"]