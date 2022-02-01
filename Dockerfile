FROM debian:jessie
MAINTAINER sidibecker [at] hotmail [dot] com

ENV DEBIAN_FRONTEND=noninteractive \
    ANDROID_HOME=/opt/android-sdk-linux \
    NODE_VERSION=14.x \
    NPM_VERSION=6.14.12 \
    IONIC_VERSION=latest \
    CORDOVA_VERSION=9.0.0 \
    GRADLE_VERSION=7.1.1 \
    ANDROID_COMPILE_SDK=30 \
    ANDROID_BUILD_TOOLS=30.0.3 \
    DBUS_SESSION_BUS_ADDRESS=/dev/null

# Install basics
RUN apt-get update &&  \
    apt-get install -y git wget curl unzip build-essential jq && \
    curl -sL https://deb.nodesource.com/setup_"$NODE_VERSION" -o nodesource_setup.sh && \
    chmod 777 nodesource_setup.sh && \
    ./nodesource_setup.sh \
    apt-get update &&  \
    apt-get install -y --force-yes nodejs && \
    npm install -g \ 
    npm@"$NPM_VERSION" \
    cordova@"$CORDOVA_VERSION" \
    @ionic/cli@"$IONIC_VERSION" && \
    npm cache clear --force && \
    mkdir Sources && \
    mkdir -p /root/.cache/yarn/  

# Set the locale
RUN apt-get clean && apt-get update && apt-get install -y locales
RUN echo "LC_ALL=en_US.UTF-8" >> /etc/environment
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
RUN echo "LANG=en_US.UTF-8" > /etc/locale.conf
RUN locale-gen en_US.UTF-8

## JAVA INSTALLATION
RUN echo "deb http://archive.debian.org/debian/ jessie-backports main" >> /etc/apt/sources.list
RUN apt-get -o Acquire::Check-Valid-Until=false update && DEBIAN_FRONTEND=noninteractive apt-get install -y -t jessie-backports --force-yes --no-install-recommends openjdk-8-jdk-headless openjdk-8-jre-headless ca-certificates-java && apt-get clean all

# System libs for android enviroment
RUN echo ANDROID_HOME="${ANDROID_HOME}" >> /etc/environment && \
    dpkg --add-architecture i386 && \
    apt-get update -o Acquire::Check-Valid-Until=false && \
    apt-get install -y --force-yes -t jessie-backports expect ant wget libc6-i386 lib32stdc++6 lib32gcc1 lib32ncurses5 lib32z1 qemu-kvm kmod

RUN apt-get clean && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN sed 's/deb http:\/\/archive.debian.org\/debian\/ jessie-backports main//g' /etc/apt/sources.list > /etc/apt/sources.list

# Install Android Tools
RUN    mkdir  /opt/android-sdk-linux && cd /opt/android-sdk-linux && \
    wget --output-document=android-tools-sdk.zip --quiet https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip && \
    unzip -q android-tools-sdk.zip && \
    rm -f android-tools-sdk.zip

# Install Gradle
RUN    mkdir  /opt/gradle && cd /opt/gradle && \
    wget --output-document=gradle.zip --quiet https://services.gradle.org/distributions/gradle-"$GRADLE_VERSION"-bin.zip && \
    unzip -q gradle.zip && \
    rm -f gradle.zip && \
    chown -R root. /opt

# Setup environment
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:/opt/gradle/gradle-${GRADLE_VERSION}/bin

# Install Android SDK
RUN yes Y | ${ANDROID_HOME}/tools/bin/sdkmanager "build-tools;$ANDROID_BUILD_TOOLS" "platforms;android-$ANDROID_COMPILE_SDK" "platform-tools"

WORKDIR Sources
