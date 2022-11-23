FROM ubuntu:20.04 AS builder

ARG TZ='Etc/UTC'
ARG RUST_TOOLCHAIN='nightly-2022-10-25'
ARG PHALA_GIT_REPO='https://github.com/Phala-Network/phala-blockchain.git'
ARG PHALA_GIT_TAG='master'

WORKDIR /root

RUN DEBIAN_FRONTEND='noninteractive' apt-get update && \
    DEBIAN_FRONTEND='noninteractive' apt-get upgrade -y && \
    DEBIAN_FRONTEND='noninteractive' apt-get install -y apt-utils apt-transport-https software-properties-common readline-common curl vim wget gnupg gnupg2 gnupg-agent ca-certificates cmake pkg-config libssl-dev git build-essential llvm clang libclang-dev rsync libboost-all-dev libssl-dev zlib1g-dev miniupnpc protobuf-compiler

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain="${RUST_TOOLCHAIN}" && \
    $HOME/.cargo/bin/rustup target add wasm32-unknown-unknown --toolchain "${RUST_TOOLCHAIN}"

RUN git clone --depth 1 --recurse-submodules --shallow-submodules -j 8 -b ${PHALA_GIT_TAG} ${PHALA_GIT_REPO} phala-blockchain

RUN cd $HOME/phala-blockchain && \
    PATH="$HOME/.cargo/bin:$PATH" cargo fetch

ARG PHALA_CARGO_PROFILE='release'

RUN cd $HOME/phala-blockchain && \
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

ARG TZ='Etc/UTC'

RUN DEBIAN_FRONTEND='noninteractive' apt-get update && \
    DEBIAN_FRONTEND='noninteractive' apt-get upgrade -y && \
    DEBIAN_FRONTEND='noninteractive' apt-get install -y apt-utils apt-transport-https software-properties-common readline-common curl vim wget gnupg gnupg2 gnupg-agent ca-certificates git tini

COPY --from=builder /root/pherry /root
ADD dockerfile.d/start_pherry.sh /root/start_pherry.sh

WORKDIR /root

ENV RUST_LOG="info"
ENV PRUNTIME_ENDPOINT='http://127.0.0.1:8000'
ENV PHALA_NODE_WS_ENDPOINT='ws://127.0.0.1:9944'
ENV MNEMONIC=''
ENV EXTRA_OPTS='-r'
ENV SLEEP_BEFORE_START=0

ENTRYPOINT ["/usr/bin/tini", "--"]

CMD ["/bin/bash", "./start_pherry.sh"]
