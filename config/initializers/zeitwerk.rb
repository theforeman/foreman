Rails.autoloaders.main.ignore(
  Rails.root.join('lib/generators')
)
Rails.autoloaders.once.ignore(
  Rails.root.join('app/registries/foreman/access_permissions.rb'),
  Rails.root.join('app/registries/foreman/settings.rb'),
  Rails.root.join('app/registries/foreman/settings')
)
