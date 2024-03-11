FROM --platform=linux/amd64 buildpack-deps:jammy-curl

ARG TZ="Etc/UTC"

RUN set -ex; \
    curl -fsSLo /usr/share/keyrings/intel-sgx-deb.asc https://download.01.org/intel-sgx/sgx_repo/ubuntu/intel-sgx-deb.key; \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/intel-sgx-deb.asc] https://download.01.org/intel-sgx/sgx_repo/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) main" | tee /etc/apt/sources.list.d/intel-sgx.list; \
    curl -fsSLo /usr/share/keyrings/gramine-keyring.gpg https://packages.gramineproject.io/gramine-keyring.gpg; \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/gramine-keyring.gpg] https://packages.gramineproject.io/ $(. /etc/os-release && echo $VERSION_CODENAME) main" | tee /etc/apt/sources.list.d/gramine.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
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
        libsgx-ae-qe3 \
        libsgx-pce-logic \
        libsgx-qe3-logic \
        libsgx-ra-network \
        libsgx-ra-uefi \
        libsgx-dcap-default-qpl \
        libsgx-dcap-default-qpl-dev \
        libsgx-dcap-quote-verify \
        libsgx-dcap-quote-verify-dev \
        libsgx-dcap-ql \
        libsgx-dcap-ql-dev \
        sgx-aesm-service \
        gramine \
    ; \
    rm -rf /var/lib/apt/lists/*

COPY --from=phalanetwork/phala-pruntime-v2-binary-ias:23041501 /opt/pruntime/releases/23041501 /opt/pruntime/releases/23041501
COPY --from=phalanetwork/phala-pruntime-v2-binary-ias:23082901 /opt/pruntime/releases/23082901 /opt/pruntime/releases/23082901
COPY --from=phalanetwork/phala-pruntime-v2-binary-ias:24011901 /opt/pruntime/releases/24011901 /opt/pruntime/releases/24011901

RUN set -ex; mkdir -p /opt/pruntime/data/23041501; ln -s /opt/pruntime/data/23041501 /opt/pruntime/releases/23041501/data
RUN set -ex; mkdir -p /opt/pruntime/data/23082901; ln -s /opt/pruntime/data/23082901 /opt/pruntime/releases/23082901/data
RUN set -ex; mkdir -p /opt/pruntime/data/24011901; ln -s /opt/pruntime/data/24011901 /opt/pruntime/releases/24011901/data

ARG PRUNTIME_VERSION="24011901"
ARG PRUNTIME_DIR="/opt/pruntime/releases/${PRUNTIME_VERSION}"
ARG PRUNTIME_DATA_DIR="/opt/pruntime/${PRUNTIME_VERSION}/data"
ARG REAL_PRUNTIME_DATA_DIR="/opt/pruntime/data/${PRUNTIME_VERSION}"

ADD dockerfile.d/start_pruntime.sh ${PRUNTIME_DIR}/start_pruntime.sh

RUN ln -s ${PRUNTIME_DIR} /opt/pruntime/releases/current

ADD dockerfile.d/conf /opt/conf

RUN set -ex; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        tini \
        unzip \
    ; \
    rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deno.land/x/install/install.sh | sh

ENV DENO_INSTALL="/root/.deno"
ENV PATH="$DENO_INSTALL/bin:$PATH"

ADD dockerfile.d/start_pruntime_with_handover.sh /opt/pruntime/start_pruntime_with_handover.sh
ADD dockerfile.d/pruntime_handover.ts /opt/pruntime/pruntime_handover.ts

RUN deno cache --reload /opt/pruntime/pruntime_handover.ts

WORKDIR /opt/pruntime/releases/current

ENV SGX=1
ENV SKIP_AESMD=0
ENV SLEEP_BEFORE_START=6
ENV RUST_LOG="info"
ENV EXTRA_OPTS=""
ENV DATA_DIR="${REAL_PRUNTIME_DATA_DIR}"

EXPOSE 8000

ENTRYPOINT ["/usr/bin/tini", "--"]

CMD ["/bin/bash", "/opt/pruntime/start_pruntime_with_handover.sh"]
