FROM ubuntu:20.04

ARG DEBIAN_FRONTEND='noninteractive'

WORKDIR /root

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y apt-utils apt-transport-https software-properties-common readline-common curl vim wget gnupg gnupg2 gnupg-agent ca-certificates && \
    apt-get autoremove -y && \
    apt-get clean -y

ARG PSW_VERSION='2.12.100.3-focal1'

ENV SGX_MODE="HW"

RUN curl -fsSL https://download.01.org/intel-sgx/sgx_repo/ubuntu/intel-sgx-deb.key | apt-key add - && \
    add-apt-repository "deb https://download.01.org/intel-sgx/sgx_repo/ubuntu focal main" && \
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
    apt-get clean -y

ADD prebuilt/app .
ADD prebuilt/enclave.signed.so .
ADD prebuilt/Rocket.toml .
ADD dockerfile.d/start_pruntime.sh ./start_pruntime.sh

EXPOSE 8000

CMD bash ./start_pruntime.sh
