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
  MANAGER = 'Manager'
  ORG_ADMIN = 'Organization admin'
  VIEWER = 'Viewer'

  audited

  scope :givable, -> { where(:builtin => 0).order(:name) }
  scope :for_current_user, -> { User.current.admin? ? where('0 = 0') : where(:id => User.current.role_ids) }
  scope :builtin, lambda { |*args|
    compare = 'not' if args.first
    where("#{compare} builtin = 0")
  }
  scope :cloned, -> { where.not(:cloned_from_id => nil) }

  validates_lengths_from_database
  before_destroy :check_deletable

  attr_accessor :modify_locked
  validate :not_locked
  before_destroy :not_locked

  after_save :sync_inheriting_filters

  has_many :user_roles, :dependent => :destroy
  has_many :users, :through => :user_roles, :source => :owner, :source_type => 'User'
  has_many :usergroups, :through => :user_roles, :source => :owner, :source_type => 'Usergroup'
  has_many :cached_user_roles, :dependent => :destroy
  has_many :cached_users, :through => :cached_user_roles, :source => :user

  has_many :filters, :autosave => true, :dependent => :destroy

  has_many :permissions, :through => :filters

  has_many :cloned_roles, :class_name => 'Role', :foreign_key => 'cloned_from_id', :dependent => :nullify
  belongs_to :cloned_from, :class_name => 'Role'

  # these associations are not used by Taxonomix but serve as a pattern for role filters
  # we intentionally don't include Taxonomix since roles are not taxable, we only need these relations
  taxonomy_join_table = :taxable_taxonomies
  has_many taxonomy_join_table.to_sym, :dependent => :destroy, :as => :taxable
  has_many :locations, -> { where(:type => 'Location') },
           :through => taxonomy_join_table, :source => :taxonomy, :validate => false
  has_many :organizations, -> { where(:type => 'Organization') },
           :through => taxonomy_join_table, :source => :taxonomy, :validate => false

  validates :name, :presence => true, :uniqueness => true
  validates :builtin, :inclusion => { :in => 0..2 }

  scoped_search :on => :name, :complete_value => true
  scoped_search :on => :builtin, :complete_value => { :true => true, :false => false }
  scoped_search :on => :description, :complete_value => false

  class << self
    attr_accessor :modify_locked

    def ignore_locking
      self.modify_locked = true
      yield
    ensure
      self.modify_locked = false
    end

    # Find all the roles that can be given to a user
    def find_all_givable
      all(:conditions => {:builtin => 0}, :order => 'name')
    end

    # Return the builtin 'Default role' role. If the role doesn't exist,
    # it will be created on the fly.
    def default
      default_role = find_by_builtin(BUILTIN_DEFAULT_ROLE)
      if default_role.nil?
        opts = { :name => 'Default role', :builtin => BUILTIN_DEFAULT_ROLE }
        default_role = create! opts
        raise ::Foreman::Exception.new(N_("Unable to create the default role.")) if default_role.new_record?
      end
      default_role
    end
  end

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
    if action.is_a?(Hash) || action.is_a?(ActionController::Parameters)
      allowed_actions.include? Foreman::AccessControl.path_hash_to_string(action)
    else
      allowed_permissions.include? action
    end
  end

  # options can have following keys
  # :search - scoped search applied to built filters
  def add_permissions(permissions, options = {})
    permissions = Array(permissions)
    search = options.delete(:search)

    collection = Permission.where(:name => permissions).all
    raise ::Foreman::PermissionMissingException.new(N_('some permissions were not found')) if collection.size != permissions.size

    current_filters = self.filters
    collection.group_by(&:resource_type).each do |resource_type, grouped_permissions|
      filter = find_filter resource_type, current_filters, search

      grouped_permissions.each do |permission|
        filtering = filter.filterings.build
        filtering.filter = filter
        filtering.permission = permission
      end
    end
  end

  def permission_diff(permission_names)
    current_names = permissions.map(&:name).map(&:to_sym)
    (current_names - permission_names) | (permission_names - current_names)
  end

  def add_permissions!(*args)
    add_permissions(*args)
    save!
  end

  def disable_filters_overriding
    self.filters.where(:override => true).map { |filter| filter.disable_overriding! }
  end

  def clone(role_params = {})
    new_role = self.deep_clone(:except => [:name, :builtin, :origin],
                               :include => [:locations, :organizations, { :filters => :permissions }])
    new_role.attributes = role_params
    new_role.cloned_from_id = self.id
    new_role
  end

  def locked?
    return false if self.modify_locked || self.class.modify_locked
    return false unless respond_to? :origin
    origin.present? && builtin != BUILTIN_DEFAULT_ROLE
  end

  def ignore_locking
    self.modify_locked = true
    yield self
    self.modify_locked = false
    self
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
    errors.add(:base, _("Cannot delete built-in role")) if builtin?
    errors.empty?
  end

  def not_locked
    errors.add(:base, _("This role is locked from being modified by users.")) if locked? && !modify_locked && changed?
    errors.empty?
  end

  def find_filter(resource_type, current_filters, search)
    filter_record = Filter.where(:search => search, :role_id => id).joins(:permissions)
                          .where("permissions.resource_type" => resource_type).first
    if filter_record
      # add filterings to what we have in memory, not to a newly fetched record
      current_filters.detect { |fil| fil.id == filter_record.id }
    else
      self.filters.build(:search => search)
    end
  end
end
