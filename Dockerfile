FROM ruby:2.3.3

RUN printf "deb http://archive.debian.org/debian/ jessie main\ndeb-src http://archive.debian.org/debian/ jessie main\ndeb http://security.debian.org jessie/updates main\ndeb-src http://security.debian.org jessie/updates main" > /etc/apt/sources.list
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

RUN mkdir /bartender
WORKDIR /bartender

COPY Gemfile /bartender/Gemfile
COPY Gemfile.lock /bartender/Gemfile.lock

RUN bundle install

COPY . /bartender

LABEL maintainer="BarTender (Kai Müller, Sarah Wiechers)"