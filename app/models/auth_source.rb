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
  include Authorizable
  audited :allow_mass_assignment => true

  validates_lengths_from_database :except => [:name, :account_password, :host, :attr_login, :attr_firstname, :attr_lastname, :attr_mail]
  before_destroy EnsureNotUsedBy.new(:users)
  has_many :users
  has_many :external_usergroups, :dependent => :destroy

  validates :name, :presence => true, :uniqueness => true, :length => { :maximum => 60 }

  scope :non_internal, lambda { where("type NOT IN (?)", ['AuthSourceInternal', 'AuthSourceHidden']) }
  scope :except_hidden, lambda { where('type <> ?', 'AuthSourceHidden') }

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

  # Called after creating a new user at login
  def update_usergroups(login)
  end

  # Try to authenticate a user not yet registered against available sources
  # Returns : user's attributes OR nil
  def self.authenticate(login, password)
    AuthSource.where(:onthefly_register => true).each do |source|
      logger.debug "Authenticating '#{login}' against '#{source.name}'"
      begin
        if (attrs = source.authenticate(login, password))
          logger.debug "Authentication successful for '#{login}'"
          attrs[:auth_source_id] = source.id
        end
      rescue => e
        logger.error "Error during authentication: #{e.message}"
        attrs = nil
      end
      return attrs if attrs
    end
    nil
  end
end
