FROM ubuntu:20.04

ARG DEBIAN_FRONTEND='noninteractive'
ARG RUST_TOOLCHAIN='nightly-2020-11-10'
ARG PHALA_GIT_REPO='https://github.com/Phala-Network/phala-blockchain.git'
ARG PHALA_GIT_TAG='master'

WORKDIR /root

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y apt-utils apt-transport-https software-properties-common readline-common curl vim wget gnupg gnupg2 gnupg-agent ca-certificates cmake pkg-config libssl-dev git build-essential llvm clang libclang-dev && \
    apt-get autoremove -y && \
    apt-get clean -y

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

FROM ubuntu:20.04

ARG DEBIAN_FRONTEND='noninteractive'

WORKDIR /root

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y apt-utils apt-transport-https software-properties-common readline-common curl vim wget gnupg gnupg2 gnupg-agent ca-certificates && \
    apt-get autoremove -y && \
    apt-get clean -y

ENV NODE_NAME='phala-node'
ENV EXTRA_OPTS=''

COPY --from=0 /root/phala-node .
ADD dockerfile.d/start_node.sh ./start_node.sh

EXPOSE 9615
EXPOSE 9933
EXPOSE 9944
EXPOSE 30333

CMD bash ./start_node.sh
