FROM ruby:2.4.3-alpine3.7
RUN apk update && \
    apk add --virtual build_deps \
    build-base ruby-dev libc-dev linux-headers \
    postgresql-dev libxml2-dev \
    libvirt-dev mariadb-dev sqlite-dev && \
    apk add nodejs yarn libxslt-dev python tzdata && \
    gem install nokogiri -- --use-system-libraries

# foreman minimum config for gems and node modules
RUN mkdir -p /app/config/
RUN mkdir -p /app/script/
RUN mkdir -p /app/app/registries/foreman/
RUN mkdir -p /app/bundler.d/
COPY Gemfile package.json /app/
COPY config/boot_settings.rb config/settings.yaml config/settings.yaml.dist /app/config/
COPY script/npm_install_plugins.js script/plugin_webpack_directories.js script/plugin_webpack_directories.rb /app/script/
COPY app/registries/foreman/webpack_assets.rb /app/app/registries/foreman/
COPY bundler.d/* /app/bundler.d/

# set home dir
ENV APP_HOME /app
ENV BUNDLE_PATH /bundle
WORKDIR $APP_HOME

# install all gems and node modules
RUN bundle install && yarn install && npm rebuild node-sass
