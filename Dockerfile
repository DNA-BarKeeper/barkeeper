FROM ruby:2.7.0

LABEL maintainer="BarKeeper (Kai Müller, Sarah Wiechers)"

RUN addgroup --gid 1000 barkeeper
RUN adduser --disabled-password --gecos '' --uid 1000 --gid 1000 barkeeper

ARG PUMA_PORT

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs cmake

ENV RAILS_ROOT /var/www/barkeeper
RUN mkdir -p $RAILS_ROOT
WORKDIR $RAILS_ROOT

COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock

ENV BUNDLER_VERSION=2.3.5
RUN gem install rails bundler:2.3.5

RUN bundle config set --local without [:test]
RUN bundle install
RUN chown -R barkeeper:barkeeper $RAILS_ROOT

RUN bundle exec rails assets:precompile
EXPOSE $PUMA_PORT

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
