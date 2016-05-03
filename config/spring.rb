%w(
  .ruby-version
  .rbenv-vars
  config/email.yaml
  config/ignored_environments.yml
  config/logging.yaml
  config/settings.yaml
  tmp/restart.txt
  tmp/caching-dev.txt
) + Dir["config/settings.plugins.d/*.yaml"].each { |path| Spring.watch(path) }
