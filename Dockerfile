FROM registry.dblayer.com/rails:latest

RUN apt-get update \
  && apt-get install -y --no-install-recommends --auto-remove \
    libcurl3 \
    libcurl3-gnutls \
    libcurl4-openssl-dev \
  && rm -rf /var/lib/apt/lists/*

COPY Gemfile /app/
COPY Gemfile.lock /app/
RUN bundle install --jobs 4 --without development test

ADD . /app
WORKDIR /app

RUN bundle exec rake tmp:cache:clear
RUN bundle exec rake assets:precompile

CMD bundle exec unicorn -o 0.0.0.0 -p $PORT -c config/unicorn.rb
