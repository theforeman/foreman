(%w(
  .ruby-version
  .rbenv-vars
  config/ignored_environments.yml
  config/logging.yaml
  config/settings.yaml
  tmp/restart.txt
  tmp/caching-dev.txt
) +
  Dir["config/settings.plugins.d/*.yaml"] +
  Dir["config/settings.d/*.yaml"]).each { |path| Spring.watch(path) }
