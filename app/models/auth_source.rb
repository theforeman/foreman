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

class AuthSource < ActiveRecord::Base
  include Authorization
  has_many :users

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_length_of :name, :maximum => 60

  def authenticate(login, password)
  end

  def test_connection
  end

  def auth_method_name
    "Abstract"
  end

  def to_label
    if type_before_type_cast.empty?
      logger.warn "Corrupt AuthSource! Record id:#{id} name:#{name} does not have an associated type. This may be due to importing a production database."
      return nil
    end

    kind = type_before_type_cast.sub("AuthSource","")
    "#{kind.upcase}-#{name}" if name
  end

  # By default a user may not set their password via Foreman
  # An internal AuthSource should override this and provide a password mechanism
  def can_set_password?
    false
  end

  # Try to authenticate a user not yet registered against available sources
  # Returns : user's attributes OR nil
  def self.authenticate(login, password)
    AuthSource.find(:all).each do |source|
      begin
        logger.debug "Authenticating '#{login}' against '#{source.name}'" if logger && logger.debug?
        attrs = source.authenticate(login, password)
      rescue => e
        logger.error "Error during authentication: #{e.message}"
        attrs = nil
      end
      return attrs if attrs
    end
    return nil
  end
end
