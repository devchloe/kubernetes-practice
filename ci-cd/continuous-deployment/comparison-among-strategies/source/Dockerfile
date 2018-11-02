FROM node:8
ARG version=1.0

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY $version/package*.json ./
RUN npm install

COPY $version/server.js .
EXPOSE 8080
ENTRYPOINT ["npm", "start"]