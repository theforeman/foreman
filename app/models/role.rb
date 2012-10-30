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
  # Built-in roles
  BUILTIN_DEFAULT_USER  = 1
  BUILTIN_ANONYMOUS     = 2

  scope :givable, { :conditions => "builtin = 0", :order => 'name' }
  scope :builtin, lambda { |*args|
    compare = 'not' if args.first
    { :conditions => "#{compare} builtin = 0" }
  }

  before_destroy :check_deletable

  has_many :user_roles, :dependent => :destroy
  has_many :users, :through => :user_roles

  serialize :permissions, Array
  attr_protected :builtin

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_length_of :name, :maximum => 30
  validates_format_of :name, :with => /^\w[\w\s\'\-]*\w$/i
  validates_inclusion_of :builtin, :in => 0..2

  scoped_search :on => :name, :complete_value => true

  def initialize *args
    super *args
    self.builtin = 0
  end

  def permissions
    read_attribute(:permissions) || []
  end

  def permissions=(perms)
    perms = perms.collect {|p| p.to_sym unless p.blank? }.compact.uniq if perms
    write_attribute(:permissions, perms)
  end                                                                                    .

  def add_permission!(*perms)
    self.permissions = [] unless permissions.is_a?(Array)

    permissions_will_change!
    perms.each do |p|
      p = p.to_sym
      permissions << p unless permissions.include?(p)
    end
    save!
  end

  def remove_permission!(*perms)
    return unless permissions.is_a?(Array)
    permissions_will_change!
    perms.each { |p| permissions.delete(p.to_sym) }
    save!
  end

  # Returns true if the role has the given permission
  def has_permission?(perm)
    !permissions.nil? && permissions.include?(perm.to_sym)
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
      allowed_actions.include? "#{action[:controller]}/#{action[:action]}"
    else
      allowed_permissions.include? action
    end
  end

  # Return all the permissions that can be given to the role
  def setable_permissions
    setable_permissions  = Foreman::AccessControl.permissions - Foreman::AccessControl.public_permissions
    setable_permissions -= Foreman::AccessControl.loggedin_only_permissions if self.builtin == BUILTIN_ANONYMOUS
    setable_permissions
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
      default_user_role = create(:name => 'Default user') do |role|
        role.builtin = BUILTIN_DEFAULT_USER
      end
      raise 'Unable to create the default user role.' if default_user_role.new_record?
    end
    default_user_role
  end

  # Return the builtin 'anonymous' role.  If the role doesn't exist,
  # it will be created on the fly.
  def self.anonymous
    anonymous_role = first(:conditions => {:builtin => BUILTIN_ANONYMOUS})
    if anonymous_role.nil?
      anonymous_role = create(:name => 'Anonymous') do |role|
        role.builtin = BUILTIN_ANONYMOUS
      end
      raise "Unable to create the anonymous role." if anonymous_role.new_record?
    end
    anonymous_role
  end

private
  def allowed_permissions
    @allowed_permissions ||= permissions + Foreman::AccessControl.public_permissions.collect {|p| p.name}
  end

  def allowed_actions
    @actions_allowed ||= allowed_permissions.inject([]) { |actions, permission| actions += Foreman::AccessControl.allowed_actions(permission) }.flatten
  end

  def check_deletable
    errors.add :base, "Role is in use" if users.any?
    errors.add :base, "Can't delete builtin role" if builtin?
    errors.empty?
  end
end