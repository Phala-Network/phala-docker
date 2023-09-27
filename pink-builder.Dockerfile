FROM --platform=linux/amd64 ubuntu:22.04

ARG TZ="Etc/UTC"
ARG RUST_TOOLCHAIN="1.72.0"
ARG PHALA_GIT_REPO="https://github.com/Phala-Network/phala-blockchain.git"
ARG PHALA_GIT_TAG="master"

WORKDIR /root

RUN DEBIAN_FRONTEND="noninteractive" apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get upgrade -y && \
    DEBIAN_FRONTEND="noninteractive" apt-get install -y apt-utils apt-transport-https software-properties-common readline-common curl vim wget gnupg gnupg2 gnupg-agent ca-certificates cmake pkg-config libssl-dev git build-essential llvm clang libclang-dev rsync libboost-all-dev libssl-dev zlib1g-dev miniupnpc

RUN curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain="${RUST_TOOLCHAIN}" && \
    $HOME/.cargo/bin/rustup target add wasm32-unknown-unknown --toolchain "${RUST_TOOLCHAIN}"

RUN git clone --depth 1 --recurse-submodules --shallow-submodules -j 8 -b ${PHALA_GIT_TAG} ${PHALA_GIT_REPO} phala-blockchain

RUN cd $HOME/phala-blockchain/standalone/pruntime && \
    PATH="$HOME/.cargo/bin:$PATH" cargo fetch

RUN curl -fsSLo /usr/share/keyrings/intel-sgx-deb.asc https://download.01.org/intel-sgx/sgx_repo/ubuntu/intel-sgx-deb.key && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/intel-sgx-deb.asc] https://download.01.org/intel-sgx/sgx_repo/ubuntu $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/intel-sgx.list

RUN curl -fsSLo /usr/share/keyrings/gramine-keyring.gpg https://packages.gramineproject.io/gramine-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/gramine-keyring.gpg] https://packages.gramineproject.io/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/gramine.list

RUN DEBIAN_FRONTEND="noninteractive" apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get install -y \
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

RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y rsync unzip lsb-release debhelper gettext cmake reprepro autoconf automake bison build-essential curl dpkg-dev expect flex gcc gdb git git-core gnupg kmod libboost-system-dev libboost-thread-dev libcurl4-openssl-dev libiptcdata0-dev libjsoncpp-dev liblog4cpp5-dev libprotobuf-dev libssl-dev libtool libxml2-dev uuid-dev ocaml ocamlbuild pkg-config protobuf-compiler gawk nasm ninja-build python3 python3-pip python3-click python3-jinja2 texinfo llvm clang libclang-dev && \
    DEBIAN_FRONTEND="noninteractive" apt-get clean -y

ARG PHALA_CARGO_PROFILE="release"
ARG PREBUILT_PINK_RUNTIMES_PROFILE="production"

RUN cd $HOME/phala-blockchain/standalone/pruntime/gramine-build && \
    PATH="$PATH:$HOME/.cargo/bin" make pre-dist PREFER_PREBUILT_PINK_LIBS=0 BUILD="${PHALA_CARGO_PROFILE}"

WORKDIR /root/phala-blockchain/standalone/pruntime/bin

ENTRYPOINT ["/bin/bash"]
