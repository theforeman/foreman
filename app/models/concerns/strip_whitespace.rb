module StripWhitespace
  extend ActiveSupport::Concern

  included do
    before_save :strip_name
  end

  def strip_name
    self.name.strip! if self.class.column_names.include?('name')
  end

end
