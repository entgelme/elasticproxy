FROM node:9.4.0-alpine
COPY elasticproxy.js ./
COPY package.json .
RUN mkdir /usr/share/elasticproxy
RUN mkdir /usr/share/elasticproxy/backend
RUN mkdir /usr/share/elasticproxy/frontend
RUN npm install &&\
    apk update &&\
    apk upgrade
EXPOSE  8080
CMD npm start
