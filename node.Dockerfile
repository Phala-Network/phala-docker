FROM ubuntu:20.04 AS builder

ARG RUST_TOOLCHAIN='nightly-2022-07-11'
ARG PHALA_GIT_REPO='https://github.com/Phala-Network/phala-blockchain.git'
ARG PHALA_GIT_TAG='master'
ARG PHALA_CARGO_PROFILE='release'

WORKDIR /root

RUN apt-get update && \
    DEBIAN_FRONTEND='noninteractive' apt-get install -y apt-utils apt-transport-https software-properties-common readline-common curl vim wget gnupg gnupg2 gnupg-agent ca-certificates cmake pkg-config libssl-dev git build-essential llvm clang libclang-dev rsync libboost-all-dev libssl-dev zlib1g-dev miniupnpc

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain="${RUST_TOOLCHAIN}" && \
    $HOME/.cargo/bin/rustup target add wasm32-unknown-unknown --toolchain "${RUST_TOOLCHAIN}"

RUN git clone --depth 1 --recurse-submodules --shallow-submodules -j 8 -b ${PHALA_GIT_TAG} ${PHALA_GIT_REPO} phala-blockchain

RUN cd phala-blockchain && \
    PATH="$HOME/.cargo/bin:$PATH" cargo build --profile $PHALA_CARGO_PROFILE && \
    cp ./target/$PHALA_CARGO_PROFILE/phala-node /root && \
    cp ./target/$PHALA_CARGO_PROFILE/pherry /root && \
    cp ./target/$PHALA_CARGO_PROFILE/headers-cache /root && \
    cp ./target/$PHALA_CARGO_PROFILE/replay /root && \
    PATH="$HOME/.cargo/bin:$PATH" cargo clean && \
    rm -rf /root/.cargo/registry && \
    rm -rf /root/.cargo/git

# ====

FROM ubuntu:20.04

WORKDIR /root

RUN apt-get update && \
    DEBIAN_FRONTEND='noninteractive' apt-get install -y apt-utils apt-transport-https software-properties-common readline-common curl vim wget gnupg gnupg2 gnupg-agent ca-certificates tini

COPY --from=builder /root/phala-node .
ADD dockerfile.d/start_node.sh ./start_node.sh

ENV RUST_LOG="info"
ENV CHAIN="phala"
ENV NODE_NAME='phala-node'
ENV NODE_ROLE="FULL"
ENV EXTRA_OPTS=''

EXPOSE 9615
EXPOSE 9933
EXPOSE 9944
EXPOSE 30333

ENTRYPOINT ["/usr/bin/tini", "--"]

CMD ["/bin/bash", "./start_node.sh"]
