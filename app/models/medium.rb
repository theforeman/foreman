class Medium < ActiveRecord::Base
  include Authorization
  has_and_belongs_to_many :operatingsystems
  has_many :hosts

  # We need to include $ in this as $arch, $release, can be in this string
  VALID_NFS_PATH=/^([\w\d\.]+):(\/[\w\d\/\$\.]+)$/
  validates_uniqueness_of :name
  validates_uniqueness_of :path
  validates_presence_of :name, :path
  validates_format_of :name, :with => /\A(\S+\s?)+\Z/, :message => "can't be blank or contain trailing white spaces."
  validates_format_of :path, :with => /^(http|https|ftp|nfs):\/\//,
    :message => "Only URLs with schema http://, https://, ftp:// or nfs:// are allowed (e.g. nfs://server/vol/dir)"

  validates_format_of :media_path, :config_path, :image_path, :allow_blank => true,
    :with => VALID_NFS_PATH, :message => "does not appear to be a valid nfs mount path",
    :if => Proc.new { |m| m.respond_to? :media_path }

  before_destroy EnsureNotUsedBy.new(:hosts)
  default_scope :order => 'LOWER(media.name)'
  scoped_search :on => :name, :complete_value => :true, :default_order => true
  scoped_search :on => :path, :complete_value => :true
  scoped_search :on => :os_family, :rename => "family", :complete_value => :true

  def as_json(options={})
    options ||= {}
    super({:only => [:name, :id]}.merge(options))
  end

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
