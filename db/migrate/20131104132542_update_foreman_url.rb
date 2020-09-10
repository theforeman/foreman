require 'uri'

class UpdateForemanUrl < ActiveRecord::Migration[4.2]
  def up
    return unless (val = Setting.find_by_name('foreman_url').try(:value))
    if URI.parse(val).host.nil?
      protocol = SETTINGS[:require_ssl] ? 'https' : 'http'
      Setting[:foreman_url] = "#{protocol}://#{val}"
    end
  end

  def down
    return unless (val = Setting.find_by_name('foreman_url').try(:value))
    Setting[:foreman_url] = URI.parse(val).host if URI.parse(val).host.present?
  end
end
