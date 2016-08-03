# redMine - project management software
# Copyright (C) 2006  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

class Role < ActiveRecord::Base
  include Authorizable
  extend FriendlyId
  friendly_id :name

  include Parameterizable::ByIdName

  # Built-in roles
  BUILTIN_DEFAULT_ROLE = 2
  audited

  scope :givable, -> { where(:builtin => 0).order(:name) }
  scope :for_current_user, -> { User.current.admin? ? where('0 = 0') : where(:id => User.current.role_ids) }
  scope :builtin, lambda { |*args|
    compare = 'not' if args.first
    where("#{compare} builtin = 0")
  }

  validates_lengths_from_database

  before_destroy :check_deletable
  after_save :sync_inheriting_filters

  has_many :user_roles, :dependent => :destroy
  has_many :users, :through => :user_roles, :source => :owner, :source_type => 'User'
  has_many :usergroups, :through => :user_roles, :source => :owner, :source_type => 'Usergroup'
  has_many :cached_user_roles, :dependent => :destroy
  has_many :cached_users, :through => :cached_user_roles, :source => :user

  has_many :filters, :dependent => :destroy

  has_many :permissions, :through => :filters

  # these associations are not used by Taxonomix but serve as a pattern for role filters
  # we intentionally don't include Taxonomix since roles are not taxable, we only need these relations
  taxonomy_join_table = :taxable_taxonomies
  has_many taxonomy_join_table.to_sym, :dependent => :destroy, :as => :taxable
  has_many :locations, -> { where(:type => 'Location') },
           :through => taxonomy_join_table, :source => :taxonomy
  has_many :organizations, -> { where(:type => 'Organization') },
           :through => taxonomy_join_table, :source => :taxonomy

  validates :name, :presence => true, :uniqueness => true
  validates :builtin, :inclusion => { :in => 0..2 }

  scoped_search :on => :name, :complete_value => true

  def permissions=(new_permissions)
    add_permissions(new_permissions.map(&:name).uniq) if new_permissions.present?
  end

  # Returns true if the role has the given permission
  def has_permission?(perm)
    permission_names.include?(perm.name.to_sym)
  end

  def permission_names
    @permission_names ||= permissions.pluck('permissions.name').map(&:to_sym)
  end

  # Return true if the role is a builtin role
  def builtin?
    self.builtin != 0
  end

  # Return true if the role is a user role
  def user?
    !self.builtin?
  end

  # Return true if role is allowed to do the specified action
  # action can be:
  # * a parameter-like Hash (eg. :controller => 'projects', :action => 'edit')
  # * a permission Symbol (eg. :edit_project)
  def allowed_to?(action)
    if action.is_a? Hash
      allowed_actions.include? Foreman::AccessControl.path_hash_to_string(action)
    else
      allowed_permissions.include? action
    end
  end

  # Find all the roles that can be given to a user
  def self.find_all_givable
    all(:conditions => {:builtin => 0}, :order => 'name')
  end

  # Return the builtin 'Default role' role. If the role doesn't exist,
  # it will be created on the fly.
  def self.default
    default_role = find_by_builtin(BUILTIN_DEFAULT_ROLE)
    if default_role.nil?
      default_role = create!(:name => 'Default role', :builtin => BUILTIN_DEFAULT_ROLE)
      raise ::Foreman::Exception.new(N_("Unable to create the default role.")) if default_role.new_record?
    end
    default_role
  end

  # options can have following keys
  # :search - scoped search applied to built filters
  def add_permissions(permissions, options = {})
    permissions = Array(permissions)
    search = options.delete(:search)

    collection = Permission.where(:name => permissions).all
    raise ArgumentError, 'some permissions were not found' if collection.size != permissions.size

    collection.group_by(&:resource_type).each do |resource_type, grouped_permissions|
      filter = self.filters.build(:search => search)
      filter.role ||= self

      grouped_permissions.each do |permission|
        filtering = filter.filterings.build
        filtering.filter = filter
        filtering.permission = permission
      end
    end
  end

  def add_permissions!(*args)
    add_permissions(*args)
    save!
  end

  def disable_filters_overriding
    self.filters.where(:override => true).map { |filter| filter.disable_overriding! }
  end

  private

  def sync_inheriting_filters
    self.filters.where(:override => false).each { |f| f.inherit_taxonomies! }
  end

  def allowed_permissions
    @allowed_permissions ||= permission_names + Foreman::AccessControl.public_permissions.map(&:name)
  end

  def allowed_actions
    @actions_allowed ||= allowed_permissions.inject([]) { |actions, permission| actions + Foreman::AccessControl.allowed_actions(permission) }.flatten
  end

  def check_deletable
    errors.add(:base, _("Role is in use")) if users.any?
    errors.add(:base, _("Can't delete built-in role")) if builtin?
    errors.empty?
  end
end
