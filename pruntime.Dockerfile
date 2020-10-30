FROM ubuntu:18.04

ARG DEBIAN_FRONTEND='noninteractive'
ARG RUST_TOOLCHAIN='nightly-2020-04-07'
ARG PHALA_GIT_REPO='https://github.com/Phala-Network/phala-blockchain.git'
ARG PHALA_GIT_TAG='master'

ARG SGX_MODE="SW"
ARG SGX_SDK_DOWNLOAD_URL="https://download.01.org/intel-sgx/sgx-linux/2.11/distro/ubuntu18.04-server/sgx_linux_x64_sdk_2.11.100.2.bin"
ARG IAS_SPID=''
ARG IAS_API_KEY=''
ARG IAS_ENV='DEV'
ARG SGX_SIGN_KEY_URL=''
ARG SGX_ENCLAVE_CONFIG_URL=''

WORKDIR /root

RUN apt update && \
    apt upgrade -y && \
    apt install -y autoconf automake bison build-essential cmake curl dpkg-dev expect flex gcc-8 gdb git git-core gnupg kmod libboost-system-dev libboost-thread-dev libcurl4-openssl-dev libiptcdata0-dev libjsoncpp-dev liblog4cpp5-dev libprotobuf-c0-dev libprotobuf-dev libssl-dev libtool libxml2-dev ocaml ocamlbuild pkg-config protobuf-compiler python sudo systemd-sysv texinfo uuid-dev vim wget dkms gnupg2 apt-transport-https software-properties-common apt-utils && \
    apt autoremove -y && \
    apt clean -y

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
    cd phala-blockchain/pruntime && \
    PATH="$PATH:$HOME/.cargo/bin" SGX_SDK="/opt/intel/sgxsdk" SGX_MODE="$SGX_MODE" make && \
    cp ./bin/app /root/ && \
    cp ./bin/enclave.signed.so /root/ && \
    cp ./bin/Rocket.toml /root/ && \
    PATH="$PATH:$HOME/.cargo/bin" make clean && \
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

ARG SGX_MODE="SW"
ARG PSW_VERSION='2.11.100.2-bionic1'

ENV SGX_MODE="$SGX_MODE"

RUN curl -fsSL https://download.01.org/intel-sgx/sgx_repo/ubuntu/intel-sgx-deb.key | apt-key add - && \
    add-apt-repository "deb https://download.01.org/intel-sgx/sgx_repo/ubuntu bionic main" && \
    apt-get install -y \
        libsgx-aesm-launch-plugin="$PSW_VERSION" \
        libsgx-enclave-common="$PSW_VERSION" \
        libsgx-enclave-common-dev="$PSW_VERSION" \
        libsgx-epid="$PSW_VERSION" \
        libsgx-epid-dev="$PSW_VERSION" \
        libsgx-launch="$PSW_VERSION" \
        libsgx-launch-dev="$PSW_VERSION" \
        libsgx-quote-ex="$PSW_VERSION" \
        libsgx-quote-ex-dev="$PSW_VERSION" \
        libsgx-uae-service="$PSW_VERSION" \
        libsgx-urts="$PSW_VERSION" && \
    apt clean -y

COPY --from=0 /opt/intel /opt/intel
COPY --from=0 /root/enclave.signed.so .
COPY --from=0 /root/app .
COPY --from=0 /root/Rocket.toml .
ADD dockerfile.d/start_pruntime.sh ./start_pruntime.sh

EXPOSE 8000

CMD bash ./start_pruntime.sh
