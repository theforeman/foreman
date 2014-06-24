class ExternalUsergroup < ActiveRecord::Base
  belongs_to :usergroup, :inverse_of => :external_usergroups
  belongs_to :auth_source

  validates_uniqueness_of :name, :scope => :auth_source_id
  validates_presence_of   :name, :auth_source, :usergroup
end
