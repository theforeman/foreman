# Container that provides the build dependencies
FROM quay.io/foreman/foreman-base
ENV RAILS_ENV=production
ENV FOREMAN_APIPIE_LANGS=en
ENV BUNDLER_SKIPPED_GROUPS="test development openid libvirt journald facter"

RUN \
  microdnf install redhat-rpm-config git \
    gcc-c++ make bzip2 gettext tar \
    libxml2-devel libcurl-devel ruby-devel \
    mysql-devel postgresql-devel libsq3-devel && \
  microdnf clean all

ENV DATABASE_URL=sqlite3:tmp/bootstrap-db.sqlite3

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
