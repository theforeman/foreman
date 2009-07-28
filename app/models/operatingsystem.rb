class Operatingsystem < ActiveRecord::Base
  has_many :hosts, :through => :hosttypes
  has_many :medias
  has_and_belongs_to_many :architectures
  has_and_belongs_to_many :hosttypes
  validates_presence_of :major, :message => "Operating System version is required"
  validates_presence_of :name

  before_destroy :ensure_not_used

  # The OS is usually represented as the catenation of the OS and the revision. E.G. "Solaris 10"
  def to_label
    "#{name} #{major}#{('.' + minor) unless minor.empty?}"
  end

  def to_s
    to_label
  end

  # a simple methods that reads data from store config and populate the operating systems table
  # TODO, make this more SQL friendly
  def self.importFacts
    helper = Array.new
    Host.all.each do |h|
     if name = h.fact(:operatingsystem)[0]
       name = name.value
     end
     if major = h.fact(:operatingsystemrelease)[0]
       major = major.value
     end
     if name and major
       helper << {name => major}
     end
    end
    helper.uniq!.each do |os|
      os.each_pair do |n,m|
        Operatingsystem.create :name => n, :major => m
      end
    end
  end
end
