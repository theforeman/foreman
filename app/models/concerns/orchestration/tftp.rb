module Orchestration::TFTP
  extend ActiveSupport::Concern

  included do
    after_validation :validate_tftp, :queue_tftp
    before_destroy :queue_tftp_destroy

    # required for pxe template url helpers
    include Rails.application.routes.url_helpers
  end

  def tftp?
    provision? && !!(subnet && subnet.tftp?) && host.managed? && (host.operatingsystem && host.operatingsystem.pxe_variant) && managed? && pxe_build?
  end

  def tftp
    subnet.tftp_proxy(:variant => host.operatingsystem.pxe_variant) if tftp?
  end

  protected

  # Adds the host to the forward and reverse TFTP zones
  # +returns+ : Boolean true on success
  def setTFTP
    logger.info "Add the TFTP configuration for #{host.name}"
    tftp.set mac, :pxeconfig => generate_pxe_template
  end

  # Removes the host from the forward and reverse TFTP zones
  # +returns+ : Boolean true on success
  def delTFTP
    logger.info "Delete the TFTP configuration for #{host.name}"
    tftp.delete mac
  end

  def setTFTPBootFiles
    logger.info "Fetching required TFTP boot files for #{host.name}"
    valid = true
    host.operatingsystem.pxe_files(host.medium, host.architecture, self).each do |bootfile_info|
      for prefix, path in bootfile_info do
        valid = false unless tftp.fetch_boot_file(:prefix => prefix.to_s, :path => path)
      end
    end
    failure _("Failed to fetch boot files") unless valid
    valid
  end

  #empty method for rollbacks
  def delTFTPBootFiles
  end

  private

  def validate_tftp
    return unless tftp?
    return unless host.operatingsystem
    return if Rails.env == "test"
    if host.configTemplate({:kind => host.operatingsystem.template_kind}).nil? && host.configTemplate({:kind => "iPXE"}).nil?
      failure _("No %{template_kind} templates were found for this host, make sure you define at least one in your %{os} settings") %
                { :template_kind => host.operatingsystem.template_kind, :os => host.os }
    end
  end

  def generate_pxe_template
    # this is the only place we generate a template not via a web request
    # therefore some workaround is required to "render" the template.
    @kernel = host.os.kernel(host.arch)
    @initrd = host.os.initrd(host.arch)
    # work around for ensuring that people can use @host as well, as tftp templates were usually confusing.
    @host = self.host
    if build?
      pxe_render host.configTemplate({:kind => host.os.template_kind})
    else
      if host.os.template_kind == "PXEGrub"
        pxe_render ConfigTemplate.find_by_name("PXEGrub default local boot")
      else
        pxe_render ConfigTemplate.find_by_name("PXELinux default local boot")
      end
    end
  rescue => e
    failure _("Failed to generate %{template_kind} template: %{e}") % { :template_kind => host.os.template_kind, :e => e }
  end

  def queue_tftp
    return unless tftp? && no_errors
    # Jumpstart builds require only minimal tftp services. They do require a tftp object to query for the boot_server.
    return true if host.jumpstart?
    new_record? ? queue_tftp_create : queue_tftp_update
  end

  def queue_tftp_create
    queue.create(:name => _("TFTP Settings for %s") % self, :priority => 20,
                 :action => [self, :setTFTP])
    return unless build
    queue.create(:name => _("Fetch TFTP boot files for %s") % self, :priority => 25,
                 :action => [self, :setTFTPBootFiles])
  end

  def queue_tftp_update
    set_tftp = false
    # we switched build mode
    set_tftp = true if old.host.build? != host.build?
    # medium or arch changed
    set_tftp = true if old.host.medium.try(:id) != host.medium.try(:id) or old.host.arch.try(:id) != host.arch.try(:id)
    # operating system changed
    set_tftp = true if host.os and old.host.os and (old.host.os.name != host.os.name or old.host.os.try(:id) != host.os.try(:id))
    # MAC address changed
    if mac != old.mac
      set_tftp = true
      # clean up old TFTP reservation file
      if old.tftp?
        queue.create(:name => _("Remove old TFTP Settings for %s") % old, :priority => 19,
                     :action => [old, :delTFTP])
      end
    end
    queue_tftp_create  if set_tftp
  end

  def queue_tftp_destroy
    return unless tftp? && no_errors
    return true if host.jumpstart?
    queue.create(:name => _("TFTP Settings for %s") % self, :priority => 20,
                 :action => [self, :delTFTP])
  end

  def no_errors
    errors.empty? && host.errors.empty?
  end

end
