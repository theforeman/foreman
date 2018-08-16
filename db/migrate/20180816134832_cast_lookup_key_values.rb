class CastLookupKeyValues < ActiveRecord::Migration[5.1]
  def up
    # Different LookupKey types handle casting a bit differently
    PuppetclassLookupKey.unscoped.preload(:lookup_values).where(override: true).where.not(key_type: 'string').find_each do |key|
      cast_key_and_values(key)
    end

    VariableLookupKey.unscoped.preload(:lookup_values).where.not(key_type: 'string').find_each do |key|
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
    @box ||= Safemode::Box.new()
  end

  def fix_value(obj, attribute)
    return if obj.omit
    value = obj.send(attribute)
    return unless value.is_a? String
    return if value.contains_erb?
    fixed = safemode.eval(value)
    obj.update_column(attribute, fixed)
  rescue StandardError => e
    puts "Error casting #{attribute} #{value} for #{obj.inspect} with error #{e.message}. Perhaps it is invalid?"
    puts e.backtrace
  end
end
