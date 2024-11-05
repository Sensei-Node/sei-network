FROM golang:1.22.1

ARG REL_TAG
ARG COSMOVISOR_TAG

RUN export GOROOT=/usr/local/go
RUN export GOPATH=$HOME/go
RUN export GO111MODULE=on
RUN export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin:/usr/bin

RUN apt update && apt install git lz4 sed wget curl jq build-essential unzip -y
RUN git clone https://github.com/sei-protocol/sei-chain.git /root/sei-chain
WORKDIR /root/sei-chain
RUN git checkout $REL_TAG && make install && make install-price-feeder

RUN curl -Ls https://github.com/cosmos/cosmos-sdk/releases/download/cosmovisor/$COSMOVISOR_TAG/cosmovisor-$COSMOVISOR_TAG-linux-amd64.tar.gz | tar xz
RUN chmod 755 cosmovisor && mv cosmovisor /usr/bin/cosmovisor

WORKDIR /tmp
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli 

ENTRYPOINT ["sh", "/scripts/start.sh"]