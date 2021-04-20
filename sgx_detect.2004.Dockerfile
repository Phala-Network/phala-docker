FROM ubuntu:20.04 AS builder

ARG DEBIAN_FRONTEND='noninteractive'
ARG RUST_TOOLCHAIN='nightly-2020-04-20'

WORKDIR /root

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y apt-utils apt-transport-https software-properties-common readline-common curl vim wget gnupg gnupg2 gnupg-agent ca-certificates unzip lsb-release debhelper cmake reprepro autoconf automake bison build-essential curl dpkg-dev expect flex gcc gdb git git-core gnupg kmod libboost-system-dev libboost-thread-dev libcurl4-openssl-dev libiptcdata0-dev libjsoncpp-dev liblog4cpp5-dev libprotobuf-dev libssl-dev libtool libxml2-dev uuid-dev ocaml ocamlbuild pkg-config protobuf-compiler python texinfo llvm clang libclang-dev && \ 
    apt-get autoremove -y && \
    apt-get clean -y

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain="${RUST_TOOLCHAIN}" && \
    $HOME/.cargo/bin/rustup target add x86_64-fortanix-unknown-sgx --toolchain "${RUST_TOOLCHAIN}" && \
    $HOME/.cargo/bin/cargo install fortanix-sgx-tools sgxs-tools

# ====

FROM ubuntu:20.04

ARG DEBIAN_FRONTEND='noninteractive'

WORKDIR /root

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y apt-utils apt-transport-https software-properties-common readline-common curl vim wget gnupg gnupg2 gnupg-agent ca-certificates && \
    apt-get autoremove -y && \
    apt-get clean -y

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

COPY --from=builder /root/.cargo/bin/sgx-detect .
ADD prebuilt/ra-test/app .
ADD prebuilt/ra-test/enclave.signed.so .
ADD dockerfile.d/start_sgx_detect.sh ./start_sgx_detect.sh

ENV SLEEP_BEFORE_START=6

CMD bash ./start_sgx_detect.sh
