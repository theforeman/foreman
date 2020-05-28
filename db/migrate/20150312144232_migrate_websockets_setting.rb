class FakeSetting < ApplicationRecord
  self.table_name = 'settings'

  def default=(v)
    write_attribute :default, v.to_yaml
  end

  def value=(v)
    v = v.to_yaml unless v.nil?
    write_attribute :value, v
  end

  def value
    v = read_attribute(:value)
    YAML.load(v) unless v.nil?
  end
end

class MigrateWebsocketsSetting < ActiveRecord::Migration[4.2]
  def up
    return unless (encrypt = FakeSetting.find_by_name("websockets_encrypt"))
    encrypt.settings_type = "boolean"
    if encrypt.value == "auto"
      encrypt.value = if Setting[:websockets_ssl_key].present? && Setting[:websockets_ssl_cert].present?
                        true
                      else
                        false
                      end
    elsif encrypt.value.present?
      encrypt.value = Foreman::Cast.to_bool(encrypt.value)
    end
    encrypt.default = !!SETTINGS[:require_ssl]
    encrypt.save!
  end

  def down
    # delete and reset on next app server start
    encrypt = FakeSetting.find_by_name("websockets_encrypt")
    Rails.cache.delete(Foreman::SettingManager.new.cache_key(encrypt.name))
    encrypt.delete
  end
end
