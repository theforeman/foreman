class OidcIdentity < ApplicationRecord
  SUBJECT_MAX_LENGTH = 255

  audited

  belongs_to :user, :inverse_of => :oidc_identities
  belongs_to :auth_source, :class_name => 'AuthSourceOidc', :inverse_of => :oidc_identities

  validates_lengths_from_database
  validates :subject, :presence => true, :length => { :maximum => SUBJECT_MAX_LENGTH },
    :uniqueness => { :scope => :auth_source_id }
  validates :auth_source_id, :uniqueness => { :scope => :user_id }
  validates :email, :email => true, :allow_blank => true
end
