class Architecture < ApplicationRecord
  audited
  include Authorizable
  extend FriendlyId
  friendly_id :name
  include Parameterizable::ByIdName

  before_destroy EnsureNotUsedBy.new(:hosts, :hostgroups)
  validates_lengths_from_database

  has_many_hosts
  has_many :hostgroups
  has_many :images, :dependent => :destroy
  has_and_belongs_to_many :operatingsystems
  validates :name, :presence => true, :uniqueness => true, :no_whitespace => true

  scoped_search :on => :name, :complete_value => :true

  def bootfilename_efi
    case name
    when /i.86/
      'ia32'
    when /x86[_-]64/
      'x64'
    when /aarch64|aa64/
      'aa64'
    else # ppc64, ppc64le and others
      name.parameterize.gsub(/[^\w\.-]/, '_')
    end
  end
end
