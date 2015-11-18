class OsDefaultTemplate < ActiveRecord::Base
  attr_accessible :provisioning_template_id, :provisioning_template_name, :template_kind_id,
    :template_kind_name, :operatingsystem, :operatingsystem_id, :operatingsystem_name

  belongs_to :provisioning_template
  belongs_to :template_kind
  belongs_to :operatingsystem

  validates :provisioning_template_id, :presence => true
  validates :template_kind_id, :presence => true, :uniqueness => {:scope => :operatingsystem_id}

  def name
    "#{operatingsystem} - #{template_kind}"
  end

  def to_label
    name
  end
end
