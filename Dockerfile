# syntax=docker/dockerfile:1
FROM debian:12-slim AS builder
RUN set -ex \
    && sed -i -- 's/Types: deb/Types: deb deb-src/g' /etc/apt/sources.list.d/debian.sources \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
               build-essential \
               curl \
               cdbs \
               devscripts \
               equivs \
               fakeroot \
               git \
               make \
               autoconf \
               automake \
               m4 \
               unzip \
    && apt-get clean \
    && rm -rf /tmp/* /var/tmp/*

WORKDIR /app
RUN git clone https://github.com/neurobin/shc.git

WORKDIR /app/shc
RUN autoreconf -vsi --force
RUN ./configure --build=x86_64-unknown-linux-gnu
RUN make install

WORKDIR /tmp
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli 

FROM golang:1.22.1
COPY --from=builder /usr/local/bin/shc /usr/local/bin/shc
COPY --from=builder /usr/local/bin/aws /usr/local/bin/aws

# Prepare dependencies
WORKDIR /app
ARG REL_TAG COSMOVISOR_TAG UPGRADE_TAG
RUN apt update && apt install git lz4 sed wget curl jq build-essential -y

# Download and install Cosmovisor
RUN go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@${COSMOVISOR_TAG}

## ------------- FOR CURRENT VERSION ------------- ##

# Make binaries for desired release tag
RUN git clone https://github.com/sei-protocol/sei-chain.git . --branch ${REL_TAG}
RUN make build
RUN mkdir -p /root/binaries/${REL_TAG}
RUN mv /app/build/seid /root/binaries/${REL_TAG}
RUN rm -rf /app/build

## ------------- SETTING UP COSMOVISOR ------------- ##

# Prepare env variables for Cosmovisor
ENV DAEMON_HOME /root/.sei
ENV DAEMON_NAME seid
ENV UNSAFE_SKIP_BACKUP true
ENV DAEMON_RESTART_AFTER_UPGRADE true
ENV DAEMON_ALLOW_DOWNLOAD_BINARIES false
# Prepare env variables for Go
ENV GOROOT /usr/local/go
ENV GOPATH $HOME/go
ENV GO111MODULE on
# Prepare PATH variable
ENV PATH $PATH:/usr/local/go/bin:$HOME/go/bin:/usr/bin:/root/binaries:/root/.sei/cosmovisor/current/bin

# Copy startup scripts and give excecution permission
COPY scripts/* ./scripts/
RUN chmod +x ./scripts/*.sh

ENTRYPOINT ["sh", "/scripts/start.sh"]