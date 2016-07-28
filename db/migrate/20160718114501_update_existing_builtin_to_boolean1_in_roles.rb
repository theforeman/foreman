class UpdateExistingBuiltinToBoolean1InRoles < ActiveRecord::Migration
  def up
    roles = Role.where(:builtin => 2)
    roles.each do |role|
      role.builtin = 1
      role.save!
    end
  end
end
