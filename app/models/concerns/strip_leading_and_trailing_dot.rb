module StripLeadingAndTrailingDot
  extend ActiveSupport::Concern

  # Strips leading and trailing dots from attributes
  #
  # using <tt>StripLeadingAndTrailingDot</tt> to strip the leading and trailing dots in +Domain+:
  #
  #  class Domain
  #     include StripLeadingAndTrailingDot
  #
  #     def dot_strip_attrs
  #     ['name']
  #     end
  #  end
  #
  # Saving a +Domain+ with the name <tt>'.foo.'</tt> saves it as <tt>'foo'</tt>

  included do
    before_validation :strip_dots
  end

  def strip_dots
    changes.each do |column, values|
      # return string if RuntimeError: can't modify frozen String
      if values.last.is_a?(String) && dot_strip_attrs.include?(column)
        send("#{column}=", values.last.gsub(/(^\.|\.$)/, '')) if respond_to?("#{column}=")
      end
    end
  end

  # default empty array - overwrite in each model for specific string fields that should have dots removed
  def dot_strip_attrs
    []
  end
end
