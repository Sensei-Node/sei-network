FROM ubuntu:22.04

RUN apt update && apt install git lz4 sed wget curl jq golang-go build-essential -y
RUN git clone https://github.com/sei-protocol/sei-chain.git sei-chain
RUN cd sei-chain && git fetch && git checkout 3.0.0 && make install && cp ~/go/bin/seid /usr/bin
#RUN wget -O sei.tar.gz $(curl -s https://api.github.com/repos/sei-protocol/sei-chain/releases/latest | jq -r '.tarball_url') 
#RUN seidir=$(tar -axvf sei.tar.gz) && cd $(echo $seidir | cut -f1 -d" ") && make install && cp ~/go/bin/seid /usr/bin
#RUN cd / && rm sei.tar.gz && rm -rf $(echo $seidir | cut -f1 -d" ")

# RUN mkdir /root/sei-configs
#COPY ./config/client.toml /root/.sei/config/client.toml
#COPY ./config/config.toml /root/.sei/config/config.toml
COPY ./scripts/init.sh /
RUN chmod +x /init.sh
ENTRYPOINT ["./init.sh"]
