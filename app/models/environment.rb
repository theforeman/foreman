class Environment < ActiveRecord::Base
  has_and_belongs_to_many :puppetclasses
  has_many :hosts
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_format_of   :name, :with => /^[\w\d]+$/, :message => "is alphanumeric and cannot contain spaces"
  default_scope :order => 'name'

  before_destroy Ensure_not_used_by.new(:hosts)

  # returns an hash of all puppet environments and their relative paths
  def self.puppetEnvs
    env = Hash.new
    # read puppet configuration
    conf = Puppet.settings.instance_variable_get(:@values)

    # query for the environments variable
    unless conf[:main][:environments].nil?
      conf[:main][:environments].split(",").each {|e| env[e.to_sym] = conf[e.to_sym][:modulepath]}
    else
      # 0.25 doesn't require the environments variable anymore, scanning for modulepath
      conf.keys.each {|p| env[p] = conf[p][:modulepath] unless conf[p][:modulepath].nil?}
      # puppetmaster section "might" also returns the modulepath
      env.delete :main
      env.delete :puppetmasterd if env.size > 1

      if env.size == 0
        # fall back to defaults - we probably don't use environments
        env[:production] = conf[:main][:modulepath] || conf[:puppetmasterd][:modulepath] || SETTINGS[:modulepath] || Puppet[:modulepath] || "/etc/puppet/modules"
      end
    end
    return env
  end

  # Imports all Environments and classes from Puppet modules.
  # TODO: compare between current and imported state, so old-unused ones will be deleted
  def self.importClasses
    self.puppetEnvs.each_pair do |e,p|
      env = Environment.find_or_create_by_name e.to_s
      # if module path contains more than one directory
      helper = Array.new
      p.split(":").each {|mp| helper += Puppetclass.scanForClasses(mp)}
      env.puppetclasses = helper
    end
  end

end
