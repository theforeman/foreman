module MediumProviders
  class Default < Provider
    def validate
      errors = []
      os = entity.try(:operatingsystem)
      medium = entity.try(:medium)
      arch = entity.try(:architecture)

      errors << N_("Operating system was not set for host '%{host}'") % { :host => entity } if os.nil?
      errors << N_("%{os} medium was not set for host '%{host}'") % { :host => entity, :os => os } if medium.nil?
      errors << N_("Invalid medium '%{medium}' for '%{os}'") % { :medium => medium, :os => os } unless os&.media&.include?(medium)
      errors << N_("Invalid architecture '%{arch}' for '%{os}'") % { :arch => arch, :os => os } unless os&.architectures&.include?(arch)
      errors
    end

    def medium_uri(path = "", &block)
      url ||= entity.medium.path if entity.medium.present?
      url ||= ''
      url += '/' + path unless path.empty?
      medium_vars_to_uri(url, entity.architecture.name, entity.operatingsystem, &block)
    end

    def interpolate_vars(pattern)
      medium_vars_to_uri(pattern, entity.architecture.name, entity.operatingsystem)
    end

    def unique_id
      @unique_id ||= begin
        digest = Base64.urlsafe_encode64(Digest::SHA1.digest(medium_uri(entity.operatingsystem.pxedir(self)).to_s + entity.operatingsystem.major + entity.operatingsystem.minor), padding: false)
        # return first 12 characters of encoded digest stripped down of non-alphanums for better readability
        "#{entity.medium.name.parameterize}-#{digest.gsub(/[-_]/, '')[1..12]}"
      end
    end

    def valid?
      entity.respond_to?(:medium) && errors.empty?
    end

    private

    def medium_vars_to_uri(url, arch, os, &block)
      URI.parse(interpolate_medium_vars(url, arch, os, &block)).normalize
    end

    def interpolate_medium_vars(path, arch, os)
      return "" if path.empty?

      path = path.gsub('$arch', '%{arch}').
                  gsub('$major',  '%{major}').
                  gsub('$minor',  '%{minor}').
                  gsub('$version', '%{version}').
                  gsub('$release', '%{release}')

      vars = medium_vars(arch, os)
      if block_given?
        yield(vars)
      end

      path % vars
    end

    def medium_vars(arch, os)
      {
        arch: arch,
        major: os.major,
        minor: os.minor,
        version: os.minor.blank? ? os.major : [os.major, os.minor].compact.join('.'),
        release: os.release_name.presence || '',
      }
    end
  end
end
