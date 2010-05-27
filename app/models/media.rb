class Media < ActiveRecord::Base
  has_and_belongs_to_many :operatingsystems
  has_many :hosts
  validates_uniqueness_of :name
  validates_uniqueness_of :path
  validates_presence_of :name, :path
  validates_format_of :name, :with => /\A(\S+\s?)+\Z/, :message => "can't be blank or contain trailing white spaces."
  validates_format_of :path, :with => /^(http|https|ftp|nfs):\/\//,
    :message => "Only URLs with schema http://, https://, ftp:// or nfs:// are allowed (e.g. nfs://server/vol/dir)"

  alias_attribute :os, :operatingsystem
  alias_attribute :to_s, :name
  alias_attribute :to_label, :name
  before_destroy Ensure_not_used_by.new(:hosts)

end
