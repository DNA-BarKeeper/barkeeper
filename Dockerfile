FROM ruby:2.6.7

LABEL maintainer="BarKeeper (Kai Müller, Sarah Wiechers)"

ARG PUMA_PORT

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs cmake

ENV RAILS_ROOT /var/www/barkeeper
RUN mkdir -p $RAILS_ROOT
WORKDIR $RAILS_ROOT

RUN gem install rails bundler
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle install

RUN bundle exec rails assets:precompile
EXPOSE $PUMA_PORT

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
