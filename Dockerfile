FROM ruby:3-alpine
# renovate: datasource=rubygems depName=modulesync
ENV MODULESYNC_VERSION=4.2.0

RUN apk update \
    && apk add curl git openssh-client-default build-base jq \
    && apk upgrade

RUN gem install modulesync -v $MODULESYNC_VERSION

RUN adduser --disabled-password --gecos '' msync

USER msync

WORKDIR /app
