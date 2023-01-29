# Base container that is used for both building and running the app
FROM quay.io/centos/centos:stream8 as base
ARG RUBY_VERSION="2.7"
ARG NODEJS_VERSION="12"
ENV FOREMAN_FQDN=foreman.example.com
ENV FOREMAN_DOMAIN=example.com

RUN \
  dnf upgrade -y && \
  dnf module enable ruby:${RUBY_VERSION} nodejs:${NODEJS_VERSION} -y && \
  dnf install -y postgresql-libs ruby{,gems} rubygem-{rake,bundler} npm nc hostname && \
  dnf clean all

ARG HOME=/home/foreman
WORKDIR $HOME
RUN groupadd -r foreman -f -g 0 && \
    useradd -u 1001 -r -g foreman -d $HOME -s /sbin/nologin \
    -c "Foreman Application User" foreman && \
    chown -R 1001:0 $HOME && \
    chmod -R g=u ${HOME}

# Add a script to be executed every time the container starts.
COPY extras/containers/entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

# Temp container that download gems/npms and compile assets etc
FROM base as builder
ENV RAILS_ENV=production
ENV FOREMAN_APIPIE_LANGS=en
ENV BUNDLER_SKIPPED_GROUPS="test development openid libvirt journald facter console"

RUN \
  dnf install -y redhat-rpm-config git-core \
    gcc-c++ make bzip2 gettext tar \
    libxml2-devel libcurl-devel ruby-devel \
    postgresql-devel && \
  dnf clean all

ENV DATABASE_URL=nulldb://nohost

ARG HOME=/home/foreman
USER 1001
WORKDIR $HOME
COPY --chown=1001:0 . ${HOME}/
RUN bundle config set --local without "${BUNDLER_SKIPPED_GROUPS}" && \
  bundle config set --local clean true && \
  bundle config set --local path vendor && \
  bundle config set --local jobs 5 && \
  bundle config set --local retry 3
RUN bundle install && \
  bundle binstubs --all && \
  rm -rf vendor/ruby/*/cache/*.gem && \
  find vendor/ruby/*/gems -name "*.c" -delete && \
  find vendor/ruby/*/gems -name "*.o" -delete
RUN \
  make -C locale all-mo && \
  mv -v db/schema.rb.nulldb db/schema.rb && \
  bundle exec rake assets:clean assets:precompile apipie:cache:index

RUN npm install --no-optional && \
  ./node_modules/webpack/bin/webpack.js --config config/webpack.config.js && npm run analyze && \
# cleanups
  rm -rf public/webpack/stats.json ./node_modules vendor/ruby/*/cache vendor/ruby/*/gems/*/node_modules bundler.d/nulldb.rb db/schema.rb && \
  bundle config without "${BUNDLER_SKIPPED_GROUPS} assets" && \
  bundle install

USER 0
RUN chgrp -R 0 ${HOME} && \
    chmod -R g=u ${HOME}

USER 1001

FROM base

ARG HOME=/home/foreman
ENV RAILS_ENV=production
ENV RAILS_SERVE_STATIC_FILES=true
ENV RAILS_LOG_TO_STDOUT=true

USER 1001
WORKDIR ${HOME}
COPY --chown=1001:0 . ${HOME}/
COPY --from=builder /usr/bin/entrypoint.sh /usr/bin/entrypoint.sh
COPY --from=builder --chown=1001:0 ${HOME}/.bundle/config ${HOME}/.bundle/config
COPY --from=builder --chown=1001:0 ${HOME}/Gemfile.lock ${HOME}/Gemfile.lock
COPY --from=builder --chown=1001:0 ${HOME}/vendor/ruby ${HOME}/vendor/ruby
COPY --from=builder --chown=1001:0 ${HOME}/public ${HOME}/public
RUN rm -rf bundler.d/nulldb.rb bin/spring

RUN date -u > BUILD_TIME

# Start the main process.
CMD bundle exec bin/rails server

EXPOSE 3000/tcp
EXPOSE 5910-5930/tcp
