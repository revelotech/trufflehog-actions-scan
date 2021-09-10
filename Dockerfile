FROM python:3.7-alpine

LABEL name="trufflehog-actions-scan"
LABEL version="1.0.2"
LABEL repository="https://github.com/contratadome/trufflehog-actions-scan"
LABEL homepage="https://github.com/contratadome/trufflehog-actions-scan"
LABEL maintainer="Revelo"

LABEL "com.github.actions.name"="Trufflehog Actions Scan"
LABEL "com.github.actions.description"="Scan repository for secrets with basic trufflehog defaults in place for easy setup."
LABEL "com.github.actions.icon"="shield"
LABEL "com.github.actions.color"="yellow"

RUN pip install gitdb2==3.0.0 truffleHog==2.1.11
RUN apk --update add git less openssh jq && \
  rm -rf /var/lib/apt/lists/* && \
  rm /var/cache/apk/*

ADD entrypoint.sh  /entrypoint.sh
ADD regexes.json /regexes.json
ADD .ignorelist /.ignorelist
ADD ignore_patterns.json /ignore_patterns.json

ENTRYPOINT ["/entrypoint.sh"]