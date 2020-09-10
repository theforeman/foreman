class CorrectDnsTimeoutSetting < ActiveRecord::Migration[5.2]
  def up
    unless Setting[:dns_timeout].is_a?(Integer) || Setting[:dns_timeout].is_a?(Array)
      Setting.find_by_name('dns_timeout')&.update_column(:value, nil)
    end
  end
end
