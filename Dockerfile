FROM node:10-alpine
MAINTAINER marco [dot] turi [at] hotmail [dot] it

ENV IONIC_VERSION=5.2.8 \
    CORDOVA_VERSION=9.0.0

RUN sed -i -e 's/v3.9/edge/g' /etc/apk/repositories \
    && apk add --no-cache \
    build-base \
    openjdk8-jre-base \
    # chromium dependencies
    nss \
    chromium-chromedriver \
    chromium  \
    && apk upgrade --no-cache --available && \
    npm install -g cordova@"$CORDOVA_VERSION" ionic@"$IONIC_VERSION"

USER node

ENV CHROME_BIN /usr/bin/chromium-browser
