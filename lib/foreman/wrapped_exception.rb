module Foreman

  class WrappedException < ::Foreman::Exception
    def initialize exception, message, *params
      super(message, *params)
      @exception = exception
    end

    def wrapped_exception
      @exception
    end

    def message
      if @exception.nil?
        wrapped = ""
      else
        wrapped = " (#{@exception.class.name} - #{@exception.message})"
      end
      "#{code}: #{@message}#{wrapped}"
    end
  end

end
