FROM golang:1.22.1

ARG REL_TAG

RUN export GOROOT=/usr/local/go
RUN export GOPATH=$HOME/go
RUN export GO111MODULE=on
RUN export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin

RUN apt update && apt install git lz4 sed wget curl jq build-essential -y
RUN git clone https://github.com/sei-protocol/sei-chain.git /root/sei-chain
WORKDIR /root/sei-chain
RUN git checkout $REL_TAG && make install

ENTRYPOINT ["sh", "/scripts/start.sh"]