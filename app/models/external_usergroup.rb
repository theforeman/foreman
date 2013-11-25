class ExternalUsergroup < ActiveRecord::Base
  belongs_to :usergroup, :inverse_of => :external_usergroups
  belongs_to :auth_source

  validates_uniqueness_of :name, :scope => :auth_source_id
  validates_presence_of   :name, :auth_source, :usergroup
  validate :hidden_authsource_restricted

  def hidden_authsource_restricted
    if auth_source_id_changed? && auth_source.kind_of?(AuthSourceHidden)
      errors.add :auth_source, _("is not permitted")
    end
  end
end
