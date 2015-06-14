module Foreman
  class Deprecation
    #deadline_version - is the version the deprecation is going to be deleted, the format must be a major release e.g "1.8"
    def self.deprecation_warning(foreman_version_deadline, info, callstack = nil)
      raise Foreman::Exception.new(N_("Invalid version format, please enter in x.y (only major version).")) unless foreman_version_deadline.to_s.match(/\A\d[.]\d+\z/)
      callstack ||= caller
      ActiveSupport::Deprecation.warn("You are using a deprecated behavior, on version #{foreman_version_deadline} it will be removed, #{info}", callstack)
    end
  end
end
