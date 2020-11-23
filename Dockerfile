FROM ruby:2.6.6

LABEL maintainer="Barcode Workflow Manager (Kai Müller, Sarah Wiechers)"

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs cmake

ENV RAILS_ROOT /var/www/barcode_workflow_manager
RUN mkdir -p $RAILS_ROOT
WORKDIR $RAILS_ROOT

RUN gem install rails bundler
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle install

RUN bundle exec rails assets:precompile
EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
