class EncryptHttpProxySetting < ActiveRecord::Migration[7.0]
  def up
    setting = Setting.find_by(name: 'http_proxy')
    return unless setting

    setting.value = setting[:value]
    setting.save!(validate: false)
  end

  def down
    # no-op (we can’t safely decrypt once it’s encrypted)
  end
end
