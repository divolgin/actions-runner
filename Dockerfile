# FROM ghcr.io/actions/actions-runner:2.315.0
FROM ghcr.io/actions/actions-runner:latest

USER root

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    make curl docker-compose wget git npm build-essential \
  && rm -rf /var/lib/apt/lists/*

RUN curl -L -o /tmp/pact.tar.gz https://github.com/pact-foundation/pact-ruby-standalone/releases/download/v2.0.0/pact-2.0.0-linux-x86_64.tar.gz \
  && tar -C /opt -xvzf /tmp/pact.tar.gz \
  && rm /tmp/pact.tar.gz
ENV PATH=$PATH:/opt/pact/bin

RUN npm install --global yarn

USER runner