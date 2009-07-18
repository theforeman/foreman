class Media < ActiveRecord::Base
  has_many :hosts
  has_one :os
  before_destroy :ensure_not_used
  validates_uniqueness_of :name
  validates_presence_of :name, :path

  private
  # This is a before_destroy callback that ensures that the media is
  # not removed if any host is currently using it.
  def ensure_not_used
    self.hosts.length == 0
  end

end
