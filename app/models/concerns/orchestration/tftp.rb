module Orchestration::TFTP
  extend ActiveSupport::Concern

  included do
    after_validation :validate_tftp, :unless => :skip_orchestration?
    after_validation :queue_tftp
    before_destroy :queue_tftp_destroy

    # required for pxe template url helpers
    include Rails.application.routes.url_helpers
    register_rebuild(:rebuild_tftp, N_('TFTP'))
  end

  def tftp?
    # host.managed? and managed? should always come first so that orchestration doesn't even get tested for such objects
    (host.nil? || host.managed?) && managed && provision? && !!(subnet && subnet.tftp?) && (host && host.operatingsystem && host.pxe_loader.present?) && pxe_build? && SETTINGS[:unattended]
  end

  def tftp
    subnet.tftp_proxy if tftp?
  end

  def rebuild_tftp
    if tftp?
      begin
        setTFTP
      rescue => e
        Foreman::Logging.exception "Failed to rebuild TFTP record for #{name}, #{ip}", e, :level => :error
        false
      end
    else
      logger.info "TFTP not supported for #{name}, #{ip}, skipping orchestration rebuild"
      true
    end
  end

  def generate_pxe_template(kind)
    # this is the only place we generate a template not via a web request
    # therefore some workaround is required to "render" the template.
    @kernel = host.operatingsystem.kernel(host.arch)
    @initrd = host.operatingsystem.initrd(host.arch)
    if host.operatingsystem.respond_to?(:mediumpath)
      @mediapath = host.operatingsystem.mediumpath(host)
    end

    # Xen requires additional boot files.
    if host.operatingsystem.respond_to?(:xen)
      @xen = host.operatingsystem.xen(host.arch)
    end

    # work around for ensuring that people can use @host as well, as tftp templates were usually confusing.
    @host = self.host

    return build_pxe_render(kind) if build?
    default_pxe_render(kind)
  end

  protected

  def build_pxe_render(kind)
    template = host.provisioning_template({:kind => kind})
    return unless template.present?
    unattended_render template
  rescue => e
    failure _("Unable to render %{kind} template '%{name}': %{e}") % { :kind => kind, :name => template.try(:name), :e => e }, e
  end

  def default_pxe_render(kind)
    template_name = "#{kind} default local boot"
    template = ProvisioningTemplate.find_by_name(template_name)
    raise Foreman::Exception.new(N_("Template '%s' was not found"), template_name) unless template
    unattended_render template, template_name
  rescue => e
    failure _("Unable to render '%{name}' template: %{e}") % { :name => template_name, :e => e }, e
  end

  # Adds the host to the forward and reverse TFTP zones
  # +returns+ : Boolean true on success
  def setTFTP(kind)
    content = generate_pxe_template(kind)
    if content
      logger.info "Deploying TFTP #{kind} configuration for #{host.name}"
      tftp.set kind, mac, :pxeconfig => content
    else
      logger.info "Skipping TFTP #{kind} configuration for #{host.name}"
      true
    end
  end

  # Removes the host from the forward and reverse TFTP zones
  # +returns+ : Boolean true on success
  def delTFTP(kind)
    logger.info "Delete the TFTP configuration for #{host.name}"
    tftp.delete kind, mac
  end

  def setTFTPBootFiles
    logger.info "Fetching required TFTP boot files for #{host.name}"
    valid = true
    host.operatingsystem.pxe_files(host.medium, host.architecture, host).each do |bootfile_info|
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
    pxe_kind = host.operatingsystem.pxe_loader_kind(host)
    if pxe_kind && host.provisioning_template({:kind => pxe_kind}).nil?
      failure _("No %{template_kind} templates were found for this host, make sure you define at least one in your %{os} settings or change PXE loader") %
        { :template_kind => pxe_kind, :os => host.operatingsystem }
    end
  end

  def queue_tftp
    return unless tftp? && no_errors
    # Jumpstart builds require only minimal tftp services. They do require a tftp object to query for the boot_server.
    return true if host.jumpstart?
    new_record? ? queue_tftp_create : queue_tftp_update
  end

  def queue_tftp_create
    host.operatingsystem.template_kinds.each do |kind|
      queue.create(:name => _("Deploy TFTP %{kind} config for %{host}") % {:kind => kind, :host => self}, :priority => 20, :action => [self, :setTFTP, kind])
    end
    return unless build
    queue.create(:name => _("Fetch TFTP boot files for %s") % self, :priority => 25, :action => [self, :setTFTPBootFiles])
  end

  def queue_tftp_update
    set_tftp = false
    # we switched build mode
    set_tftp = true if old.host.build? != host.build?
    # medium or arch changed
    set_tftp = true if old.host.medium.try(:id) != host.medium.try(:id) || old.host.arch.try(:id) != host.arch.try(:id)
    # operating system changed
    set_tftp = true if host.operatingsystem && old.host.operatingsystem && (old.host.operatingsystem.name != host.operatingsystem.name || old.host.operatingsystem.try(:id) != host.operatingsystem.try(:id))
    # MAC address changed
    if mac != old.mac
      set_tftp = true
      # clean up old TFTP reservation file
      queue_tftp_destroy(false, 19, old) if old.tftp?
    end
    queue_tftp_create if set_tftp
  end

  def queue_tftp_destroy(validate = true, priority = 20, host = self)
    if validate
      return unless tftp? && no_errors
      return true if host.jumpstart?
    end
    host.operatingsystem.template_kinds.each do |kind|
      queue.create(:name => _("Delete TFTP %{kind} config for %{host}") % {:kind => kind, :host => host}, :priority => priority, :action => [host, :delTFTP, kind])
    end
  end

  def no_errors
    errors.empty? && host.errors.empty?
  end
end
