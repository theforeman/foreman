class Media < ActiveRecord::Base
  belongs_to :operatingsystem
  has_many :hosts
  validates_uniqueness_of :path
  validates_presence_of :name, :path
  validates_format_of :path, :with => /^((http|ftp):\/\/)|\w+:\/\w+/, :message => "path must be a url (http:// or ftp://) or a NFS share (e.g. server:/vol/dir), it should not include the architecture direcoty at the end.
  for example: http://mirror.nus.edu.sg/fedora/releases/11/Fedora"

  alias_attribute :os, :operatingsystem
  before_destroy :ensure_not_used

end
