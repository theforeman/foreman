require 'uri'
require 'net/http'
require 'json'

module Updates
  class Base
    attr_reader :cache_duration

    def initialize(opts = {})
      @cache_duration = opts[:cache_duration] || 2.hours
    end

    def url
      raise NotImplementedError, "Method 'url' needs to be implemented"
    end

    def file_name
      raise NotImplementedError, "Method 'file_name' needs to be implemented"
    end

    def humanized_name
      self.class.name.underscore
    end

    def fetch_from_file
      if Setting[:foreman_updates_override].present?
        begin
          file_path = File.join(Setting[:foreman_updates_override], file_name)
          File.open(file_path, "r") do |file|
            JSON.parse(file.read)
          end
        rescue => e
          Rails.logger.warn "Failed to read from #{file_path}: #{e.message}"
          {}
        end
      else
        {}
      end
    end

    def fetch_from_web
      if Setting[:foreman_updates]
        Rails.cache.fetch(humanized_name, :expires_in => cache_duration) do
          uri = URI.parse url
          request = Net::HTTP::Get.new(uri.request_uri)
          request['Content-Type'] = 'application/json'
          begin
            result = Net::Http.start(uri.host, uri.port, :read_timeout => 1000) { |http| http.request(request) }
            result.value
          rescue => e
            Rails.logger.warn "Could not retrieve latest releases from #{url}. Cause: #{e.message}"
            return {}
          end
          JSON.parse(result.body)
        end
      else
        {}
      end
    end

    def fetch
      from_file = fetch_from_file
      return from_file unless from_file.empty?
      fetch_from_web
    end
  end
end
