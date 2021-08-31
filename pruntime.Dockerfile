FROM ubuntu:20.04 AS builder

ARG DEBIAN_FRONTEND='noninteractive'
ARG RUST_TOOLCHAIN='nightly-2021-07-03'
ARG PHALA_GIT_REPO='https://github.com/Phala-Network/phala-blockchain.git'
ARG PHALA_GIT_TAG='master'

ARG SGX_MODE="SW"
ARG SGX_SDK_DOWNLOAD_URL="https://download.01.org/intel-sgx/sgx-linux/2.14/distro/ubuntu20.04-server/sgx_linux_x64_sdk_2.14.100.2.bin"
ARG IAS_SPID=''
ARG IAS_API_KEY=''
ARG IAS_ENV='DEV'
ARG SGX_SIGN_KEY_URL=''
ARG SGX_ENCLAVE_CONFIG_URL=''

WORKDIR /root

RUN apt-get update && \
    apt-get install -y apt-utils apt-transport-https software-properties-common readline-common curl vim wget gnupg gnupg2 gnupg-agent ca-certificates unzip lsb-release debhelper gettext cmake reprepro autoconf automake bison build-essential curl dpkg-dev expect flex gcc gdb git git-core gnupg kmod libboost-system-dev libboost-thread-dev libcurl4-openssl-dev libiptcdata0-dev libjsoncpp-dev liblog4cpp5-dev libprotobuf-dev libssl-dev libtool libxml2-dev uuid-dev ocaml ocamlbuild pkg-config protobuf-compiler python texinfo llvm clang libclang-dev

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain="${RUST_TOOLCHAIN}"

RUN echo "Compiling Phala Blockchain from $PHALA_GIT_REPO:$PHALA_GIT_TAG..." && \
    cd /root && \
    wget "$SGX_SDK_DOWNLOAD_URL" -t 3 -O sgx_linux_sdk.bin && \
    chmod +x ./sgx_linux_sdk.bin && \
    echo -e 'no\n/opt/intel' | ./sgx_linux_sdk.bin && \
    echo 'source /opt/intel/sgxsdk/environment' >> /root/.bashrc && \
    rm -rf ./sgx_linux_sdk.bin

RUN git clone --depth 1 --recurse-submodules --shallow-submodules -j 8 -b ${PHALA_GIT_TAG} ${PHALA_GIT_REPO} phala-blockchain && \
    cd phala-blockchain/standalone/pruntime && \
    PATH="$PATH:$HOME/.cargo/bin" SGX_SDK="/opt/intel/sgxsdk" SGX_MODE="$SGX_MODE" make && \
    cp ./bin/app /root/ && \
    cp ./bin/enclave.signed.so /root/ && \
    cp ./bin/Rocket.toml /root/ && \
    PATH="$PATH:$HOME/.cargo/bin" make clean && \
    rm -rf /root/.cargo/registry && \
    rm -rf /root/.cargo/git

# ====

FROM ubuntu:20.04

ARG DEBIAN_FRONTEND='noninteractive'

WORKDIR /root

RUN apt-get update && \
    apt-get install -y apt-utils apt-transport-https software-properties-common readline-common curl vim wget gnupg gnupg2 gnupg-agent ca-certificates tini

ARG SGX_MODE="SW"

RUN curl -fsSL https://download.01.org/intel-sgx/sgx_repo/ubuntu/intel-sgx-deb.key | apt-key add - && \
    add-apt-repository "deb https://download.01.org/intel-sgx/sgx_repo/ubuntu focal main" && \
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
        sgx-aesm-service \
        libsgx-ae-qe3 \
        libsgx-pce-logic \
        libsgx-qe3-logic \
        libsgx-ra-network \
        libsgx-ra-uefi && \
    apt-get clean -y

COPY --from=builder /opt/intel /opt/intel
COPY --from=builder /root/enclave.signed.so .
COPY --from=builder /root/app .
COPY --from=builder /root/Rocket.toml .
ADD dockerfile.d/start_pruntime.sh ./start_pruntime.sh

ENV RUST_LOG="info"
ENV SGX_MODE="$SGX_MODE"
ENV SLEEP_BEFORE_START=6
ENV EXTRA_OPTS=''

EXPOSE 8000

ENTRYPOINT ["/usr/bin/tini", "--"]

CMD ["/bin/bash", "./start_pruntime.sh"]
