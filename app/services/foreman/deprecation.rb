module Foreman
  class Deprecation
    #deadline_version - is the version the deprecation is going to be deleted, the format must be a major release e.g "1.8"
    def self.deprecation_warning(foreman_version_deadline, info)
      raise Foreman::Exception.new(N_("Invalid version format, please enter in x.y (only major version).")) unless foreman_version_deadline.to_s.match(/\A\d[.]\d+\z/)
      ActiveSupport::Deprecation.warn("You are using a deprecated behavior, it will be removed in version #{foreman_version_deadline}, #{info}", caller(2))
    end

    def self.api_deprecation_warning(info)
      ActiveSupport::Deprecation.warn("Your API call uses deprecated behavior, #{info}", caller)
    end
  end
end
