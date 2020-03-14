module StripWhitespace
  extend ActiveSupport::Concern

  included do
    before_validation :strip_spaces
  end

  def strip_spaces
    changes.each do |column, values|
      self[column] = self[column].strip if (self[column].is_a?(String) && !skip_strip_attrs.include?(column))
    end
  end

  # default empty array - overwrite in each model for specific string fields that should not be .strip!
  def skip_strip_attrs
    []
  end
end
