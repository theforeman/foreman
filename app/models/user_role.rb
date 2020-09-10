# Redmine - project management software
# Copyright (C) 2006-2009  Jean-Philippe Lang
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

class UserRole < ApplicationRecord
  include TopbarCacheExpiry

  belongs_to :owner, :polymorphic => true
  belongs_to :role

  has_many :cached_user_roles, :dependent => :destroy

  validates :role_id, :presence => true
  validates :owner_id, :uniqueness => {:scope => [:role_id, :owner_type],
                                       :message => N_("has this role already")},
                                       :unless => -> { owner.blank? }

  # if we trigger cache clean up by deleting the user, the owner relation target
  # does not work since taxable_taxonomy record is already deleted, in this case
  # we can ignore expiration since it was expired on User already
  delegate :expire_topbar_cache, :to => :owner, :allow_nil => true

  def user_role?
    owner_type == 'User'
  end

  def user_group_role?
    owner_type == 'Usergroup'
  end

  before_save :remove_cache!
  after_save :cache_user_roles!
  before_destroy :remove_cache!

  private

  def remove_cache!
    cached_user_roles.destroy_all
  end

  def cache_user_roles!
    if user_role?
      built = build_user_role_cache
    elsif user_group_role?
      built = build_user_group_role_cache(owner)
    else
      raise 'unknown UserRole owner type'
    end

    built.all?(&:save!)
  end

  def build_user_role_cache
    [cached_user_roles.build(:user_id => owner_id, :role_id => role_id)]
  end

  def build_user_group_role_cache(owner)
    cache = []
    cache += owner.users.map { |m| cached_user_roles.build(:user => m, :role => role) }
    cache += owner.usergroups.map { |g| build_user_group_role_cache(g) }
    cache.flatten
  end
end
