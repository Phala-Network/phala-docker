FROM ubuntu:20.04 AS builder

ARG RUST_TOOLCHAIN='nightly-2022-09-08'
ARG PHALA_GIT_REPO='https://github.com/Phala-Network/phala-blockchain.git'
ARG PHALA_GIT_TAG='master'
ARG PHALA_CARGO_PROFILE='release'

WORKDIR /root

RUN apt-get update && \
    DEBIAN_FRONTEND='noninteractive' apt-get install -y apt-utils apt-transport-https software-properties-common readline-common curl vim wget gnupg gnupg2 gnupg-agent ca-certificates cmake pkg-config libssl-dev git build-essential llvm clang libclang-dev rsync libboost-all-dev libssl-dev zlib1g-dev miniupnpc

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain="${RUST_TOOLCHAIN}" && \
    $HOME/.cargo/bin/rustup target add wasm32-unknown-unknown --toolchain "${RUST_TOOLCHAIN}"

RUN git clone --depth 1 --recurse-submodules --shallow-submodules -j 8 -b ${PHALA_GIT_TAG} ${PHALA_GIT_REPO} phala-blockchain

RUN cd $HOME/phala-blockchain/standalone/prouter && \
    PATH="$HOME/.cargo/bin:$PATH" cargo fetch

RUN cd $HOME/phala-blockchain/standalone/prouter && \
    PATH="$HOME/.cargo/bin:$PATH" cargo build --profile $PHALA_CARGO_PROFILE && \
    cp ./target/$PHALA_CARGO_PROFILE/prouter /root && \
    PATH="$HOME/.cargo/bin:$PATH" cargo clean && \
    rm -rf /root/.cargo/registry && \
    rm -rf /root/.cargo/git

# ====

FROM ubuntu:20.04

RUN apt-get update && \
    DEBIAN_FRONTEND='noninteractive' apt-get install -y apt-utils apt-transport-https software-properties-common readline-common curl vim wget gnupg gnupg2 gnupg-agent ca-certificates tini

RUN mkdir -p /opt/prouter/data
COPY --from=builder /root/prouter /opt/prouter

ENV RUST_LOG="info"

WORKDIR /opt/prouter/data

ENTRYPOINT ["/usr/bin/tini", "--", "/opt/prouter/prouter"]
