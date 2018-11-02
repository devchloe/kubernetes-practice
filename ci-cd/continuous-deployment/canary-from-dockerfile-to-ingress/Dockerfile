FROM node:6.9.2
ARG version=1.0
EXPOSE 8080
COPY source/$version/server.js .
ENTRYPOINT ["node", "server.js"]
