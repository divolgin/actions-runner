# FROM ghcr.io/actions/actions-runner:2.315.0
FROM ghcr.io/actions/actions-runner:latest

USER root

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    make curl docker-compose wget git npm build-essential ssh skopeo unzip \
  && rm -rf /var/lib/apt/lists/*

RUN curl -L -o /tmp/pact.tar.gz https://github.com/pact-foundation/pact-ruby-standalone/releases/download/v2.0.0/pact-2.0.0-linux-x86_64.tar.gz \
  && tar -C /opt -xvzf /tmp/pact.tar.gz \
  && rm /tmp/pact.tar.gz
ENV PATH=$PATH:/opt/pact/bin

RUN curl -L -o /tmp/kustomize.tar.gz https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv5.4.1/kustomize_v5.4.1_linux_amd64.tar.gz \
  && tar -C /usr/local/bin -xvzf /tmp/kustomize.tar.gz \
  && rm /tmp/kustomize.tar.gz

RUN cd /tmp && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
  && unzip awscliv2.zip \
  && ./aws/install

RUN npm install --global yarn

USER runner