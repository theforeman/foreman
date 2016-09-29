class ArrayTypeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add attribute, _("must be comma separated") unless Array(value).map { |item| item.to_s.match /\A\S+\z/ }.all?
  end
end
