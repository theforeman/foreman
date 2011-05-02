class Bookmark < ActiveRecord::Base
  belongs_to :owner, :polymorphic => true
  attr_accessible :name, :controller, :query, :public

  validates_uniqueness_of :name, :unless => Proc.new{|b| Bookmark.my_bookmarks(:conditions => {:name => b.name}).empty?}
  validates_presence_of :name
  validates_format_of :controller, :with => /\A(\S+)\Z/, :message => "can't be blank or contain white spaces."
  validates_presence_of :query
  default_scope :order => :name

  named_scope :my_bookmarks, lambda {
    return {} unless SETTINGS[:login]

    user       = User.current
    conditions = sanitize_sql_for_conditions(["((bookmarks.public = ?) OR (bookmarks.owner_id in (?) AND bookmarks.owner_type = 'Usergroup') OR (bookmarks.owner_id = ? AND bookmarks.owner_type = 'User'))", true, user.my_usergroups.map(&:id), user.id])
    {:conditions => conditions}
  }

  def after_initialize
    self.owner ||= User.current
  end

  def to_param
    name
  end
end
