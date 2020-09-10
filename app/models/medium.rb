class Medium < ApplicationRecord
  audited
  include Authorizable
  extend FriendlyId
  friendly_id :name
  include Taxonomix
  include ValidateOsFamily
  include Parameterizable::ByIdName

  validates_lengths_from_database

  before_destroy :ensure_hosts_not_in_build

  has_and_belongs_to_many :operatingsystems
  has_many_hosts :dependent => :nullify
  has_many :hostgroups, :dependent => :nullify

  # We need to include $ in this as $arch, $release, can be in this string
  VALID_NFS_PATH = /\A([-\w\d\.]+):(\/[\w\d\/\$\.]+)\Z/
  validates :name, :uniqueness => true, :presence => true
  validates :path, :uniqueness => true, :presence => true,
    :url_schema => ['http', 'https', 'ftp', 'nfs']
  validates :media_path, :config_path, :image_path, :allow_blank => true,
                :format => { :with => VALID_NFS_PATH, :message => N_("does not appear to be a valid nfs mount path")},
                :if => proc { |m| m.respond_to? :media_path }

  validate_inclusion_in_families :os_family

  # with proc support, default_scope can no longer be chained
  # include all default scoping here
  default_scope lambda {
    with_taxonomy_scope do
      order("media.name")
    end
  }
  scoped_search :on => :name, :complete_value => :true, :default_order => true
  scoped_search :on => :path, :complete_value => :true
  scoped_search :on => :os_family, :rename => "family", :complete_value => :true

  def media_host
    media_path.match(VALID_NFS_PATH)[1]
  end

  def jumpstart_host
    config_path.match(VALID_NFS_PATH)[1]
  end

  def media_dir
    media_path.match(VALID_NFS_PATH)[2]
  end

  def jumpstart_dir
    config_path.match(VALID_NFS_PATH)[2]
  end

  # Write the image path, with a trailing "/" if required
  def image_path=(path)
    self[:image_path] = "#{path}#{'/' unless path =~ /\/$|^$/}"
  end

  def ensure_hosts_not_in_build
    return true if (hosts_in_build = hosts.where(:build => true)).empty?
    hosts_in_build.each do |host|
      errors.add :base, _("%{record} is used by host in build mode %{what}") % { :record => name, :what => host.name }
    end
    Rails.logger.error "You may not destroy #{to_label} as it is used by hosts in build mode!"
    throw :abort
  end
end
