 
FROM node:8.14.0-alpine as basis

WORKDIR /opt/nodejs

RUN apk --no-cache add gcc g++ musl-dev make python bash zlib-dev

COPY package.json ./package.json
RUN npm install


FROM node:8.14.0-alpine
RUN apk add --no-cache tini
ENTRYPOINT ["/sbin/tini", "--"]

COPY --from=basis /opt/nodejs /opt/nodejs
WORKDIR /opt/nodejs

COPY src ./src
CMD ["node", "src/index.js"]
