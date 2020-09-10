class DeleteBootableInterface < ActiveRecord::Migration[4.2]
  def up
    Nic::Base.where(:type => 'Nic::Bootable').update_all(:type => 'Nic::Managed',
                                                         :provision => true)
  end

  # This migration cannot be reverted as once Bootable nics have been migrated
  # to Managed interfaces, there is no way to know which managed interfaces
  # were Bootable interfaces in the past.
end
