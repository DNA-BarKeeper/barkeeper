#FROM ruby:2.3.3
#
##RUN apk update && apk add build-base nodejs postgresql-dev
#RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
#
#RUN mkdir /app
#WORKDIR /app
#
#COPY Gemfile Gemfile.lock ./
#RUN bundle install --binstubs
#
#COPY . .
#
#LABEL maintainer="GBOL5 (Kai Müller, Sarah Wiechers)"
#
#CMD puma -C config/puma.rb

FROM ruby:2.3.3

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

RUN mkdir /gbol5
WORKDIR /gbol5

COPY Gemfile /gbol5/Gemfile
COPY Gemfile.lock /gbol5/Gemfile.lock

RUN bundle install

COPY . /gbol5

LABEL maintainer="GBOL5 (Kai Müller, Sarah Wiechers)"