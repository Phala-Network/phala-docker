FROM ubuntu:20.04 AS builder

RUN set -ex; \
    apt-get update; \
    apt-get install -y python3 python3-pip python3-venv; \
    rm -rf /var/lib/apt/lists/

RUN mkdir /opt/pruntime-telemetry
RUN python3 -m venv /opt/pruntime-telemetry
ENV PATH=/opt/pruntime-telemetry/bin:$PATH
RUN pip install requests sentry-sdk

FROM ubuntu:20.04

ARG DEBIAN_FRONTEND='noninteractive'

WORKDIR /root

RUN set -ex; \
    apt-get update; \
    apt-get install -y apt-utils apt-transport-https software-properties-common readline-common curl vim wget gnupg gnupg2 gnupg-agent ca-certificates tini; \
    rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://download.01.org/intel-sgx/sgx_repo/ubuntu/intel-sgx-deb.key | apt-key add - && \
    add-apt-repository "deb https://download.01.org/intel-sgx/sgx_repo/ubuntu focal main" && \
    apt-get install -y \
        sgx-aesm-service \
        libsgx-ae-epid \
        libsgx-ae-le \
        libsgx-ae-pce \
        libsgx-aesm-ecdsa-plugin \
        libsgx-aesm-epid-plugin \
        libsgx-aesm-launch-plugin \
        libsgx-aesm-pce-plugin \
        libsgx-aesm-quote-ex-plugin \
        libsgx-enclave-common \
        libsgx-epid \
        libsgx-launch \
        libsgx-quote-ex \
        libsgx-uae-service \
        libsgx-urts \
        libsgx-ae-qe3 \
        libsgx-pce-logic \
        libsgx-qe3-logic \
        libsgx-dcap-default-qpl \
        libsgx-ra-network \
        libsgx-ra-uefi && \
    rm -rf /var/lib/apt/lists/*

ADD prebuilt/pruntime/app .
ADD prebuilt/pruntime/enclave.signed.so .
ADD prebuilt/pruntime/Rocket.toml .
ADD dockerfile.d/start_pruntime.sh ./start_pruntime.sh
ADD dockerfile.d/pruntime_telemetry.py ./pruntime_telemetry.py

ENV TELEMETRY_URL="https://pruntime-telemetry.phala.network/khala/"
COPY --from=builder /opt/pruntime-telemetry /opt/pruntime-telemetry

ENV RUST_LOG="info"
ENV SGX_MODE="HW"
ENV SLEEP_BEFORE_START=6
ENV EXTRA_OPTS=''

EXPOSE 8000

ENTRYPOINT ["/usr/bin/tini", "--"]

CMD ["/bin/bash", "./start_pruntime.sh"]
