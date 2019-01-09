Keycloak.configure do |config|
  config.server_url = "localhost"
  config.realm_id   = "hammer-cli"
  config.logger     = Rails.logger
  config.skip_paths = {
    post:   [/^\/message/],
    get:    [/^\/locales/, /^\/health\/.+/]
  }
end
