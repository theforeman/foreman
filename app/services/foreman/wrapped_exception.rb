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
      super unless @wrapped_exception.present?

      cls = @wrapped_exception.class.name
      msg = @wrapped_exception.message
      super + " ([#{cls}]: #{msg})"
    end
  end
end
