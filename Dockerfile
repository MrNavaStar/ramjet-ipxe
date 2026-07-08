FROM debian:bookworm

RUN apt update && \
	apt install --no-install-recommends --no-install-suggests -y \
		software-properties-common \
		build-essential \
		make \
		gcc \
		binutils \
		perl \
		liblzma5 \
		liblzma-dev \
		xz-utils \
		git \
		gcc-aarch64-linux-gnu \
		gcc-arm-linux-gnueabi \
        && \
    rm -rf /var/lib/apt/lists/*

COPY builder.sh /builder.sh

ARG IPXE_TAG
RUN git clone --branch ${IPXE_TAG} --depth 1 https://github.com/ipxe/ipxe.git

WORKDIR /ipxe/src
ENTRYPOINT ["/builder.sh", "custom"]