module HiddenValue
  extend ActiveSupport::Concern

  HIDDEN_VALUE = "*" * 5

  def safe_value
    hidden_value? ? HIDDEN_VALUE : value
  end

  def hidden_value
    HIDDEN_VALUE
  end
end
