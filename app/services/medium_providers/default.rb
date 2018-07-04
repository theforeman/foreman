module MediumProviders
  class Default < Provider
    def validate
      errors = []
      os = entity.operatingsystem
      medium = entity.medium
      arch = entity.architecture

      errors << N_("%{os} medium was not set for host '%{host}'") % { :host => entity, :os => os } if medium.nil?
      errors << N_("Invalid medium '%{medium}' for '%{os}'") % { :medium => medium, :os => os } unless os.media.include?(medium)
      errors << N_("Invalid architecture '%{arch}' for '%{os}'") % { :arch => arch, :os => os } unless os.architectures.include?(arch)
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
        full_uniq = super
        "#{entity.medium.name.parameterize}-#{full_uniq[1..10]}"
      end
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
        release: os.release_name.presence || ''
      }
    end
  end
end
