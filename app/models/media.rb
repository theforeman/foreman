class Media < ActiveRecord::Base
  belongs_to :operatingsystem
  has_many :hosts
  validates_uniqueness_of :name, :scope => :operatingsystem_id
  validates_uniqueness_of :path, :scope => :operatingsystem_id
  validates_presence_of :name, :path
  validates_format_of :name, :with => /\A(\S+\s?)+\Z/, :message => "can't be blank or contain trailing white spaces."
  validates_format_of :path, :with => /^(http|https|ftp|nfs):\/\//,
    :message => "Only URLs with schema http://, https://, ftp:// or nfs:// are allowed (e.g. nfs://server/vol/dir)"

  alias_attribute :os, :operatingsystem
  before_destroy Ensure_not_used_by.new(:hosts)

  def to_s
    name
  end

end
