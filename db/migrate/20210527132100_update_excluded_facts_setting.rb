class UpdateExcludedFactsSetting < ActiveRecord::Migration[6.0]
  def up
    replace_values = { 'vnet*' => '*vnet*', 'veth*' => '*vnet*'}

    Setting.without_auditing do
      setting = Setting.where(:name => 'excluded_facts').first
      return unless setting
      default_facts = setting.default

      replace_values.each do |original, new|
        index = default_facts.index(original)
        next unless index
        default_facts[index] = new
      end

      setting.update_attribute(:default, default_facts)
    end
  end

  def down
    replace_values = { '*vnet*' => 'vnet*', '*veth*' => 'vnet*'}

    Setting.without_auditing do
      setting = Setting.where(:name => 'excluded_facts').first
      return unless setting
      default_facts = setting.default

      replace_values.each do |original, new|
        index = default_facts.index(original)
        default_facts[index] = new
      end

      setting.update_attribute(:default, default_facts)
    end
  end
end
