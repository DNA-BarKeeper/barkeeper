FROM ruby:2.3.3

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

RUN mkdir /gbol5
WORKDIR /gbol5

COPY Gemfile /gbol5/Gemfile
COPY Gemfile.lock /gbol5/Gemfile.lock

RUN bundle install

COPY . /gbol5

LABEL maintainer="GBOL5 (Kai Müller, Sarah Wiechers)"