class HostgroupClass < ActiveRecord::Base
  include Authorization
  audited :associated_with => :hostgroup, :allow_mass_assignment => true
  belongs_to :hostgroup
  belongs_to :puppetclass

  attr_accessible :hostgroup_id, :hostgroup, :puppetclass_id, :puppetclass
  validates_presence_of :hostgroup_id, :puppetclass_id
  validates :puppetclass_id, :uniqueness => {:scope => :hostgroup_id}

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
      errors.add(:base, _("You do not have permission to edit puppetclasses on this hostgroup"))
      return false
    end
  end

end
