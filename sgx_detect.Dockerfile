FROM ubuntu:20.04 AS builder

ARG RUST_TOOLCHAIN='nightly-2022-10-22'

WORKDIR /root

RUN apt-get update && \
    DEBIAN_FRONTEND='noninteractive' apt-get install -y apt-utils apt-transport-https software-properties-common readline-common curl vim wget gnupg gnupg2 gnupg-agent ca-certificates cmake pkg-config libssl-dev git build-essential llvm clang libclang-dev rsync libboost-all-dev libssl-dev zlib1g-dev miniupnpc protobuf-compiler

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain="${RUST_TOOLCHAIN}" && \
    $HOME/.cargo/bin/rustup target add x86_64-fortanix-unknown-sgx --toolchain "${RUST_TOOLCHAIN}" && \
    $HOME/.cargo/bin/cargo install fortanix-sgx-tools sgxs-tools && \
    echo >> $HOME/.cargo/config -e '[target.x86_64-fortanix-unknown-sgx]\nrunner = "ftxsgx-runner-cargo"'

# ====

FROM ubuntu:20.04

ARG TZ='Etc/UTC'

RUN DEBIAN_FRONTEND='noninteractive' apt-get update && \
    DEBIAN_FRONTEND='noninteractive' apt-get upgrade -y && \
    DEBIAN_FRONTEND='noninteractive' apt-get install -y apt-utils apt-transport-https software-properties-common readline-common curl vim wget gnupg gnupg2 gnupg-agent ca-certificates git unzip tini

RUN curl -fsSL https://download.01.org/intel-sgx/sgx_repo/ubuntu/intel-sgx-deb.key | apt-key add - && \
    add-apt-repository "deb https://download.01.org/intel-sgx/sgx_repo/ubuntu focal main" && \
    DEBIAN_FRONTEND='noninteractive' apt-get install -y \
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

COPY --from=builder /root/.cargo/bin/sgx-detect /root
ADD prebuilt/ra-test/app /root
ADD prebuilt/ra-test/enclave.signed.so /root
ADD dockerfile.d/start_sgx_detect.sh /root/start_sgx_detect.sh

WORKDIR /root

ENV RUST_LOG="info"
ENV SLEEP_BEFORE_START=12

ENTRYPOINT ["/usr/bin/tini", "--"]

CMD ["/bin/bash", "./start_sgx_detect.sh"]
