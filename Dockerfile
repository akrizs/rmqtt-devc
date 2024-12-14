FROM rust:1-alpine3.20

ARG TARGET_ARCH=aarch64-unknown-linux-musl

RUN apk update && apk add --no-cache \
    openssl \
    openssl-dev \
    openssl-libs-static \
    protoc \
    build-base \
    zlib-dev \
    zlib-static \
    pkgconfig \
    cmake \
    git \
    curl \
    perl \
    make \
    linux-headers \
    file \
    openssh

ENV TARGET_ARCH=${TARGET_ARCH} \
    CC=gcc \
    CXX=g++ \
    OPENSSL_DIR="/usr" \
    OPENSSL_NO_VENDOR=1 \
    OPENSSL_STATIC=1 \
    RUSTFLAGS="-C target-feature=+crt-static"