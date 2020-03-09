module Foreman
  class Deprecation
    # deadline_version - is the version the deprecation is going to be deleted, the format must be a major release e.g "1.8"
    def self.deprecation_warning(foreman_version_deadline, info)
      check_version_format foreman_version_deadline
      ActiveSupport::Deprecation.warn("You are using a deprecated behavior, it will be removed in version #{foreman_version_deadline}, #{info}", caller(2))
    end

    def self.check_version_format(foreman_version_deadline)
      raise Foreman::Exception.new(N_("Invalid version format, please enter in x.y (only major version).")) unless foreman_version_deadline.to_s =~ /\A\d[.]\d+\z/
    end

    def self.api_deprecation_warning(info)
      Foreman::Logging.logger('api_deprecations').warn(info)
    end

    def self.renderer_deprecation(foreman_version_deadline, method, new_method)
      check_version_format foreman_version_deadline
      called_from_params = false
      caller.each_with_index do |item, index|
        called_from_params = true if item =~ /host_params\.rb.*params/
        return if called_from_params && item.match(/host_info_extensions\.rb.*info/)
        next unless item =~ /renderer\.rb.*render_safe/
        Rails.logger.warn "DEPRECATION WARNING: you are using deprecated @host.#{method} in a template, it will be removed in #{foreman_version_deadline}. Use #{new_method} instead."
        return
      end
    end
  end
end
