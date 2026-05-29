class AlphanumericValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add(attribute, _("must only contain alphanumeric or underscore characters")) unless value.to_s =~ /\A\w+\Z/
  end
end
