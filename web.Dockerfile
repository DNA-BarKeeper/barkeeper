FROM nginx:latest

RUN apt-get update -qq && apt-get -y install apache2-utils

ENV RAILS_ROOT /var/www/barkeeper
ARG PROJECT_DOMAIN
ARG PORT
ARG SSL_PORT
ARG PUMA_PORT
ARG RAILS_ENV

WORKDIR $RAILS_ROOT

RUN mkdir log

COPY public public/
COPY nginx.conf /tmp/docker.nginx

COPY ssl /tmp/docker.ssl
RUN envsubst '${RAILS_ROOT} ${PROJECT_DOMAIN} ${PUMA_PORT} ${PORT}' < /tmp/docker.nginx > /etc/nginx/conf.d/default.conf
RUN if [ "$RAILS_ENV" = "production" ]; then envsubst '${PROJECT_DOMAIN} ${SSL_PORT}' < /tmp/docker.ssl > /etc/nginx/conf.d/ssl; fi

EXPOSE ${PORT}
EXPOSE ${SSL_PORT}

CMD [ "nginx", "-g", "daemon off;" ]
