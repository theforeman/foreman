class FixIntegerSettings < ActiveRecord::Migration
  def up
    Setting.where(:settings_type => 'integer').each do |s|
      if !s.value.is_a? Integer
        # make sure all integer settings are not stored as string
        s.value = s.value.to_i
        s.save!
      end
    end
  end

  def down
  end
end
