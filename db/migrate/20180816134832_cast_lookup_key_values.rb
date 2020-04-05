class CastLookupKeyValues < ActiveRecord::Migration[5.1]
  def up
    # Different LookupKey types handle casting a bit differently
    PuppetclassLookupKey.unscoped.preload(:lookup_values).where(override: true).where.not(key_type: 'string').find_each do |key|
      cast_key_and_values(key)
    end
  end

  private

  def cast_key_and_values(key)
    fix_value(key, :default_value)
    key.lookup_values.each do |lv|
      fix_value(lv, :value)
    end
  end

  def safemode
    @box ||= Safemode::Box.new
  end

  def fix_value(obj, attribute)
    return if obj.omit && !obj.try(:merge_default)
    value = obj.send(attribute)
    return unless value.is_a? String
    return if value.contains_erb?
    fixed = safemode.eval(value)
    obj.update_column(attribute, fixed)
  rescue StandardError => e
    say "Failed to cast #{attribute} for #{obj.inspect}:"
    say "Value: #{value}", subitem: true
    say "Error: #{e.message}", subitem: true
    say "Perhaps it is invalid? Casting skipped, manual action may be needed.", subitem: true
  end
end
