FROM nginx:latest

RUN apt-get update -qq && apt-get -y install apache2-utils

ENV RAILS_ROOT /var/www/barkeeper
ARG PROJECT_DOMAIN
ARG PUMA_PORT

WORKDIR $RAILS_ROOT

RUN mkdir log

COPY public public/
COPY nginx.conf /tmp/docker.nginx
RUN envsubst '${RAILS_ROOT} ${PROJECT_DOMAIN} ${PUMA_PORT}' < /tmp/docker.nginx > /etc/nginx/conf.d/default.conf

EXPOSE ${PORT}

CMD [ "nginx", "-g", "daemon off;" ]
