FROM ruby:2.1-slim

ENV BUILD_PACKAGES git-all make gcc g++
ENV RUN_PACKAGES curl \
  libcurl3 \
  libcurl3-gnutls \
  libcurl4-openssl-dev \
  nodejs \
  npm \
  nodejs-legacy

RUN apt-get update && \
  apt-get install -y --no-install-recommends --auto-remove $BUILD_PACKAGES

RUN apt-get update && \
  apt-get install -y --no-install-recommends --auto-remove $RUN_PACKAGES && \
  apt-get clean


RUN mkdir /app
WORKDIR /app

COPY Gemfile /app/
COPY Gemfile.lock /app/
RUN bundle install --jobs 4 --without development test

ADD . /app
WORKDIR /app

ENV RAILS_ENV production
RUN bundle exec rake tmp:cache:clear

CMD bundle exec unicorn -o 0.0.0.0 -p $PORT -c config/unicorn.rb
