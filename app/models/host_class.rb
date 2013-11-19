class SystemClass < ActiveRecord::Base
  include Authorization
  audited :associated_with => :system, :allow_mass_assignment => true
  belongs_to_system :foreign_key => :system_id
  belongs_to :puppetclass

  validates :system_id, :presence => true
  validates :puppetclass_id, :presence => true, :uniqueness => {:scope => :system_id}

  def name
    "#{system} - #{puppetclass}"
  end

  private

  def enforce_permissions operation
    if operation == "edit" and new_record?
      return true # We get called again with the operation being set to create
    end
    if User.current.allowed_to?(:edit_classes) && System.my_systems.pluck(:id).include?(self.system_id)
      return true
    else
      errors.add(:base, _("You do not have permission to edit Puppet classes on this system"))
      return false
    end
  end

end
