class MigrateWebsocketsSetting < ActiveRecord::Migration
  def up
    return unless encrypt = Setting.find_by_name("websockets_encrypt")
    encrypt.settings_type = "boolean"
    if encrypt.value == "auto"
      encrypt.value = (Setting[:websockets_ssl_key].nil? ||
                       Setting[:websockets_ssl_cert].nil?) ? false : true
    else
      encrypt.value = Foreman::Cast.to_bool(encrypt.value)
    end
    encrypt.default = false
    encrypt.save(:validate => false)
  end

  def down
    # delete and reset on next app server start
    Setting.delete_by_name("websockets_encrypt")
  end
end
