# Base container that is used for both building and running the app
FROM registry.fedoraproject.org/fedora-minimal:30 as base
ARG RUBY_VERSION="2.6"
ARG NODEJS_VERSION="11"
ENV FOREMAN_FQDN=foreman.example.com
ENV FOREMAN_DOMAIN=example.com

RUN \
  echo -e "[nodejs]\nname=nodejs\nstream=${NODEJS_VERSION}\nprofiles=\nstate=enabled\n" > /etc/dnf/modules.d/nodejs.module && \
  echo -e "[ruby]\nname=ruby\nstream=${RUBY_VERSION}\nprofiles=\nstate=enabled\n" > /etc/dnf/modules.d/ruby.module && \
  microdnf install mysql-libs mariadb-connector-c postgresql-libs ruby{,gems} rubygem-{rake,bundler} npm nc hostname \
  # needed for VNC/SPICE websockets
  python2-numpy && \
  microdnf clean all

ARG HOME=/home/foreman
WORKDIR $HOME
RUN groupadd -r foreman -f -g 1001 && \
    useradd -u 1001 -r -g foreman -d $HOME -s /sbin/nologin \
    -c "Foreman Application User" foreman && \
    chown -R 1001:1001 $HOME

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

# Temp container that download gems/npms and compile assets etc
FROM base as builder
ENV RAILS_ENV=production
ENV FOREMAN_APIPIE_LANGS=en
ENV BUNDLER_SKIPPED_GROUPS="test development openid libvirt journald facter"

RUN \
  microdnf install redhat-rpm-config git \
    gcc-c++ make bzip2 gettext tar \
    libxml2-devel libcurl-devel ruby-devel \
    mysql-devel postgresql-devel libsq3-devel && \
  microdnf clean all

ENV DATABASE_URL=sqlite3:tmp/bootstrap-db.sql

ARG HOME=/home/foreman
USER 1001
WORKDIR $HOME
COPY --chown=1001:1001 . ${HOME}/
# Adding missing gems, for tzdata see https://bugzilla.redhat.com/show_bug.cgi?id=1611117
RUN echo gem '"rdoc"' > bundler.d/container.rb && echo gem '"tzinfo-data"' >> bundler.d/container.rb
RUN bundle install --without "${BUNDLER_SKIPPED_GROUPS}" \
    --binstubs --clean --path vendor --jobs=5 --retry=3 && \
  rm -rf vendor/ruby/*/cache/*.gem && \
  find vendor/ruby/*/gems -name "*.c" -delete && \
  find vendor/ruby/*/gems -name "*.o" -delete
RUN npm install --no-optional
RUN \
  make -C locale all-mo && \
  bundle exec rake assets:clean assets:precompile db:migrate &&  \
  bundle exec rake db:seed apipie:cache:index && rm tmp/bootstrap-db.sql
RUN ./node_modules/webpack/bin/webpack.js --config config/webpack.config.js && npm run analyze && rm -rf public/webpack/stats.json
RUN rm -rf vendor/ruby/*/cache vendor/ruby/*/gems/*/node_modules

FROM base

ARG HOME=/home/foreman
ARG RAILS_ENV=production
ENV RAILS_SERVE_STATIC_FILES=true
ENV RAILS_LOG_TO_STDOUT=true

USER 1001
WORKDIR ${HOME}
COPY --chown=1001:1001 . ${HOME}/
COPY --from=builder /usr/bin/entrypoint.sh /usr/bin/entrypoint.sh
COPY --from=builder --chown=1001:1001 ${HOME}/.bundle/config ${HOME}/.bundle/config
COPY --from=builder --chown=1001:1001 ${HOME}/Gemfile.lock ${HOME}/Gemfile.lock
COPY --from=builder --chown=1001:1001 ${HOME}/vendor/ruby ${HOME}/vendor/ruby
COPY --from=builder --chown=1001:1001 ${HOME}/public ${HOME}/public
RUN echo gem '"rdoc"' > bundler.d/container.rb && echo gem '"tzinfo-data"' >> bundler.d/container.rb

RUN date -u > BUILD_TIME

# Start the main process.
CMD "bundle exec bin/rails server"

EXPOSE 3000/tcp
EXPOSE 5910-5930/tcp
