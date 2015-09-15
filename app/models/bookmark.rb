class Bookmark < ActiveRecord::Base
  include Authorizable
  extend FriendlyId
  friendly_id :name
  include Parameterizable::ByIdName

  validates_lengths_from_database

  belongs_to :owner, :polymorphic => true
  attr_accessible :name, :query, :public, :controller
  audited :allow_mass_assignment => true

  validates :name, :uniqueness => {:scope => :controller}, :unless => Proc.new{|b| Bookmark.my_bookmarks.where(:name => b.name).empty?}
  validates :name, :query, :presence => true
  validates :controller, :presence => true, :no_whitespace => true, :bookmark_controller => true
  default_scope -> { order(:name) }
  before_validation :set_default_user

  scoped_search :on => :controller, :complete_value => true
  scoped_search :on => :name, :complete_value => true

  scope :my_bookmarks, lambda {
    user = User.current
    if !SETTINGS[:login] || user.nil?
      conditions = {}
    else
      conditions = sanitize_sql_for_conditions(["((bookmarks.public = ?) OR (bookmarks.owner_id = ? AND bookmarks.owner_type = 'User'))", true, user.id])
    end
    where(conditions)
  }

  scope :controller, ->(*args) { where("controller = ?", (args.first || '')) }

  def set_default_user
    self.owner ||= User.current
  end
end
