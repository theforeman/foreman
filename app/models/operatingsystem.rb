require 'ostruct'
require 'uri'

class Operatingsystem < ActiveRecord::Base
  has_many :hosts
  has_and_belongs_to_many :medias
  has_and_belongs_to_many :ptables
  has_and_belongs_to_many :architectures
  has_and_belongs_to_many :puppetclasses
  validates_presence_of :major, :message => "Operating System version is required"
  validates_numericality_of :major
  validates_numericality_of :minor, :allow_nil => true, :allow_blank => true
  validates_format_of :name, :with => /\A(\S+)\Z/, :message => "can't be blank or contain white spaces."
  before_validation :downcase_release_name
  #TODO: add validation for name and major uniqueness

  before_destroy Ensure_not_used_by.new(:hosts)
  before_save :deduce_family
  acts_as_audited

  FAMILIES = {'Debian'  => %r{Debian|Ubuntu}i,
              'Redhat'  => %r{RedHat|Centos|Fedora}i,
              'Solaris' => %r{Solaris}i}

  # As Rails loads an object it casts it to the class in the 'type' field. If we ensure that the type and
  # family are the same thing then rails converts the record to a Debian or a solaris object as required.
  # Manually managing the 'type' field allows us to control the inheritance chain and the available methods
  def family
    type
  end

  def family=(value)
    self.type = value
  end

  def self.families
    FAMILIES.keys.sort
  end

  def self.families_as_collection
    families.map{|e| OpenStruct.new(:name => e, :value => e) }
  end

  def media_uri host, url = nil
    url ||= host.media.path
    URI.parse(url.gsub('$arch',    host.architecture.name).
                  gsub('$major',   host.os.major).
                  gsub('$minor',   host.os.minor).
                  gsub('$version', [ host.os.major, host.os.minor ].compact.join('.'))
             ).normalize
  end

  # The OS is usually represented as the catenation of the OS and the revision. E.G. "Solaris 10"
  def to_label
    "#{name} #{major}#{('.' + minor) unless minor.empty?}"
  end

  def to_s
    to_label
  end

  def fullname
    to_label
  end

  def as_json(options={})
    {:operatingsystem => {:name => to_s, :id => id}}
  end

  private
  def deduce_family
    if self.family.blank?
      found = nil
      for f in self.class.families
        if name =~ FAMILIES[f]
          found = f
        end
      end
      self.family = found
    end
  end

  def downcase_release_name
    self.release_name.downcase! unless defined?(Rake) or release_name.nil? or release_name.empty?
  end

end
