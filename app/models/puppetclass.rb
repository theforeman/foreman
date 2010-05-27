class Puppetclass < ActiveRecord::Base
  has_and_belongs_to_many :environments
  has_and_belongs_to_many :operatingsystems
  has_and_belongs_to_many :hosts
  has_and_belongs_to_many :hostgroups

  validates_uniqueness_of :name
  validates_presence_of :name
  validates_associated :environments
  validates_format_of :name, :with => /\A(\S+\s?)+\Z/, :message => "can't be blank or contain white spaces."
  acts_as_audited

  before_destroy Ensure_not_used_by.new(:hosts)
  before_destroy Ensure_not_used_by.new(:hostgroups)

  # scans for puppet classes
  # parameter is the module path
  # returns an array of puppetclasses objects
  def self.scanForClasses(path)
    klasses=Array.new
    Dir.glob("#{path}/*/manifests/**/*.pp").each do |manifest|
      File.read(manifest).each_line do |line|
        klass=line.match(/^class (\S+).*\{/)
        klasses << Puppetclass.find_or_create_by_name(klass[1]) if klass
      end
    end
    return klasses
  end

  def to_s
    name
  end

  # returns a hash containing modules and associated classes
  def self.classes2hash classes
    hash = {}
    for klass in classes
      if mod = klass.module_name
        hash[mod] ||= []
        hash[mod] << klass
      else
        next
      end
    end
    return hash
  end

  # returns module name (excluding of the class name)
  # if class seperator does not exists (the "::" chars), then returns the whole class name
  def module_name
    return (i = name.index("::")) ? name[0..i-1] : name
  end

  # returns class name (excluding of the module name)
  def klass
    return name.gsub(module_name+"::","")
  end

  # add sort by class name
  def <=>(other)
    klass <=> other.klass
  end

  def self.per_page
    20
  end

end
