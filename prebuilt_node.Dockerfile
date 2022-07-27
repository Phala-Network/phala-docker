FROM ubuntu:20.04

RUN apt-get update && \
    DEBIAN_FRONTEND='noninteractive' apt-get install -y apt-utils apt-transport-https software-properties-common readline-common curl vim wget gnupg gnupg2 gnupg-agent ca-certificates tini

ADD prebuilt/node/* /root

WORKDIR /root

ENV RUST_LOG="info"
ENV NODE_NAME='phala-node'
ENV NODE_ROLE="FULL"
ENV EXTRA_OPTS=''

EXPOSE 9615
EXPOSE 9933
EXPOSE 9944
EXPOSE 30333

ENTRYPOINT ["/usr/bin/tini", "--"]

CMD ["/bin/bash", "./start_node.sh"]
