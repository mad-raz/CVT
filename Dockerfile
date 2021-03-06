FROM ruby:2.3.1-alpine

MAINTAINER mad-raz <abdelrazzak.ahmed@gmail.com>

# Install Dependencies
RUN apk add --no-cache \
  build-base \
  file \
  git \
  libxml2-dev \
  libxslt-dev \
  nodejs \
  postgresql-dev

# Prepare project
EXPOSE 3000
RUN mkdir /app
WORKDIR /app
COPY Gemfile Gemfile.lock /app/

RUN gem install bundler
RUN bundle config github.https true
RUN bundle install --clean --binstubs="$BUNDLE_BIN"

# Clean up
RUN apk del build-base git

# Copy Project files
COPY . /app/
CMD bundle exec puma -C config/puma.rb
