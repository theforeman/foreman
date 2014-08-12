#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

class AuthorizeAssociationsValidator < ActiveModel::Validator

  def validate(record)
    if record.class.respond_to?(:reflect_on_all_associations)
      exemptions = if record.respond_to?(:association_authorization_overrides)
                     record.association_authorization_overrides
                   else
                     {}
                   end

      record.class.reflect_on_all_associations.each do |association|

        if check_authorization?(record, association, exemptions)

          permission = exemptions[association.name] || "view_#{association.klass.name.downcase.pluralize}"
          check_association(record, association, permission)

        end
      end
    end
  end

  def check_association(record, association, permission)
    if association.macro.to_sym == :has_many
      has_many_authorized?(record, association, permission)
    elsif association.macro.to_sym == :belongs_to
      belongs_to_authorized?(record, association, permission)
    end
  end

  def belongs_to_authorized?(record, association, permission)
    permitted = false
    name = association.name
    association_record = record.send(name)
    return true if association_record.nil?

    if organization?(name)
      permitted = user.allowed_organizations.include?(association_record)
    elsif location?(name)
      permitted = user.allowed_locations.include?(association_record)
    else
      permitted = association_record.authorized?(permission)
    end

    add_error(record, name, association_record) if !permitted
  end

  def has_many_authorized?(record, association, permission)
    permitted = []
    name = association.name
    association_record = record.send(name)

    if organization?(name)
      permitted = user.allowed_organizations
    elsif location?(name)
      permitted = user.allowed_locations
    else
      permitted = association.klass.authorized(permission)
    end

    permitted = association_record - permitted
    add_error(record, name, permitted) if !permitted.empty?
  end

  def add_error(record, association_name, unauthorized)
    if unauthorized.is_a?(Array)
      message = "not found for ids '#{unauthorized.map(&:id)}'"
    else
      message = "not found by id '#{unauthorized.id}'"
    end

    record.errors[association_name] << message
  end

  def user
    ::User.current
  end

  def location?(association_name)
    association_name.to_s.singularize == 'location'
  end

  def organization?(association_name)
    association_name.to_s.singularize == 'organization'
  end

  def check_authorization?(record, association, exemptions)
    klass = association.options.include?(:polymorphic) ? record.send(association.foreign_type) : association.klass
    !exemptions[association.name] &&
      klass &&
      klass.respond_to?(:authorized) &&
      association.name != 'taxonomies'
  end

end
