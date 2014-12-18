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
  BUILTIN_DEFAULT_USER  = 1
  BUILTIN_ANONYMOUS     = 2
  audited :allow_mass_assignment => true

  scope :givable, lambda { where(:builtin => 0).order(:name) }
  scope :for_current_user, lambda { User.current.admin? ? {} : where(:id => User.current.role_ids) }
  scope :builtin, lambda { |*args|
    compare = 'not' if args.first
    where("#{compare} builtin = 0")
  }

  validates_lengths_from_database
  before_destroy :check_deletable

  has_many :user_roles, :dependent => :destroy
  has_many :users, :through => :user_roles, :source => :owner, :source_type => 'User'
  has_many :usergroups, :through => :user_roles, :source => :owner, :source_type => 'Usergroup'
  has_many :cached_user_roles, :dependent => :destroy
  has_many :cached_users, :through => :cached_user_roles, :source => :user

  has_many :filters, :dependent => :destroy

  has_many :permissions, :through => :filters

  validates :name, :presence => true, :uniqueness => true
  validates :builtin, :inclusion => { :in => 0..2 }

  scoped_search :on => :name, :complete_value => true

  def initialize(*args)
    super(*args)
    self.builtin = 0
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
      action[:controller] = action[:controller][1..-1] if action[:controller].starts_with?('/')
      allowed_actions.include? "#{action[:controller]}/#{action[:action]}"
    else
      allowed_permissions.include? action
    end
  end

  # Find all the roles that can be given to a user
  def self.find_all_givable
    all(:conditions => {:builtin => 0}, :order => 'name')
  end

  # Return the builtin 'default user' role.  If the role doesn't exist,
  # it will be created on the fly.
  def self.default_user
    default_user_role = first(:conditions => {:builtin => BUILTIN_DEFAULT_USER})
    if default_user_role.nil?
      default_user_role = create!(:name => 'Default user') do |role|
        role.builtin = BUILTIN_DEFAULT_USER
      end
      raise ::Foreman::Exception.new(N_('Unable to create the default user role.')) if default_user_role.new_record?
    end
    default_user_role
  end

  # Return the builtin 'anonymous' role.  If the role doesn't exist,
  # it will be created on the fly.
  def self.anonymous
    anonymous_role = first(:conditions => {:builtin => BUILTIN_ANONYMOUS})
    if anonymous_role.nil?
      anonymous_role = create!(:name => 'Anonymous') do |role|
        role.builtin = BUILTIN_ANONYMOUS
      end
      raise ::Foreman::Exception.new(N_("Unable to create the anonymous role.")) if anonymous_role.new_record?
    end
    anonymous_role
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

private

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
