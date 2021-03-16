FROM ubuntu:20.04 AS builder

ARG DEBIAN_FRONTEND='noninteractive'
ARG RUST_TOOLCHAIN='nightly-2020-11-10'
ARG GIT_REPO='https://github.com/Phala-Network/pdiem-relayer.git'
ARG GIT_TAG='pdiem-m3'

WORKDIR /root

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y apt-utils apt-transport-https software-properties-common readline-common curl vim wget gnupg gnupg2 gnupg-agent ca-certificates cmake pkg-config libssl-dev git build-essential llvm clang libclang-dev && \
    apt-get autoremove -y && \
    apt-get clean -y

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain="${RUST_TOOLCHAIN}"

RUN echo "Compiling Phala Blockchain from $GIT_REPO:$GIT_TAG..." && \
    git clone --depth 1 --recurse-submodules --shallow-submodules -j 8 -b ${GIT_TAG} ${GIT_REPO} pdiem-relayer && \
    cd pdiem-relayer && \
    PATH="$HOME/.cargo/bin:$PATH" cargo build --release && \
    cp ./target/release/pdiem /root && \
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

COPY --from=builder /root/pdiem .

CMD /root/pdiem
