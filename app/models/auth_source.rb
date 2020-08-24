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

class AuthSource < ApplicationRecord
  audited
  include Authorizable
  scoped_search :on => :name, :complete_value => :true

  has_many Taxonomix::TAXONOMY_JOIN_TABLE, :dependent => :destroy, :as => :taxable
  has_many :locations, -> { where(:type => 'Location') },
    :through => Taxonomix::TAXONOMY_JOIN_TABLE, :source => :taxonomy,
    :validate => false
  has_many :organizations, -> { where(:type => 'Organization') },
    :through => Taxonomix::TAXONOMY_JOIN_TABLE, :source => :taxonomy,
    :validate => false

  scoped_search :relation => :locations, :on => :name, :rename => :location, :complete_value => true, :only_explicit => true
  scoped_search :relation => :locations, :on => :id, :rename => :location_id, :complete_enabled => false, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
  scoped_search :relation => :organizations, :on => :name, :rename => :organization, :complete_value => true, :only_explicit => true
  scoped_search :relation => :organizations, :on => :id, :rename => :organization_id, :complete_enabled => false, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER

  scoped_search :on => :name, :complete_value => :true

  # audited gem uses class variable for audied_options so once child class define auditing of these associations
  # other auth sources definitions start failing, since organization_ids_changed? method is undefined there
  audit_associations :organizations, :locations

  validates_lengths_from_database :except => [:name, :account_password, :host, :attr_login, :attr_firstname, :attr_lastname, :attr_mail]
  before_destroy EnsureNotUsedBy.new(:users)
  has_many :users
  has_many :external_usergroups, :dependent => :destroy

  validates :name, :presence => true, :uniqueness => true, :length => { :maximum => 60 }

  scope :non_internal, -> { where.not(type: (internal_types + hidden_types).map(&:to_s)) }
  scope :except_hidden, -> { where.not(type: hidden_types.map(&:to_s)) }
  scope :only_ldap, -> { where(type: ldap_types.map(&:to_s)) }

  def self.internal_types
    [AuthSourceInternal] + AuthSourceInternal.descendants
  end

  def self.hidden_types
    [AuthSourceHidden] + AuthSourceHidden.descendants
  end

  def self.ldap_types
    [AuthSourceLdap] + AuthSourceLdap.descendants
  end

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

    kind = type_before_type_cast.sub("AuthSource", "")
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

  def refresh_usergroup_members(usergroup)
  end

  # Does the user exist?
  def valid_user?(name)
    false
  end

  # Try to authenticate a user not yet registered against available sources
  # Returns : user's attributes OR nil
  def self.authenticate(login, password)
    AuthSource.where(:onthefly_register => true).find_each do |source|
      logger.debug "Authenticating '#{login}' against '#{source}'"
      begin
        if (attrs = source.authenticate(login, password))
          logger.debug "Authentication successful for '#{login}'"
          attrs[:auth_source_id] = source.id
        end
      rescue => e
        Foreman::Logging.exception("Error during authentication against '#{source}'", e)
        attrs = nil
      end
      return attrs if attrs
    end
    nil
  end

  def supports_refresh?
    true
  end
end
