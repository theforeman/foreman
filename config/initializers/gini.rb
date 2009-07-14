require 'puppet'
require "#{RAILS_ROOT}/vendor/gateway/gateway.rb"

# import settings file
$settings = YAML.load_file("#{RAILS_ROOT}/config/settings.yaml")
# Add an empty method to nil. Now no need for if x and x.empty?. Just x.empty?
class NilClass
  def empty?
    true
  end
end

