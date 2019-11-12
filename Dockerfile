#FROM node:9.4.0-alpine
#FROM ibmcom/icp-nodejs-sample
FROM <baseimage>:<tag>
#COPY elasticproxy.js ./
#COPY package.json .
#instead copy everything, because node_modules have to be copied to the image. 
#In an airgapped environment, npm install won't work
COPY . .
RUN mkdir /usr/share/elasticproxy
RUN mkdir /usr/share/elasticproxy/backend
RUN mkdir /usr/share/elasticproxy/frontend
#RUN npm install &&    apk update &&    apk upgrade
EXPOSE  8080
CMD node elasticproxy.js

