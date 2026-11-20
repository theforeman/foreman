require 'digest/md5'

module Foreman
  class ActiveStorageMigrator
    def initialize(source:, destination:, apply: false, output: $stdout)
      source = source.to_s
      destination = destination.to_s
      raise ArgumentError, 'Source and destination must be different services' if source == destination

      @source = source
      @destination = destination
      @source_service = ActiveStorage::Blob.services.fetch(source)
      @destination_service = ActiveStorage::Blob.services.fetch(destination)
      @apply = apply
      @output = output
    end

    def run
      counts = { :planned => 0, :copied => 0, :skipped => 0, :failed => 0 }
      ActiveStorage::Blob.where(:service_name => @source).find_each do |blob|
        result = migrate(blob)
        counts[result] += 1
        @output.puts "Blob #{blob.id}: #{result}"
      rescue StandardError => error
        counts[:failed] += 1
        @output.puts "Blob #{blob.id}: failed (#{error.class})"
      end
      @output.puts counts.map { |name, count| "#{name}=#{count}" }.join(' ')
      counts
    end

    private

    def migrate(blob)
      blob.with_lock do
        return :skipped unless blob.service_name == @source
        raise ActiveStorage::FileNotFoundError unless @source_service.exist?(blob.key)
        return :planned unless @apply

        # Never overwrite an existing destination object. It may be a verified
        # copy left by an interrupted migration; verify it before reusing it.
        unless @destination_service.exist?(blob.key)
          blob.open do |file|
            @destination_service.upload(blob.key, file,
              :checksum => blob.checksum,
              :content_type => blob.content_type,
              :custom_metadata => blob.custom_metadata)
          end
        end
        verify(blob)
        blob.update!(:service_name => @destination)
        :copied
      end
    end

    def verify(blob)
      checksum = Digest::MD5.new
      byte_size = 0
      @destination_service.download(blob.key) do |chunk|
        checksum.update(chunk)
        byte_size += chunk.bytesize
      end
      unless checksum.base64digest == blob.checksum && byte_size == blob.byte_size
        raise ActiveStorage::IntegrityError
      end
    end
  end
end
