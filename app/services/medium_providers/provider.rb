module MediumProviders
  # This is a base class for medium providers.
  # Medium provider is responsible to provide location of installation medium for a given entity
  # Example:
  # provider = MyMediumProvider.new(centos_host)
  # provider.medium_uri
  # => #<URI::HTTP http://mirror.centos.org/centos/7/os/x86_64>
  class Provider
    delegate :logger, :to => :Rails

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

    # A medium provider can optionally return an array of hashes for additional
    # software repos to enable during installation, if the template supports
    # it.  The default implemenation looks at host parameters. The hash keys:
    #
    #   name:    Repo name, no spaces
    #   comment: Repo comment
    #   url:     Repo URL
    #   gpgkey:  GPG key URL
    #   install: Install repo on system for after boot
    #
    def additional_media
      return [] unless entity.respond_to?(:host_param) && (media = entity.host_param('additional_media'))
      parse_media(media) || []
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

    def parse_media(media)
      media = JSON.parse(media)
      if media.is_a?(Array)
        media.reject { |medium| is_invalid_hash(medium) }
      else
        logger.error("Expected #{entity.name} additional_media parameter to be an array.")
	[]
      end
    rescue JSON::ParserError
      logger.error("JSON parsing error on #{entity.name}'s additional_media parameter.")
      []
    end

    def is_invalid_hash(medium)
      return false unless medium['name'].blank? || medium['url'].blank?
      logger.error("Medium #{medium} missing name.") if medium['name'].blank?
      logger.error("Medium #{medium} missing URL.") if medium['url'].blank?
      true
    end

    attr_reader :entity
  end
end
