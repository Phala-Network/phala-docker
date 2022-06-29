FROM ubuntu:20.04 AS builder

RUN apt-get update && \
    apt-get install -y apt-utils apt-transport-https software-properties-common readline-common curl vim wget gnupg gnupg2 gnupg-agent ca-certificates tini

RUN curl -fsSL https://download.01.org/intel-sgx/sgx_repo/ubuntu/intel-sgx-deb.key | apt-key add - && \
    echo 'deb [arch=amd64] https://download.01.org/intel-sgx/sgx_repo/ubuntu focal main' | tee /etc/apt/sources.list.d/intel-sgx.list

RUN curl -fsSLo /usr/share/keyrings/gramine-keyring.gpg https://packages.gramineproject.io/gramine-keyring.gpg && \
    echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/gramine-keyring.gpg] https://packages.gramineproject.io/ stable main' | tee /etc/apt/sources.list.d/gramine.list

RUN apt-get update && \
    apt-get install -y \
        libsgx-headers \
        libsgx-ae-epid \
        libsgx-ae-le \
        libsgx-ae-pce \
        libsgx-aesm-ecdsa-plugin \
        libsgx-aesm-epid-plugin \
        libsgx-aesm-launch-plugin \
        libsgx-aesm-pce-plugin \
        libsgx-aesm-quote-ex-plugin \
        libsgx-enclave-common \
        libsgx-enclave-common-dev \
        libsgx-epid \
        libsgx-epid-dev \
        libsgx-launch \
        libsgx-launch-dev \
        libsgx-quote-ex \
        libsgx-quote-ex-dev \
        libsgx-uae-service \
        libsgx-urts \
        libsgx-ae-qe3 \
        libsgx-pce-logic \
        libsgx-qe3-logic \
        libsgx-ra-network \
        libsgx-ra-uefi \
        libsgx-dcap-default-qpl \
        sgx-aesm-service \
        gramine && \
    apt-get clean -y

RUN apt-get install -y unzip lsb-release debhelper gettext cmake reprepro autoconf automake bison build-essential curl dpkg-dev expect flex gcc gdb git git-core gnupg kmod libboost-system-dev libboost-thread-dev libcurl4-openssl-dev libiptcdata0-dev libjsoncpp-dev liblog4cpp5-dev libprotobuf-dev libssl-dev libtool libxml2-dev uuid-dev ocaml ocamlbuild pkg-config protobuf-compiler gawk nasm ninja-build python3 python3-pip python3-click python3-jinja2 texinfo llvm clang libclang-dev && \
    apt-get clean -y

ARG RUST_TOOLCHAIN='nightly-2021-04-01'
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain="${RUST_TOOLCHAIN}" && \
    $HOME/.cargo/bin/rustup component add rust-src rust-analysis clippy && \
    $HOME/.cargo/bin/rustup target add wasm32-unknown-unknown

WORKDIR /root

ARG PHALA_GIT_REPO='https://github.com/Phala-Network/phala-blockchain.git'
ARG PHALA_GIT_TAG='master'

RUN git clone --depth 1 --recurse-submodules --shallow-submodules -j 8 -b ${PHALA_GIT_TAG} ${PHALA_GIT_REPO} phala-blockchain

ARG RA_METHOD="epid"
ARG IAS_SPID=""
ARG IAS_API_KEY=""
ARG IAS_ENV="DEV"
ARG SGX_SIGNER_KEY="private.dev.pem"
ARG PRUNTIME_DATA_DIR="/opt/pruntime/data"

COPY priv.build_stage .priv

RUN cd phala-blockchain/standalone/pruntime/gramine-build && \
    PATH="$PATH:$HOME/.cargo/bin" make dist PREFIX=/opt/pruntime && \
    PATH="$PATH:$HOME/.cargo/bin" make clean && \
    rm -rf $HOME/.priv/* && \
    rm -f /opt/pruntime/pruntime.token

# ====

FROM ubuntu:20.04

RUN apt-get update && \
    apt-get install -y apt-utils apt-transport-https software-properties-common readline-common curl vim wget gnupg gnupg2 gnupg-agent ca-certificates tini

RUN curl -fsSL https://download.01.org/intel-sgx/sgx_repo/ubuntu/intel-sgx-deb.key | apt-key add - && \
    echo 'deb [arch=amd64] https://download.01.org/intel-sgx/sgx_repo/ubuntu focal main' | tee /etc/apt/sources.list.d/intel-sgx.list

RUN curl -fsSLo /usr/share/keyrings/gramine-keyring.gpg https://packages.gramineproject.io/gramine-keyring.gpg && \
    echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/gramine-keyring.gpg] https://packages.gramineproject.io/ stable main' | tee /etc/apt/sources.list.d/gramine.list

RUN apt-get update && \
    apt-get install -y \
        libsgx-headers \
        libsgx-ae-epid \
        libsgx-ae-le \
        libsgx-ae-pce \
        libsgx-aesm-ecdsa-plugin \
        libsgx-aesm-epid-plugin \
        libsgx-aesm-launch-plugin \
        libsgx-aesm-pce-plugin \
        libsgx-aesm-quote-ex-plugin \
        libsgx-enclave-common \
        libsgx-enclave-common-dev \
        libsgx-epid \
        libsgx-epid-dev \
        libsgx-launch \
        libsgx-launch-dev \
        libsgx-quote-ex \
        libsgx-quote-ex-dev \
        libsgx-uae-service \
        libsgx-urts \
        libsgx-ae-qe3 \
        libsgx-pce-logic \
        libsgx-qe3-logic \
        libsgx-ra-network \
        libsgx-ra-uefi \
        libsgx-dcap-default-qpl \
        sgx-aesm-service \
        gramine && \
    apt-get clean -y

COPY --from=builder /opt/pruntime /opt/pruntime
ADD dockerfile.d/start_pruntime.sh /opt/pruntime/start_pruntime.sh

# STOPSIGNAL SIGQUIT

WORKDIR /opt/pruntime

ENV RUST_LOG="info"
ENV SGX=1
ENV SLEEP_BEFORE_START=6
ENV EXTRA_OPTS=""

EXPOSE 8000

ENTRYPOINT ["/usr/bin/tini", "--"]

CMD ["/bin/bash", "/opt/pruntime/start_pruntime.sh"]
