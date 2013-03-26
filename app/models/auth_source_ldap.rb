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

require 'net/ldap'
require 'iconv'

class AuthSourceLdap < AuthSource
  validates_presence_of :host, :port
  validates_presence_of :attr_login, :attr_firstname, :attr_lastname, :attr_mail, :if => Proc.new { |auth| auth.onthefly_register? }
  validates_length_of :name, :host, :account_password, :maximum => 60, :allow_nil => true
  validates_length_of :account, :base_dn, :maximum => 255, :allow_nil => true
  validates_length_of :attr_login, :attr_firstname, :attr_lastname, :attr_mail, :maximum => 30, :allow_nil => true
  validates_numericality_of :port, :only_integer => true

  before_validation :strip_ldap_attributes
  after_initialize :set_defaults

  # Loads the LDAP info for a user and authenticates the user with their password
  # Returns : Array of Strings.
  #           Either the users's DN or the user's full details OR nil
  def authenticate(login, password)
    return nil if login.blank? || password.blank?

    logger.debug "LDAP-Auth with User #{effective_user(login)}"
    # first, search for User Entries in LDAP
    entry = search_for_user_entries(login, password)
    return nil unless entry.is_a?(Net::LDAP::Entry)

    # extract required attributes
    attrs = required_attributes_values(entry)

    # not sure if there is a case were search result without a DN
    # but just to be on the safe side.
    if (dn=attrs.delete(:dn)).empty?
      logger.warn "no DN"
      return nil
    end

    logger.debug "DN found for #{login}: #{dn}"

    # finally, authenticate user
    ldap_con = initialize_ldap_con(dn, password)
    unless ldap_con.bind
      logger.warn "Result: #{ldap_con.get_operation_result.code}"
      logger.warn "Message: #{ldap_con.get_operation_result.message}"
      logger.warn "Failed to authenticate #{login}"
      return nil
    end
    # return user's attributes
    attrs
  rescue Net::LDAP::LdapError => text
    raise "LdapError: %s" % text
  end

  # test the connection to the LDAP
  def test_connection
    ldap_con = initialize_ldap_con(self.account, self.account_password)
    ldap_con.open { }
  rescue Net::LDAP::LdapError => text
    raise "LdapError: %s" % text
  end

  def auth_method_name
    "LDAP"
  end

  private

  def strip_ldap_attributes
    [:attr_login, :attr_firstname, :attr_lastname, :attr_mail].each do |attr|
      write_attribute(attr, read_attribute(attr).strip) unless read_attribute(attr).nil?
    end
  end

  def initialize_ldap_con(ldap_user, ldap_password)
    options = { :host       => host,
                :port       => port,
                :encryption => (tls ? :simple_tls : nil)
    }
    options.merge!(:auth => { :method => :simple, :username => ldap_user, :password => ldap_password }) unless ldap_user.blank? && ldap_password.blank?
    Net::LDAP.new options
  end

  def set_defaults
    self.port ||= 389
  end

  def use_user_login_for_auth?
    # returns true if account is defined and includes "$login"
    (account and account.include? "$login")
  end

  def effective_user(login)
    use_user_login_for_auth? ? account.sub("$login", login) : account
  end

  def required_ldap_attributes
    return {:dn => :dn} unless onthefly_register?
    { :firstname => attr_firstname,
      :lastname  => attr_lastname,
      :mail      => attr_mail,
      :dn        => :dn,
    }
  end

  def required_attributes_values entry
    Hash[required_ldap_attributes.map do |name, value|
      value = entry[value].is_a?(Array) ? entry[value].first : entry[value]
      [name, value.to_s]
    end]
  end

  def search_for_user_entries(login, password)
    user          = effective_user(login)
    pass          = use_user_login_for_auth? ? password : account_password
    ldap_con      = initialize_ldap_con(user, pass)
    login_filter  = Net::LDAP::Filter.eq(attr_login, login)
    object_filter = Net::LDAP::Filter.eq("objectClass", "*")

    # search for a match for our authenticating user.
    entries       = ldap_con.search(:base       => base_dn,
                                    :filter     => object_filter & login_filter,
                                    # only ask for the DN if on-the-fly registration is disabled
                                    :attributes => required_ldap_attributes.values)
    unless ldap_con.get_operation_result.code == 0
      logger.warn "Search Result: #{ldap_con.get_operation_result.code}"
      logger.warn "Search Message: #{ldap_con.get_operation_result.message}"
    end

    # we really care about one match, using the last one, hoping there is only one match :)
    entries ? entries.last : nil
  end

end
