FROM docker/compose:1.25.4

WORKDIR /github/workspace

COPY . /opt/action

ENTRYPOINT [ "/opt/action/step.sh" ]

CMD [""]