module Foreman::Controller::Flash
  extend ActiveSupport::Concern

  included do
    add_flash_types :inline, :success, :info, :warning, :error

    def success(message, options = default_flash_options)
      flash_message(:success, message, options)
    end

    def inline_success(message, now = false)
      inline_flash_message(:success, message, now)
    end

    def info(message, options = default_flash_options)
      flash_message(:info, message, options)
    end

    def inline_info(message, now = false)
      inline_flash_message(:info, message, now)
    end

    def warning(message, options = default_flash_options)
      flash_message(:warning, message, options)
    end

    def inline_warning(message, now = false)
      inline_flash_message(:warning, message, now)
    end

    def error(message, options = default_flash_options)
      flash_message(:error, message, options)
    end

    def inline_error(message, now = false)
      inline_flash_message(:error, message, now)
    end
  end

  private

  def default_flash_options
    @default_flash_options ||= { :now => false, :link => nil }
  end

  def inline_flash_message(type, message, now = false)
    flash_data = { type => CGI.escapeHTML(message) }

    if now
      flash.now[:inline] ||= {}
      flash.now[:inline] = flash_data
    else
      flash[:inline] ||= {}
      flash[:inline] = flash_data
    end
  end

  def flash_message(type, message, options = default_flash_options)
    # backward compatibility, so old code can still run
    # `error('some message', true)` instead of migrate to
    # `error('some message', { :now => true })`
    options = { now: true, link: nil } if options.is_a?(TrueClass)

    if options[:link].nil?
      flash_data = message
    else
      flash_data = { type: type, message: CGI.escapeHTML(message), link: options[:link] }
    end

    if options[:now]
      flash.now[type] = flash_data
    else
      flash[type] = flash_data
    end
  end
end
