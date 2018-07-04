module MediumProviders
  # This is a base class for medium providers.
  # Medium provider is responsible to provide location of installation medium for a given entity
  # Example:
  # provider = MyMediumProvider.new(centos_host)
  # provider.medium_uri
  # => #<URI::HTTP http://mirror.centos.org/centos/7/os/x86_64>
  class Provider
    # Provides a friendly name of the provider in case of provider error.
    def self.friendly_name
      self.name
    end

    class Jail < Safemode::Jail
      allow :medium_uri, :unique_id, :errors
    end

    def initialize(entity)
      @entity = entity
    end

    # Returns URI of the installation medium for the current host.
    def medium_uri
      throw "medium_uri is not implemented for #{self.class.name}"
    end

    # Returns unique string representing current installation medium.
    def unique_id
      @unique_id ||= Base64.urlsafe_encode64(Digest::SHA1.digest(medium_uri.to_s), padding: false)
    end

    def valid?
      errors.empty?
    end

    def errors
      @errors ||= validate
    end

    # This method is used to determine whether this provider can handle the entity or not.
    # This method uses rails pattern for validation - it adds errors to #errors property
    # Example:
    # def validate
    #   errors << "Can't handle entity without medium" unless entity.respond_to?(:medium)
    # end
    def validate
      raise "validate is not implemented for #{self.class.name}"
    end

    private

    attr_reader :entity
  end
end
