FROM quay.io/foreman/foreman:builder-base as builder

ARG HOME=/home/foreman
ARG RAILS_ENV=production
ENV RAILS_SERVE_STATIC_FILES=true
ENV RAILS_LOG_TO_STDOUT=true

USER 1001
WORKDIR $HOME

# Add the sources again and reinstall the the build dependencies in case of caching the builder-base image
COPY --chown=1001:1001 . ${HOME}/
RUN \
  bundle install && \
  npm install --no-optional

RUN \
  make -C locale all-mo && \
  bundle exec rake assets:clean assets:precompile db:migrate &&  \
  bundle exec rake db:seed apipie:cache:index && rm tmp/bootstrap-db.sqlite3
RUN ./node_modules/webpack/bin/webpack.js --config config/webpack.config.js && npm run analyze && rm -rf public/webpack/stats.json
RUN rm -rf vendor/ruby/*/cache vendor/ruby/*/gems/*/node_modules

FROM quay.io/foreman/foreman:base

ARG HOME=/home/foreman
ARG RAILS_ENV=production
ENV RAILS_SERVE_STATIC_FILES=true
ENV RAILS_LOG_TO_STDOUT=true

USER 1001
WORKDIR $HOME
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
