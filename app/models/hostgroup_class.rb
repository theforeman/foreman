class HostgroupClass < ActiveRecord::Base
  include Authorization
  include Authorizable
  audited :associated_with => :hostgroup, :allow_mass_assignment => true
  belongs_to :hostgroup
  belongs_to :puppetclass

  attr_accessible :hostgroup_id, :hostgroup, :puppetclass_id, :puppetclass

  validates :hostgroup_id, :presence => true
  validates :puppetclass_id, :presence => true, :uniqueness => {:scope => :hostgroup_id}

  def name
    "#{hostgroup} - #{puppetclass}"
  end

  private

  def enforce_permissions operation
    if operation == "edit" and new_record?
      return true # We get called again with the operation being set to create
    end
    if User.current.allowed_to?(:edit_classes) && Hostgroup.my_groups.pluck(:id).include?(self.hostgroup_id)
      return true
    else
      errors.add(:base, _("You do not have permission to edit Puppet classes on this host group"))
      return false
    end
  end

end
