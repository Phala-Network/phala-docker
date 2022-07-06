FROM ubuntu:20.04 AS builder

ARG DEBIAN_FRONTEND='noninteractive'
ARG RUST_TOOLCHAIN='nightly-2022-04-01'
ARG PHALA_GIT_REPO='https://github.com/Phala-Network/phala-blockchain.git'
ARG PHALA_GIT_TAG='master'
ARG PHALA_CARGO_PROFILE='release'

WORKDIR /root

RUN apt-get update && \
    apt-get install -y apt-utils apt-transport-https software-properties-common readline-common curl vim wget gnupg gnupg2 gnupg-agent ca-certificates cmake pkg-config libssl-dev git build-essential llvm clang libclang-dev

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain="${RUST_TOOLCHAIN}" && \
    $HOME/.cargo/bin/rustup target add wasm32-unknown-unknown --toolchain "${RUST_TOOLCHAIN}"

RUN echo "Compiling Phala Blockchain from $PHALA_GIT_REPO:$PHALA_GIT_TAG..." && \
    git clone --depth 1 --recurse-submodules --shallow-submodules -j 8 -b ${PHALA_GIT_TAG} ${PHALA_GIT_REPO} phala-blockchain && \
    cd phala-blockchain && \
    PATH="$HOME/.cargo/bin:$PATH" cargo build --profile $PHALA_CARGO_PROFILE && \
    cp ./target/$PHALA_CARGO_PROFILE/phala-node /root && \
    cp ./target/$PHALA_CARGO_PROFILE/pherry /root && \
    cp ./target/$PHALA_CARGO_PROFILE/headers-cache /root && \
    PATH="$HOME/.cargo/bin:$PATH" cargo clean && \
    rm -rf /root/.cargo/registry && \
    rm -rf /root/.cargo/git

# ====

FROM ubuntu:20.04

ARG DEBIAN_FRONTEND='noninteractive'

WORKDIR /root

RUN apt-get update && \
    apt-get install -y apt-utils apt-transport-https software-properties-common readline-common curl vim wget gnupg gnupg2 gnupg-agent ca-certificates tini

COPY --from=builder /root/headers-cache .
RUN mkdir /root/data

ENV RUST_LOG="info"

WORKDIR /root/data

ENTRYPOINT ["/root/headers-cache"]