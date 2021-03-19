FROM node:12.21.0-alpine AS base

WORKDIR /opt/nodejs

RUN apk --no-cache add \
    bash \
    g++ \
    ca-certificates \
    lz4-dev \
    musl-dev \
    cyrus-sasl-dev \
    openssl-dev \
    make \
    python3

RUN apk add --no-cache --virtual .build-deps gcc zlib-dev libc-dev bsd-compat-headers py-setuptools bash

COPY package.json ./package.json
COPY package-lock.json ./package-lock.json

RUN npm install --production


FROM node:12.21.0-alpine
WORKDIR /opt/nodejs

RUN apk --no-cache add \
    libsasl \
    lz4-libs

COPY --from=base /opt/nodejs /opt/nodejs

COPY src ./src
CMD ["node", "--unhandled-rejections=strict", "src/index.js"]