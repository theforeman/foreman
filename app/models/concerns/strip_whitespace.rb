module StripWhitespace
  extend ActiveSupport::Concern

  included do
    before_validation :strip_spaces
  end

  def strip_spaces
    self.changes.each do |column, values|
      # return string if RuntimeError: can't modify frozen String
      self.send(column).strip! if (values.last.is_a?(String) && !skip_strip_attrs.include?(column)) rescue send(column)
    end
  end

  # default empty array - overwrite in each model for specific string fields that should not be .strip!
  def skip_strip_attrs
    []
  end
end
