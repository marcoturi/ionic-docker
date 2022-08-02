FROM  adoptopenjdk/openjdk11:alpine
MAINTAINER sidibecker [at] hotmail [dot] com

ENV DEBIAN_FRONTEND=noninteractive \
    ANDROID_DIR=/opt/android \
    NPM_VERSION=6.14.12 \
    IONIC_VERSION=latest \
    CORDOVA_VERSION=10.0.0 \
    GRADLE_VERSION=7.1.1 \
    ANDROID_COMPILE_SDK=31 \
    ANDROID_BUILD_TOOLS=32.0.0 \
    DBUS_SESSION_BUS_ADDRESS=/dev/null

# Timezone
RUN apk add tzdata
RUN cp /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
RUN echo "America/Sao_Paulo" > /etc/timezone
RUN date

# Install basics
RUN apk update 
RUN apk add --no-cache --upgrade bash
RUN apk add libstdc++6 expect apache-ant wget libgcc qemu kmod util-linux

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
RUN echo "LC_ALL=en_US.UTF-8" >> /etc/environment
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
RUN echo "LANG=en_US.UTF-8" > /etc/locale.conf
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Python instalation
RUN apk add --update --no-cache python3 && ln -sf python3 /usr/bin/python 
RUN python3 -m ensurepip
RUN pip3 install --no-cache --upgrade pip
RUN pip install pillow

RUN  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Android Tools
RUN mkdir $ANDROID_DIR && cd $ANDROID_DIR && \
    wget --output-document=android-tools-sdk.zip --quiet https://dl.google.com/android/repository/commandlinetools-linux-8512546_latest.zip && \
    unzip -q android-tools-sdk.zip && \
    rm -f android-tools-sdk.zip  && \
    mv cmdline-tools latest && \
    mkdir sdk && \
    mkdir sdk/cmdline-tools && \
    mv latest sdk/cmdline-tools


# Install Gradle
RUN mkdir /opt/gradle && cd /opt/gradle && \
    wget --output-document=gradle.zip --quiet https://services.gradle.org/distributions/gradle-"$GRADLE_VERSION"-bin.zip && \
    unzip -q gradle.zip && \
    rm -f gradle.zip && \
    chown -R root. /opt


# Setup environment
ENV ANDROID_HOME "${ANDROID_DIR}/sdk"
ENV ANDROID_SDK_ROOT "${ANDROID_DIR}/sdk"
ENV PATH ${PATH}:${ANDROID_HOME}:${ANDROID_HOME}/cmdline-tools:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/build-tools/${ANDROID_BUILD_TOOLS}:/opt/gradle/gradle-${GRADLE_VERSION}/bin

# Install Android SDK
RUN yes Y | sdkmanager "build-tools;$ANDROID_BUILD_TOOLS" "platforms;android-$ANDROID_COMPILE_SDK" "platform-tools"

WORKDIR Sources
