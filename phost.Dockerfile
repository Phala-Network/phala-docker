FROM ubuntu:18.04

ARG DEBIAN_FRONTEND='noninteractive'
ARG RUST_TOOLCHAIN='nightly-2020-10-01'
ARG PHALA_GIT_REPO='https://github.com/Phala-Network/phala-blockchain.git'
ARG PHALA_GIT_TAG='master'

WORKDIR /root

RUN apt update && \
    apt upgrade -y && \
    apt install -y cmake pkg-config libssl-dev git build-essential llvm-10 clang-10 libclang-10-dev curl apt-utils && \
    apt autoremove -y && \
    apt clean -y

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain="${RUST_TOOLCHAIN}" && \
    $HOME/.cargo/bin/rustup target add wasm32-unknown-unknown --toolchain "${RUST_TOOLCHAIN}"

RUN echo "Compiling Phala Blockchain from $PHALA_GIT_REPO:$PHALA_GIT_TAG..." && \
    git clone --depth 1 --recurse-submodules --shallow-submodules -j 8 -b ${PHALA_GIT_TAG} ${PHALA_GIT_REPO} phala-blockchain && \
    cd phala-blockchain && \
    PATH="$HOME/.cargo/bin:$PATH" cargo build --release && \
    cp ./target/release/phala-node /root && \
    cp ./target/release/phost /root && \
    PATH="$HOME/.cargo/bin:$PATH" cargo clean && \
    rm -rf /root/.cargo/registry && \
    rm -rf /root/.cargo/git

# ====

FROM ubuntu:18.04

WORKDIR /root

RUN apt update && \
    apt upgrade -y && \
    apt install -y curl vim wget gnupg apt-transport-https software-properties-common apt-utils && \
    apt autoremove -y && \
    apt clean -y

COPY --from=0 /root/phost .
ADD dockerfile.d/start_phost.sh ./start_phost.sh

ENV PRUNTIME_ENDPOINT='http://127.0.0.1:8000'
ENV PHALA_NODE_WS_ENDPOINT='ws://127.0.0.1:9944'
ENV MNEMONIC=''
ENV EXTRA_OPTS='-r'
ENV SLEEP_BEFORE_START=0

CMD bash ./start_phost.sh
