class ChangeBaseInterfaceType < ActiveRecord::Migration[7.0]
  def up
    allowed_types = Nic::Base.allowed_types.map(&:name)
    Nic::Base.where.not(type: allowed_types)
                   .or(Nic::Base.where(type: nil))
                   .update_all(type: 'Nic::Managed')
  end

  def down
  end
end
