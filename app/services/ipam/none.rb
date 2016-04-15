module IPAM
  class None < Base
    def suggest_ip
      logger.debug "Not suggesting IP Address for #{subnet} as IPAM is disabled"
      nil
    end

    def suggest_new?
      false
    end
  end
end
