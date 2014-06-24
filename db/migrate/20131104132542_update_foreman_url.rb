require 'uri'

class UpdateForemanUrl < ActiveRecord::Migration
  def up
    return unless (val = Setting.find_by_name('foreman_url').try(:value))
    if URI.parse(val).host.nil?
      protocol=SETTINGS[:require_ssl] ? 'https' : 'http'
      Setting[:foreman_url]="#{protocol}://#{val}"
    end
  end

  def down
    return unless (val = Setting.find_by_name('foreman_url').try(:value))
    if URI.parse(val).host.present?
      Setting[:foreman_url]=URI.parse(val).host
    end
  end
end
