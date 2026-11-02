require 'digest'

module Hosts
  class BulkScopeHash
    def self.for_current_viewer
      new(
        user: User.current,
        organization: Organization.current,
        location: Location.current
      ).to_s
    end

    def initialize(user:, organization:, location:)
      @user = user
      @organization = organization
      @location = location
    end

    def to_s
      digest = Digest::SHA256.new
      digest << "user:#{@user&.id}|org:#{@organization&.id}|loc:#{@location&.id}|"

      hosts_scope.pluck(:id).each { |id| digest << "#{id}," }

      digest.hexdigest
    end

    private

    def hosts_scope
      ::Host::Managed.authorized(:view_hosts).reselect(:id).reorder(:id)
    end
  end
end
