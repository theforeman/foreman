module Foreman

  class WrappedException < ::Foreman::Exception
    def initialize(wrapped_exception, message, *params)
      super(message, *params)
      @wrapped_exception = wrapped_exception
    end

    def wrapped_exception
      @wrapped_exception
    end

    def message
      if @wrapped_exception.nil?
        wrapped = ""
        super
      else
        cls = @wrapped_exception.class.name
        msg = @wrapped_exception.message.try(:truncate, 90)
        super + " ([#{cls}]: #{msg})"
      end
    end
  end

end
