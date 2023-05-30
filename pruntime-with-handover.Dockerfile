ARG PRUNTIME_BASE_IMAGE=""
FROM $PRUNTIME_BASE_IMAGE

RUN curl -fsSL https://deno.land/x/install/install.sh | sh

ENV DENO_INSTALL="/root/.deno"
ENV PATH="$DENO_INSTALL/bin:$PATH"

ADD dockerfile.d/start_pruntime_with_handover.sh /opt/pruntime/start_pruntime_with_handover.sh
ADD dockerfile.d/pruntime_handover.ts /opt/pruntime/pruntime_handover.ts

RUN deno cache --reload /opt/pruntime/pruntime_handover.ts 

WORKDIR /opt/pruntime/releases/current

ARG PRUNTIME_VERSION="master"
ARG PRUNTIME_DIR="/opt/pruntime/releases/${PRUNTIME_VERSION}"
ARG REAL_PRUNTIME_DATA_DIR="/opt/pruntime/data/${PRUNTIME_VERSION}"

ENV SGX=1
ENV SKIP_AESMD=0
ENV SLEEP_BEFORE_START=6
ENV RUST_LOG="info"
ENV EXTRA_OPTS=""
ENV DATA_DIR="${REAL_PRUNTIME_DATA_DIR}"

EXPOSE 8000

ENTRYPOINT ["/usr/bin/tini", "--"]

CMD ["/bin/bash", "/opt/pruntime/start_pruntime_with_handover.sh"]
