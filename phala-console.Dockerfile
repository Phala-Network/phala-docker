FROM node:lts

ADD dockerfile.d/phala-console /root/phala-console
WORKDIR /root/phala-console
RUN yarn

ENTRYPOINT [ "node", "index.js" ]
