FROM ruby:2.6.6

LABEL maintainer="Barcode Workflow Manager (Kai Müller, Sarah Wiechers)"

ARG USER_ID
ARG GROUP_ID

RUN addgroup --gid $GROUP_ID user
RUN adduser --disabled-password --gecos '' --uid $USER_ID --gid $GROUP_ID user

ENV INSTALL_PATH /opt/app
RUN mkdir -p $INSTALL_PATH

# nodejs & yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg -o /root/yarn-pubkey.gpg && apt-key add /root/yarn-pubkey.gpg
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install -y --no-install-recommends nodejs yarn

# rails
RUN gem install rails bundler
COPY barcode_workflow_manager/Gemfile Gemfile
WORKDIR /opt/app/barcode_workflow_manager
RUN bundle install

RUN chown -R user:user /opt/app
USER $USER_ID
VOLUME ["$INSTALL_PATH/public"]

CMD bundle exec puma -C config/puma.rb
