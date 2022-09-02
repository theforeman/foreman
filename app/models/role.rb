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

class Role < ApplicationRecord
  audited
  include Authorizable
  include ScopedSearchExtensions
  extend FriendlyId
  friendly_id :name

  include Parameterizable::ByIdName
  # Built-in roles
  BUILTIN_DEFAULT_ROLE = 2
  MANAGER = 'Manager'
  ORG_ADMIN = 'Organization admin'
  VIEWER = 'Viewer'
  SYSTEM_ADMIN = 'System admin'
  SITE_MANAGER = 'Site manager'

  has_associated_audits
  scope :givable, -> { where(:builtin => 0).order(:name) }
  scope :for_current_user, -> { User.current.can_escalate? ? givable : givable.where(:id => User.current.cached_role_ids) }
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

  scoped_search :on => :id, :complete_enabled => false, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
  scoped_search :on => :name, :complete_value => true
  scoped_search :on => :builtin, :complete_value => { :true => true, :false => false }
  scoped_search :on => :description, :complete_value => false
  scoped_search :on => :locked, :ext_method => :search_by_locked, :complete_value => { :true => true, :false => false }, :operators => ['= '], :only_explicit => true
  scoped_search :relation => :permissions, :on => :name, :complete_value => true, :rename => :permission, :only_explicit => true, :ext_method => :search_by_permission

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
        Role.without_auditing do
          Role.skip_permission_check do
            opts = { :name => 'Default role', :builtin => BUILTIN_DEFAULT_ROLE }
            default_role = create! opts
          end
        end
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
    builtin != 0
  end

  # Return true if the role is a user role
  def user?
    !builtin?
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

    collection = permission_records permissions

    current_filters = filters
    collection.group_by(&:resource_type).each do |resource_type, grouped_permissions|
      filter = filter_for_permission_add resource_type, current_filters, search

      grouped_permissions.each do |permission|
        next if filter.permissions.include?(permission)
        filtering = filter.filterings.build
        filtering.filter = filter
        filtering.permission = permission
        filtering.save! if options[:save!]
      end
    end
  end

  def find_for_permission_removal(permission_names)
    collection = permission_records permission_names
    current_filters = filters
    collection.group_by(&:resource_type).inject([]) do |memo, (resource_type, grouped_permissions)|
      memo.concat filters_and_filterings_for_removal(resource_type, grouped_permissions, current_filters)
    end
  end

  def filters_and_filterings_for_removal(resource_type, grouped_permissions, current_filters)
    filter = filter_for_permissions_remove resource_type, current_filters
    if filter.permissions.size == grouped_permissions.size
      [filter]
    else
      grouped_permissions.map do |perm|
        Filtering.find_by(:filter_id => filter.id, :permission_id => perm.id)
      end
    end
  end

  def permission_diff(permission_names)
    current_names = permission_symbols
    extra_permissions(permission_names, current_names) | missing_permissions(permission_names, current_names)
  end

  def permission_symbols
    permissions.map { |p| p.name.to_sym }
  end

  def extra_permissions(permission_names, current_names = permission_symbols)
    current_names - permission_names
  end

  def missing_permissions(permission_names, current_names = permission_symbols)
    permission_names - current_names
  end

  def add_permissions!(permissions, opts = {})
    add_permissions(permissions, opts.merge(:save! => true))
    save!
  end

  def remove_permissions!(*args)
    find_for_permission_removal(args).map(&:destroy!)
  end

  def disable_filters_overriding
    filters.where(:override => true).map { |filter| filter.disable_overriding! }
  end

  def clone(role_params = {})
    new_role = deep_clone(:except => [:name, :builtin, :origin],
                               :include => [:locations, :organizations, { :filters => :permissions }])
    new_role.attributes = role_params
    new_role.cloned_from_id = id
    new_role.filters = new_role.filters.select { |f| f.filterings.present? }
    new_role
  end

  def locked?
    return false if modify_locked || self.class.modify_locked
    return false unless respond_to? :origin
    origin.present? && builtin != BUILTIN_DEFAULT_ROLE
  end

  def ignore_locking
    self.modify_locked = true
    yield self
    self.modify_locked = false
    self
  end

  def self.search_by_permission(key, operator, value)
    condition = search_condition_for_permission(operator, value)
    role_ids = Filter.joins(:permissions).where(condition).select(
      'distinct filters.role_id, filters.id'
    ).map(&:role_id).uniq.join(',')
    role_ids = '-1' if role_ids.empty?
    role_condition = "id IN (#{role_ids})"
    role_condition = "id NOT IN (#{role_ids})" if ['<>', 'NOT ILIKE', 'NOT IN'].include?(operator)
    {:conditions => role_condition}
  end

  def self.search_by_locked(key, operator, value)
    role_condition = "origin IS NOT NULL AND builtin <> #{BUILTIN_DEFAULT_ROLE}"
    if value == 'false'
      role_condition = "NOT (#{role_condition})"
    end
    {:conditions => role_condition}
  end

  def self.search_condition_for_permission(operator, value)
    operator_val = override_search_operator(operator)
    if operator_val.eql?('IN')
      sanitize_sql_for_conditions(["permissions.name #{operator_val} (?)", value_to_sql(operator_val, value)])
    else
      sanitize_sql_for_conditions(["permissions.name #{operator_val} ?", value_to_sql(operator_val, value)])
    end
  end

  def self.override_search_operator(operator)
    case operator.strip
    when '<>'
      '='
    when 'NOT ILIKE'
      'ILIKE'
    when 'NOT IN'
      'IN'
    else
      operator
    end
  end

  private

  def sync_inheriting_filters
    filters.where(:override => false).find_each do |f|
      unless f.save
        errors.add :base, N_('One or more of the associated filters are invalid which prevented the role to be saved')
        raise ActiveRecord::Rollback, N_("Unable to submit role: Problem with associated filter %s") % f.errors
      end
    end
  end

  def allowed_permissions
    @allowed_permissions ||= permission_names + Foreman::AccessControl.public_permissions.map(&:name)
  end

  def allowed_actions
    @actions_allowed ||= allowed_permissions.inject([]) { |actions, permission| actions + Foreman::AccessControl.allowed_actions(permission) }.flatten
  end

  def check_deletable
    if builtin?
      errors.add(:base, _("Cannot delete built-in role"))
      throw :abort
    end
  end

  def not_locked
    errors.add(:base, _("This role is locked from being modified by users.")) if locked? && !modify_locked && changed?
    errors.empty?
  end

  def find_filter(resource_type, current_filters, search = :skip)
    filter = Filter.where(:role_id => id).joins(:permissions)
          .where("permissions.resource_type" => resource_type)
    filter = filter.where(search: search) unless search == :skip
    filter.first
  end

  def filter_for_permission_add(resource_type, current_filters, search)
    filter_record = find_filter resource_type, current_filters, search
    if filter_record
      # add filterings to what we have in memory, not to a newly fetched record
      find_current_filter current_filters, filter_record
    else
      filters.build(:search => search)
    end
  end

  def filter_for_permissions_remove(resource_type, current_filters)
    filter_record = find_filter resource_type, current_filters
    find_current_filter current_filters, filter_record
  end

  def find_current_filter(current_filters, filter_record)
    current_filters.reload.detect { |fil| fil.id == filter_record.id }
  end

  def permission_records(permissions)
    perms = permissions.flatten
    collection = Permission.where(:name => perms).all
    if collection.size != perms.size
      raise ::Foreman::PermissionMissingException.new(N_("some permissions were not found: %s"),
        not_found_permissions(collection.pluck(:name), perms))
    end
    collection
  end

  def not_found_permissions(first, second)
    (first - second) | (second - first)
  end
end
