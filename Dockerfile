FROM  adoptopenjdk/openjdk11:alpine
MAINTAINER sidibecker [at] hotmail [dot] com

ENV DEBIAN_FRONTEND=noninteractive \
    ANDROID_HOME=/opt/android-sdk-linux \
    NODE_VERSION=14.x \
    NPM_VERSION=6.14.12 \
    IONIC_VERSION=latest \
    CORDOVA_VERSION=10.0.0 \
    GRADLE_VERSION=7.1.1 \
    ANDROID_COMPILE_SDK=31 \
    ANDROID_BUILD_TOOLS=32.0.0 \
    DBUS_SESSION_BUS_ADDRESS=/dev/null


RUN ls
#RUN dpkg-reconfigure -f noninteractive tzdata
RUN apk add tzdata
RUN cp /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
RUN echo "America/Sao_Paulo" > /etc/timezone
RUN date

# Install basics
RUN apk update 
RUN apk add --no-cache --upgrade bash

RUN apk add --virtual build-dependencies
RUN apk add git wget curl unzip jq 
RUN apk add npm
RUN apk update &&  \
    apk add nodejs && \
    npm install -g \ 
    npm@"$NPM_VERSION" \
    cordova@"$CORDOVA_VERSION" \
    @ionic/cli@"$IONIC_VERSION" && \
    npm cache clear --force && \
    mkdir Sources && \
    mkdir -p /root/.cache/yarn/  

# Set the locale
#RUN apk add locales
RUN echo "LC_ALL=en_US.UTF-8" >> /etc/environment
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
RUN echo "LANG=en_US.UTF-8" > /etc/locale.conf
#RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8



## JAVA INSTALLATION
#RUN echo "deb http://archive.debian.org/debian/ jessie-backports main" >> /etc/apt/sources.list
#RUN add-apt-repository ppa:openjdk-r/ppa
#RUN apk update
#RUN apk -o Acquire::Check-Valid-Until=false update && DEBIAN_FRONTEND=noninteractive apk add -y -t jessie-backports --force-yes --no-install-recommends openjdk-11-jdk ca-certificates-java && apk clean all
RUN java -version

RUN apk add libstdc++6
#RUN apk add libc6-compat
# System libs for android enviroment
RUN echo ANDROID_HOME="${ANDROID_HOME}" >> /etc/environment && \
    #dpkg --add-architecture i386 && \
    #apk update -o Acquire::Check-Valid-Until=false && \
    apk add \
    expect \ 
    apache-ant \
     wget \
     # libc6-compat  \
        libgcc \ 
        #ncurses5 \
         #zlib-dev \
          qemu \ 
         kmod

RUN 
#apk clean && \
   # apk autoclean && \
RUN    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


#RUN sed 's/deb http:\/\/archive.debian.org\/debian\/ jessie-backports main//g' /etc/apt/sources.list > /etc/apt/sources.list

# Install Android Tools
RUN    mkdir  /opt/android-sdk-linux && cd /opt/android-sdk-linux && \
    wget --output-document=android-tools-sdk.zip --quiet https://dl.google.com/android/repository/commandlinetools-linux-8512546_latest.zip && \
    unzip -q android-tools-sdk.zip && \
    rm -f android-tools-sdk.zip

# Install Gradle
RUN    mkdir  /opt/gradle && cd /opt/gradle && \
    wget --output-document=gradle.zip --quiet https://services.gradle.org/distributions/gradle-"$GRADLE_VERSION"-bin.zip && \
    unzip -q gradle.zip && \
    rm -f gradle.zip && \
    chown -R root. /opt

# Setup environment
ENV PATH ${PATH}:${ANDROID_HOME}/cmdline-tools:${ANDROID_HOME}/cmdline-tools/bin:${ANDROID_HOME}/platform-tools:/opt/gradle/gradle-${GRADLE_VERSION}/bin

# Install Android SDK
RUN yes Y | ${ANDROID_HOME}/cmdline-tools/bin/sdkmanager --sdk_root="${ANDROID_HOME}/cmdline-tools" "build-tools;$ANDROID_BUILD_TOOLS" "platforms;android-$ANDROID_COMPILE_SDK" "platform-tools"

WORKDIR Sources
