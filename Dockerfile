# FROM ghcr.io/actions/actions-runner:2.315.0
FROM ghcr.io/actions/actions-runner:latest

USER root

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    make curl docker-compose wget git npm build-essential ssh skopeo unzip jq \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir -p -m 755 /etc/apt/keyrings && wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
  && chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
  && apt-get update -y \
  && apt-get install -y --no-install-recommends gh \
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

# Add github ssh keys for runner user
RUN mkdir -p .ssh && curl -L https://api.github.com/meta | jq -r '.ssh_keys | .[]' | sed -e 's/^/github.com /' >> ~/.ssh/known_hosts
