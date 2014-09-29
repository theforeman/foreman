class OrganizationAssociationValidator < ActiveModel::Validator

  def validate(record)
    if record.class.respond_to?(:reflect_on_all_associations) && belongs_to_organization?(record)
      record.class.reflect_on_all_associations.each do |association|

        if (association_record = record.send(association.name))
          if belongs_to_organization?(association_record)

            association_records = association_record.is_a?(Array) ? association_record : [association_record]
            association_records.each do |association_rec|
              check_belongs_to(record, association_rec)
            end

          elsif has_many_organizations?(association_record)

            add_error(record, association_record) if !organizations(association_record).include?(record.organization)

          end
        end

      end
    end
  end

  def check_belongs_to(record, association_record)

    if belongs_to_organization?(record)
      add_error(record, association_record) if record.organization != association_record.organization
    elsif has_many_organizations?(record)
      add_error(record, association_record) if organizations(record).include?(association_record.organization)
    end

  end

  def class_name(record)
    record.class.name.split('::').last
  end

  def add_error(record, association_record)
    message = _("#{class_name(record)} and #{class_name(association_record)} '#{association_record.id}' do not belong to the same organization and cannot be associated")
    message = record.errors[:base] << message
  end

  def belongs_to_organization?(record)
    record = record.first if record.is_a?(Array)
    defined?(record.class) && record.class.respond_to?(:reflect_on_association) && record.class.reflect_on_association(:organization)
  end

  def has_many_organizations?(record)
    record = record.first if record.is_a?(Array)
    defined?(record.class) && record.class.respond_to?(:reflect_on_association) && record.class.reflect_on_association(:organizations)
  end

  def organizations(association_record)
    if association_record.class == User
      association_record.allowed_organizations
    else
      association_record.organizations
    end
  end

end
