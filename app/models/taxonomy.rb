class Taxonomy < ActiveRecord::Base
  audited
  has_associated_audits

  validates_presence_of :name
  validates_uniqueness_of :name

  belongs_to :user

  has_many :taxonomy_users, :dependent => :destroy
  has_many :users, :through => :taxonomy_users
  has_many :taxonomy_smart_proxies, :dependent => :destroy
  has_many :smart_proxies, :through => :taxonomy_smart_proxies
  has_many :taxonomy_compute_resources, :dependent => :destroy
  has_many :compute_resources, :through => :taxonomy_compute_resources
  has_many :taxonomy_media, :dependent => :destroy
  has_many :media, :through => :taxonomy_media
  has_many :taxonomy_domains, :dependent => :destroy
  has_many :domains, :through => :taxonomy_domains
  has_many :taxonomy_hostgroups, :dependent => :destroy
  has_many :hostgroups, :through => :taxonomy_hostgroups
  has_many :taxonomy_environments, :dependent => :destroy
  has_many :environments, :through => :taxonomy_environments
  has_many :taxonomy_puppetclasses, :dependent => :destroy
  has_many :puppetclasses, :through => :taxonomy_puppetclasses
  has_many :taxonomy_subnets, :dependent => :destroy
  has_many :subnets, :through => :taxonomy_subnets

  scoped_search :on => :name, :complete_value => true

  def to_param
    name
  end

  # There is an issue in _edit_habtm.erb where the taxonomies method gets
  # called on each subclass of taxonomies in order to map associations. This
  # little definition fixes that problem by returning the current class.
  def taxonomies
    self.class.name
  end


  def self.with_taxonomy_scope
    if SETTINGS[:orgs_enabled]
      # the join with organizations should exclude all objects not in the user's
      # current org(s) ... if the user has no current org, then the user will
      # see no objects as a result of this join
      taxonomy_ids = [Taxonomy.current].flatten
      taxonomy_ids = taxonomy_ids.any? ? taxonomy_ids.map(&:id) : nil
      scope = yield
      scope = scope.joins(:taxonomies).where("taxonomies.id in (?)", taxonomy_ids)

      # by default, joins result in readonly records; override
      scope = scope.readonly(false)
    end
    scope
  end


  def self.when_single_taxonomy
    unless User.current.admin?
      if SETTINGS[:single_org]
        yield if block_given?
      end
    end
  end
end
