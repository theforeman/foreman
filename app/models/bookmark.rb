class Bookmark < ActiveRecord::Base
  include Authorizable

  belongs_to :owner, :polymorphic => true
  attr_accessible :name, :controller, :query, :public
  audited :allow_mass_assignment => true

  validates :name, :uniqueness => true, :unless => Proc.new{|b| Bookmark.my_bookmarks.where(:name => b.name).empty?}
  validates :name, :query, :presence => true
  validates :controller, :presence => true,
                         :format => { :with => /\A(\S+)\Z/, :message => N_("can't be blank or contain white spaces.") },
                         :inclusion => {
                           :in => ["dashboard"] + ActiveRecord::Base.connection.tables.map(&:to_s),
                           :message => _("%{value} is not a valid controller") }
  default_scope lambda { order(:name) }
  before_validation :set_default_user

  scope :my_bookmarks, lambda {
    user = User.current
    return {} unless SETTINGS[:login] and !user.nil?

    user       = User.current
    conditions = sanitize_sql_for_conditions(["((bookmarks.public = ?) OR (bookmarks.owner_id = ? AND bookmarks.owner_type = 'User'))", true, user.id])
    where(conditions)
  }

  scope :controller, lambda { |*args| where("controller = ?", (args.first || '')) }

  def set_default_user
    self.owner ||= User.current
  end

  def to_param
    "#{id}-#{name.parameterize}"
  end
end
