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

    def last_modified_id
      hash_source = []
      entity.operatingsystem.boot_files_uri(self).each do |url|
        fetch_headers_url(url, 5, hash_source)
      end
      hash_source.first
    end

    def fetch_headers_url(url, limit, result)
      raise "maximum redirection hit" if limit <= 0
      logger.debug "Performing HTTP HEAD #{url}"
      uri = URI(url)
      Net::HTTP.start(uri.host, uri.port) do |http|
        http.open_timeout = 5
        http.read_timeout = 5
        response = http.head(uri.path)
        ['last-modified', 'etag'].each do |header|
          result << response[header] if response[header]
        end
        if response.code =~ /301|302/
          fetch_headers_url(response['location'], limit - 1, result)
        elsif response.code != '200'
          raise "server returned #{response.code}"
        end
      end
    rescue => e
      raise ::Foreman::WrappedException.new(e, N_("Check media URL, unable to perform HTTP HEAD for %s"), url)
    end

    def format_unique_id(input)
      digest = Base64.urlsafe_encode64(Digest::SHA1.digest(input), padding: false)
      # return first 8 characters of encoded digest stripped down of non-alphanums for better readability
      "#{entity.medium.name.parameterize}-#{digest.gsub(/[-_]/, '')[0..7]}"
    end

    # filename-friendly formatted hash of either last-modified, etag or URL
    def unique_id
      @unique_id ||= begin
        source = last_modified_id
        source ||= medium_uri(entity.operatingsystem.pxedir).to_s
        format_unique_id(source)
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
        release: os.release_name.presence || ''
      }
    end
  end
end
