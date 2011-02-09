module Orchestration::TFTP
  def self.included(base)
    base.send :include, InstanceMethods
    base.class_eval do
      attr_reader :tftp
      attr_accessor :request_url
      after_validation :initialize_tftp, :validate_tftp, :queue_tftp
      before_destroy :initialize_tftp, :queue_tftp_destroy

      # required for pxe template url helpers
      include ActionController::UrlWriter
    end
  end

  module InstanceMethods

    def tftp?
      !subnet.nil? and !subnet.tftp.nil? and !subnet.tftp.url.empty?
    end

    protected
    def initialize_tftp
      return unless tftp?
      @tftp = ProxyAPI::TFTP.new :url => subnet.tftp.url
    rescue => e
      failure "Failed to initialize the TFTP proxy: #{e}"
    end

    # Adds the host to the forward and reverse TFTP zones
    # +returns+ : Boolean true on success
    def setTFTP
      logger.info "Add the TFTP configuration for #{name}"
      tftp.set mac, :syslinux_config => generate_pxe_template
    rescue => e
      failure "Failed to set TFTP: #{proxy_error e}"
    end

    # Removes the host from the forward and reverse TFTP zones
    # +returns+ : Boolean true on success
    def delTFTP
      logger.info "Delete the TFTP configuration for #{name}"
      tftp.delete mac
    rescue => e
      failure "Failed to delete TFTP: #{proxy_error e}"
    end

    def setTFTPBootFiles
      logger.info "Fetching required TFTP boot files for #{name}"
      valid = true
      operatingsystem.pxe_files(medium, architecture).each do |bootfile_info|
        for prefix, path in bootfile_info do
          valid = false unless tftp.fetch_boot_file(:prefix => prefix.to_s, :path => path)
        end
      end
      failure "Failed to fetch boot files" unless valid
      valid
    rescue => e
      failure "Failed to fetch boot files: #{proxy_error e}"
    end

    #empty method for rollbacks
    def delTFTPBootFiles
    end

    private

    def validate_tftp
      return unless tftp?
      return if Rails.env == "test"
      if configTemplate("PXELinux").nil?
        failure "No PXELinux templates where found for this host, make sure you define at least one in your #{os} settings"
      end
    end

    def generate_pxe_template
      # this is the only place we generate a template not via a web request
      # therefore some workaround is required to "render" the template.

      prefix   = operatingsystem.pxe_prefix(arch)
      pxefiles = eval "#{os.family}::PXEFILES"
      @kernel  = "#{prefix}-#{pxefiles[:kernel]}"
      @initrd  = "#{prefix}-#{pxefiles[:initrd]}"
      pxe      = configTemplate("PXELinux").template
      ERB.new(pxe).result(binding)
    rescue => e
      failure "Failed to generate PXELinux template: #{e}"
    end

    #returns the URL for Foreman based on the required action
    def foreman_url(action = "provision")
      url_for :only_path => false, :controller => "unattended", :action => action, :host => request_url
    end

    def queue_tftp
      return unless tftp? and errors.empty?
      new_record? ? queue_tftp_create : queue_tftp_update
    end

    def queue_tftp_create
      return unless build
      queue.create(:name => "TFTP Settings for #{self}", :priority => 20,
                   :action => [self, :setTFTP])
      queue.create(:name => "Fetch TFTP boot files for #{self}", :priority => 25,
                   :action => [self, :setTFTPBootFiles])
    end

    def queue_tftp_update
      set_tftp = false
      set_tftp = true if (build == true and old.build == false)
      if set_tftp == false and old
        set_tftp = true if old.medium != medium or old.arch != arch
        set_tftp = true if os and old.os and (old.os.name != os.name or old.os != os)
      end unless
      queue_tftp_create if set_tftp
      if build == false and old.build == true
        queue_tftp_destroy
      end
    end

    def queue_tftp_destroy
      return unless tftp? and errors.empty?
      queue.create(:name => "TFTP Settings for #{self}", :priority => 20,
                   :action => [self, :delTFTP])
    end

  end
end
