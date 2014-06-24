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

class AuthSourceLdap < AuthSource
  validates :host, :presence => true, :length => {:maximum => 60}, :allow_nil => true
  validates :attr_login, :attr_firstname, :attr_lastname, :attr_mail, :presence => true, :if => Proc.new { |auth| auth.onthefly_register? }
  validates :attr_login, :attr_firstname, :attr_lastname, :attr_mail, :length => {:maximum => 30}, :allow_nil => true
  validates :name, :account_password, :length => {:maximum => 60}, :allow_nil => true
  validates :account, :base_dn, :ldap_filter, :length => {:maximum => 255}, :allow_nil => true
  validates :port, :presence => true, :numericality => {:only_integer => true}
  validate :validate_ldap_filter, :unless => Proc.new { |auth| auth.ldap_filter.blank? }

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

    # extract attributes
    attrs = attributes_values(entry)

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
    logger.debug "Retrieved LDAP Attributes for #{login}: #{attrs}"
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

  def optional_ldap_attributes
    { :avatar => attr_photo }
  end

  def attributes_values entry
    Hash[required_ldap_attributes.merge(optional_ldap_attributes).map do |name, value|
      next if value.blank? || (entry[value].blank? && optional_ldap_attributes.keys.include?(name))
      if name.eql? :avatar
        [:avatar_hash, store_avatar(entry[value].first)]
      else
        value = entry[value].is_a?(Array) ? entry[value].first : entry[value]
        [name, value.to_s]
      end
    end]
  end

  def store_avatar avatar
    avatar_path = "#{Rails.public_path}/assets/avatars"
    avatar_hash = Digest::SHA1.hexdigest(avatar)
    avatar_file = "#{avatar_path}/#{avatar_hash}.jpg"
    unless FileTest.exist? avatar_file
      FileUtils.mkdir_p(avatar_path)
      File.open(avatar_file, 'w') { |f| f.write(avatar) }
    end
    avatar_hash
  end
 
  def validate_ldap_filter
    Net::LDAP::Filter.construct(ldap_filter)
  rescue Net::LDAP::LdapError => text
    errors.add(:ldap_filter, _("invalid LDAP filter syntax"))
  end

  def search_for_user_entries(login, password)
    user          = effective_user(login)
    pass          = use_user_login_for_auth? ? password : account_password
    ldap_con      = initialize_ldap_con(user, pass)
    login_filter  = Net::LDAP::Filter.eq(attr_login, login)
    object_filter = Net::LDAP::Filter.eq("objectClass", "*")
    object_filter = object_filter & Net::LDAP::Filter.construct(ldap_filter) unless ldap_filter.blank?

    # search for a match for our authenticating user.
    entries       = ldap_con.search(:base       => base_dn,
                                    :filter     => object_filter & login_filter,
                                    # only ask for the DN if on-the-fly registration is disabled
                                    :attributes => required_ldap_attributes.values + optional_ldap_attributes.values)
    unless ldap_con.get_operation_result.code == 0
      logger.warn "Search Result: #{ldap_con.get_operation_result.code}"
      logger.warn "Search Message: #{ldap_con.get_operation_result.message}"
    end

    # we really care about one match, using the last one, hoping there is only one match :)
    entries ? entries.last : nil
  end

end
