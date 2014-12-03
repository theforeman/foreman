class NoWhitespaceValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add(attribute, _("can't contain white spaces.")) if value =~ /\s/
  end
end
