FROM ubuntu:18.04

ARG PSW_VERSION='2.11.100.2-bionic1'

ENV SGX_MODE="HW"

WORKDIR /root

RUN apt update && \ 
    apt install -y curl vim wget gnupg apt-transport-https software-properties-common apt-utils && \
    curl -fsSL https://download.01.org/intel-sgx/sgx_repo/ubuntu/intel-sgx-deb.key | apt-key add - && \
    add-apt-repository "deb https://download.01.org/intel-sgx/sgx_repo/ubuntu bionic main" && \
    apt upgrade -y && \
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
    apt autoremove -y && \
    apt clean -y

ADD prebuilt/app .
ADD prebuilt/enclave.signed.so .
ADD prebuilt/Rocket.toml .

ADD dockerfile.d/start_pruntime.sh ./start_pruntime.sh

EXPOSE 8000

CMD bash ./start_pruntime.sh
