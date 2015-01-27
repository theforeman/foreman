class AlphanumericValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add(attribute, _("is alphanumeric and cannot contain spaces")) unless value =~ /\A\w+\Z/
  end
end
