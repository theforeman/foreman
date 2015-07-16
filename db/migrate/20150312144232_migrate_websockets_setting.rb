class FakeSetting < ActiveRecord::Base
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

class MigrateWebsocketsSetting < ActiveRecord::Migration
  def up
    return unless encrypt = FakeSetting.find_by_name("websockets_encrypt")
    encrypt.settings_type = "boolean"
    if encrypt.value == "auto"
      encrypt.value = (Setting[:websockets_ssl_key].nil? ||
                       Setting[:websockets_ssl_cert].nil?) ? false : true
    elsif !encrypt.value.nil?
      encrypt.value = Foreman::Cast.to_bool(encrypt.value)
    end
    encrypt.default = !!SETTINGS[:require_ssl]
    encrypt.save!
  end

  def down
    # delete and reset on next app server start
    FakeSetting.find_by_name("websockets_encrypt").delete
  end
end
