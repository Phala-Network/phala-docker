FROM ubuntu:20.04 AS builder
ARG DEBIAN_FRONTEND='noninteractive'
WORKDIR /root

# System dependencies

RUN apt-get update && apt-get install -y cmake curl clang git pkg-config libssl-dev && \
    apt-get autoremove -y && \
    apt-get clean -y

# Rustup
ARG RUST_TOOLCHAIN='nightly-2020-11-19'

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain none
ENV PATH "$PATH:/root/.cargo/bin"

RUN rustup install "${RUST_TOOLCHAIN}"
ARG ENABLE_FAILPOINTS

# Fetch & compile code

ARG GIT_REPO='https://github.com/diem/diem.git'
# The commit for pdiem-m3 development
ARG GIT_TAG='afe6044c6aea789aca8c701465ce020301880084'

RUN git clone -j 8 ${GIT_REPO} diem && \
    cd diem && \
    git checkout "${GIT_TAG}" && \
    git submodule update --init --depth 1 --recursive -j 8 && \
    cargo build --release && \
    cargo build --release -p cli && \
    cp ./target/release/diem-node /root/ && \
    cp ./target/release/cli /root/ && \
    rm -rf /root/.cargo/registry && \
    rm -rf /root/.cargo/git

# ====

FROM ubuntu:20.04

ARG DEBIAN_FRONTEND='noninteractive'

RUN apt-get update && apt-get install -y libssl1.1 && apt-get clean && rm -r /var/lib/apt/lists/*

COPY --from=builder /root/diem-node /root
COPY --from=builder /root/cli /root
COPY ./dockerfile.d/diem-cli.sh /root
# Pin the mnenomic file because we hardcoded the deposit addresse in the pdiem-m3 demo
COPY ./dockerfile.d/client.mnemonic /root
WORKDIR /root

# JSON RPC
EXPOSE 8080
# Validator network
EXPOSE 7180
# Metrics
EXPOSE 9101

# Capture backtrace on error
ENV RUST_BACKTRACE 1
