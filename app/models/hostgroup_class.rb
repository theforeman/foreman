class SystemGroupClass < ActiveRecord::Base
  include Authorization
  audited :associated_with => :system_group, :allow_mass_assignment => true
  belongs_to :system_group
  belongs_to :puppetclass

  attr_accessible :system_group_id, :system_group, :puppetclass_id, :puppetclass

  validates :system_group_id, :presence => true
  validates :puppetclass_id, :presence => true, :uniqueness => {:scope => :system_group_id}

  def name
    "#{system_group} - #{puppetclass}"
  end

  private

  def enforce_permissions operation
    if operation == "edit" and new_record?
      return true # We get called again with the operation being set to create
    end
    if User.current.allowed_to?(:edit_classes) && SystemGroup.my_groups.pluck(:id).include?(self.system_group_id)
      return true
    else
      errors.add(:base, _("You do not have permission to edit Puppet classes on this system group"))
      return false
    end
  end

end
