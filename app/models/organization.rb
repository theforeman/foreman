class Organization < ActiveRecord::Base
  include Foreman::ThreadSession::OrganizationModel
  audited
  has_associated_audits

  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :organization_users, :dependent => :destroy
  has_many :users, :through => :organization_users
  has_many :organization_smart_proxies, :dependent => :destroy
  has_many :smart_proxies, :through => :organization_smart_proxies
  has_many :organization_compute_resources, :dependent => :destroy
  has_many :compute_resources, :through => :organization_compute_resources
  has_many :organization_media, :dependent => :destroy
  has_many :media, :through => :organization_media
  has_many :organization_domains, :dependent => :destroy
  has_many :domains, :through => :organization_domains
  has_many :organization_hostgroups, :dependent => :destroy
  has_many :hostgroups, :through => :organization_hostgroups
  has_many :organization_environments, :dependent => :destroy
  has_many :environments, :through => :organization_environments

  scoped_search :on => :name, :complete_value => true

  def to_param
    name
  end

  def self.apply_org_scope scope
    if SETTINGS[:orgs_enabled] and not User.current.admin?
      org_ids = [Organization.current].flatten
      # the join with organizations should exclude all objects not in the user's
      # current org(s) ... if the user has no current org, then the user will
      # see no objects as a result of this join
      org_ids = org_ids.any? ? org_ids.map(&:id) : nil
      scope = scope.joins(:organizations).where("organizations.id in (?)", org_ids)
    end
    scope
  end
end
