class RegexpValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add attribute, _("must be a valid regexp") unless (Regexp.new(value) rescue nil)
  end
end
