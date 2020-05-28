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

class ConvertDnsConflictTimeoutSetting < ActiveRecord::Migration[5.2]
  def clean_cache
    Rails.cache.delete(Foreman::SettingManager.new.cache_key("dns_conflict_timeout"))
    Rails.cache.delete(Foreman::SettingManager.new.cache_key("dns_timeout"))
  end

  def up
    Setting.without_auditing do
      old_setting = FakeSetting.find_by_name("dns_conflict_timeout")
      new_setting = FakeSetting.find_by_name("dns_timeout")
      return if old_setting.nil? || new_setting.nil?
      # only migrate the value if it was redefined (default was 3)
      if old_setting.value != 3
        new_setting.value = [old_setting.value]
        new_setting.save!
      end
      old_setting.destroy!
      clean_cache
    end
  end

  def down
    Setting.without_auditing do
      FakeSetting.where("name = 'dns_timeout' or name = 'dns_conflict_timeout'").destroy_all
      clean_cache
    end
  end
end
