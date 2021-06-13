FROM ubuntu:20.04

ARG DEBIAN_FRONTEND='noninteractive'

WORKDIR /root

RUN apt-get update && \
    apt-get install -y apt-utils apt-transport-https software-properties-common readline-common curl vim wget gnupg gnupg2 gnupg-agent ca-certificates tini

ARG PSW_VERSION='2.13.103.1-focal1'
ARG DCAP_VERSION='1.10.103.1-focal1'

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

ADD prebuilt/pruntime/app .
ADD prebuilt/pruntime/enclave.signed.so .
ADD prebuilt/pruntime/Rocket.toml .
ADD dockerfile.d/start_pruntime.sh ./start_pruntime.sh

ENV SGX_MODE="HW"
ENV SLEEP_BEFORE_START=6
ENV EXTRA_OPTS=''

EXPOSE 8000

ENTRYPOINT ["/usr/bin/tini", "--"]

CMD ["/bin/bash", "./start_pruntime.sh"]
