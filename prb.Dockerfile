FROM ubuntu:22.04 AS builder

ARG TZ="Etc/UTC"
ARG RUST_TOOLCHAIN="1.73.0"

WORKDIR /root

RUN DEBIAN_FRONTEND="noninteractive" apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get upgrade -y && \
    DEBIAN_FRONTEND="noninteractive" apt-get install -y apt-utils apt-transport-https software-properties-common readline-common curl vim wget gnupg gnupg2 gnupg-agent ca-certificates cmake pkg-config libssl-dev git build-essential llvm clang libclang-dev rsync libboost-all-dev libssl-dev zlib1g-dev miniupnpc protobuf-compiler

RUN curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain="${RUST_TOOLCHAIN}" && \
    $HOME/.cargo/bin/rustup target add wasm32-unknown-unknown --toolchain "${RUST_TOOLCHAIN}"

ARG PHALA_GIT_REPO="https://github.com/Phala-Network/phala-blockchain.git"
ARG PHALA_GIT_TAG="master"
RUN git clone --depth 1 --recurse-submodules --shallow-submodules -j 8 -b ${PHALA_GIT_TAG} ${PHALA_GIT_REPO} phala-blockchain

RUN cd $HOME/phala-blockchain && \
    PATH="$HOME/.cargo/bin:$PATH" cargo fetch

ARG PHALA_CARGO_PROFILE="release"
RUN cd $HOME/phala-blockchain && \
    PATH="$HOME/.cargo/bin:$PATH" cargo build --profile $PHALA_CARGO_PROFILE && \
    cp ./target/$PHALA_CARGO_PROFILE/phala-node /root && \
    cp ./target/$PHALA_CARGO_PROFILE/pherry /root && \
    cp ./target/$PHALA_CARGO_PROFILE/headers-cache /root && \
    cp ./target/$PHALA_CARGO_PROFILE/replay /root && \
    cp ./target/$PHALA_CARGO_PROFILE/prb-wm /root && \
    cp ./target/$PHALA_CARGO_PROFILE/prb-config /root && \
    PATH="$HOME/.cargo/bin:$PATH" cargo clean && \
    rm -rf /root/.cargo/registry && \
    rm -rf /root/.cargo/git

# ====

FROM ubuntu:22.04

ARG TZ="Etc/UTC"

RUN DEBIAN_FRONTEND="noninteractive" apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get upgrade -y && \
    DEBIAN_FRONTEND="noninteractive" apt-get install -y apt-utils apt-transport-https software-properties-common readline-common curl vim wget gnupg gnupg2 gnupg-agent ca-certificates git tini

RUN mkdir -p /opt/headers-cache/data
COPY --from=builder /root/headers-cache /opt/headers-cache/headers-cache

RUN mkdir -p /opt/prb/data
COPY --from=builder /root/prb-wm /opt/prb/prb-wm
COPY --from=builder /root/prb-config /opt/prb/prb-config

ENV RUST_LOG="info"

WORKDIR /opt/prb/data

ENTRYPOINT /opt/prb/prb-wm
