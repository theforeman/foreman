module ComputeResourceConsoleCommon
  extend ActiveSupport::Concern

  def set_console_password?
    !(attrs[:setpw] == 0) # return true unless attrs[:setpw] is set to 0
  end
  alias_method :set_console_password, :set_console_password?

  def set_console_password=(setpw)
    if ['true', true, '1', 1].include?(setpw)
      attrs[:setpw] = 1
    else
      attrs[:setpw] = 0
    end
  end

  def name_sort(array)
    array.sort_by { |a| a.name }
  end
end
