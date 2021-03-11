FROM ubuntu:20.04 AS builder

ARG DEBIAN_FRONTEND='noninteractive'
ARG RUST_TOOLCHAIN='nightly-2020-11-10'
ARG PHALA_GIT_REPO='https://github.com/Phala-Network/phala-blockchain.git'
ARG PHALA_GIT_TAG='master'

ARG SGX_MODE="SW"
ARG SGX_SDK_DOWNLOAD_URL="https://download.01.org/intel-sgx/sgx-linux/2.13/distro/ubuntu20.04-server/sgx_linux_x64_sdk_2.13.100.4.bin"
ARG IAS_SPID=''
ARG IAS_API_KEY=''
ARG IAS_ENV='DEV'
ARG SGX_SIGN_KEY_URL=''
ARG SGX_ENCLAVE_CONFIG_URL=''

WORKDIR /root

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y apt-utils apt-transport-https software-properties-common readline-common curl vim wget gnupg gnupg2 gnupg-agent ca-certificates unzip lsb-release debhelper cmake reprepro autoconf automake bison build-essential curl dpkg-dev expect flex gcc gdb git git-core gnupg kmod libboost-system-dev libboost-thread-dev libcurl4-openssl-dev libiptcdata0-dev libjsoncpp-dev liblog4cpp5-dev libprotobuf-dev libssl-dev libtool libxml2-dev uuid-dev ocaml ocamlbuild pkg-config protobuf-compiler python texinfo llvm clang libclang-dev && \
    apt-get autoremove -y && \
    apt-get clean -y

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain="${RUST_TOOLCHAIN}" && \
    /root/.cargo/bin/cargo install xargo

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
    apt-get upgrade -y && \
    apt-get install -y apt-utils apt-transport-https software-properties-common readline-common curl vim wget gnupg gnupg2 gnupg-agent ca-certificates && \
    apt-get autoremove -y && \
    apt-get clean -y

ARG SGX_MODE="SW"
ARG PSW_VERSION='2.13.100.4-focal1'
ARG DCAP_VERSION='1.10.100.4-focal1'

RUN curl -fsSL https://download.01.org/intel-sgx/sgx_repo/ubuntu/intel-sgx-deb.key | apt-key add - && \
    add-apt-repository "deb https://download.01.org/intel-sgx/sgx_repo/ubuntu focal main" && \
    apt-get install -y \
        libsgx-headers="$PSW_VERSION" \
        libsgx-ae-epid="$PSW_VERSION" \
        libsgx-ae-le="$PSW_VERSION" \
        libsgx-ae-pce="$PSW_VERSION" \
        libsgx-aesm-ecdsa-plugin="$PSW_VERSION" \
        libsgx-aesm-epid-plugin="$PSW_VERSION" \
        libsgx-aesm-launch-plugin="$PSW_VERSION" \
        libsgx-aesm-pce-plugin="$PSW_VERSION" \
        libsgx-aesm-quote-ex-plugin="$PSW_VERSION" \
        libsgx-enclave-common="$PSW_VERSION" \
        libsgx-enclave-common-dev="$PSW_VERSION" \
        libsgx-epid="$PSW_VERSION" \
        libsgx-epid-dev="$PSW_VERSION" \
        libsgx-launch="$PSW_VERSION" \
        libsgx-launch-dev="$PSW_VERSION" \
        libsgx-quote-ex="$PSW_VERSION" \
        libsgx-quote-ex-dev="$PSW_VERSION" \
        libsgx-uae-service="$PSW_VERSION" \
        libsgx-urts="$PSW_VERSION" \
        sgx-aesm-service="$PSW_VERSION" \
        libsgx-ae-qe3="$DCAP_VERSION" \
        libsgx-pce-logic="$DCAP_VERSION" \
        libsgx-qe3-logic="$DCAP_VERSION" \
        libsgx-ra-network="$DCAP_VERSION" \
        libsgx-ra-uefi="$DCAP_VERSION" && \
    apt-get clean -y

COPY --from=builder /opt/intel /opt/intel
COPY --from=builder /root/enclave.signed.so .
COPY --from=builder /root/app .
COPY --from=builder /root/Rocket.toml .
ADD dockerfile.d/start_pruntime.sh ./start_pruntime.sh

ENV SGX_MODE="$SGX_MODE"
ENV SLEEP_BEFORE_START=6

EXPOSE 8000

CMD bash ./start_pruntime.sh
