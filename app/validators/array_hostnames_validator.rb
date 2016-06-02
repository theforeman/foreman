class ArrayHostnamesValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add attribute, _("must contain valid hostnames") unless value.all? { |item| item.to_s.match URI::HOST }
  end
end
