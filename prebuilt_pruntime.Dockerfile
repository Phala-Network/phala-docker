FROM ubuntu:20.04

ARG DEBIAN_FRONTEND='noninteractive'

RUN apt-get update && \
    apt-get install -y apt-utils apt-transport-https software-properties-common readline-common curl vim wget gnupg gnupg2 gnupg-agent ca-certificates tini

RUN curl -fsSLo /usr/share/keyrings/gramine-keyring.gpg https://packages.gramineproject.io/gramine-keyring.gpg && \
    add-apt-repository 'deb [arch=amd64 signed-by=/usr/share/keyrings/gramine-keyring.gpg] https://packages.gramineproject.io/ stable main' && \
    curl -fsSL https://download.01.org/intel-sgx/sgx_repo/ubuntu/intel-sgx-deb.key | apt-key add - && \
    add-apt-repository "deb https://download.01.org/intel-sgx/sgx_repo/ubuntu focal main"

RUN apt-get install -y \
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
        libsgx-ra-uefi \
        gramine && \
    apt-get clean -y

WORKDIR /opt

COPY prebuilt/pruntime .
ADD dockerfile.d/start_pruntime.sh ./start_pruntime.sh

ENV RUST_LOG="info"
ENV SGX_MODE="HW"
ENV SLEEP_BEFORE_START=6
ENV EXTRA_OPTS=''

EXPOSE 8000

ENTRYPOINT ["/usr/bin/tini", "--"]

CMD ["/bin/bash", "./start_pruntime.sh"]
