class Environment < ActiveRecord::Base
  has_and_belongs_to_many :puppetclasses
  has_many :hosts
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_format_of   :name, :with => /^\S+$/, :message => "Name cannot contain spaces"

  def to_label
    name
  end

  def to_s
    name
  end

  # returns an hash of all puppet environments and their relative paths
  def self.puppetEnvs
    env = Hash.new
    # read puppet configuration
    conf = Puppet.settings.instance_variable_get(:@values)
    unless conf[:main][:environments].nil?
      conf[:main][:environments].split(",").each {|e| env[e.to_sym] = conf[e.to_sym][:modulepath]}
    else
      # we dont use environments
      env[:production] = conf[:main][:modulepath] || conf[:puppetmasterd][:modulepath] || $settings[:modulepath] || "/etc/puppet/modules"
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
