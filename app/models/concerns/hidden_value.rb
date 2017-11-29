module HiddenValue
  extend ActiveSupport::Concern

  HIDDEN_VALUE = "*" * 5

  def safe_value
    self.hidden_value? ? HIDDEN_VALUE : self.value_before_type_cast
  end

  def hidden_value
    HIDDEN_VALUE
  end
end
