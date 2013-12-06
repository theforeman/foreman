class Medium < ActiveRecord::Base
  include Authorization
  include Authorizable
  include Taxonomix
  include ValidateOsFamily
  audited :allow_mass_assignment => true

  before_destroy EnsureNotUsedBy.new(:hosts, :hostgroups)

  has_and_belongs_to_many :operatingsystems
  has_many_hosts
  has_many :hostgroups

  # We need to include $ in this as $arch, $release, can be in this string
  VALID_NFS_PATH=/\A([-\w\d\.]+):(\/[\w\d\/\$\.]+)\Z/
  validates :name, :uniqueness => true, :presence => true,
                   :format => { :with => /\A(\S+\s)*\S+\Z/, :message => N_("can't be blank or contain trailing white spaces.") }
  validates :path, :uniqueness => true, :presence => true,
                   :format => { :with => /^(http|https|ftp|nfs):\/\//,
                                :message => N_("Only URLs with schema http://, https://, ftp:// or nfs:// are allowed (e.g. nfs://server/vol/dir)")
                              }
  validates :media_path, :config_path, :image_path, :allow_blank => true,
                :format => { :with => VALID_NFS_PATH, :message => N_("does not appear to be a valid nfs mount path")},
                :if => Proc.new { |m| m.respond_to? :media_path }

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
  def image_path= path
    write_attribute :image_path, "#{path}#{"/" unless path =~ /\/$|^$/}"
  end
end
