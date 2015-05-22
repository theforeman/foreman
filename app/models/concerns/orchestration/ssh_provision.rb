module Orchestration::SSHProvision
  extend ActiveSupport::Concern

  included do
    after_validation :validate_ssh_provisioning, :queue_ssh_provision
    attr_accessor :template_file, :client
  end

  def ssh_provision?
    compute_attributes.present? && image_build? && !image.try(:user_data)
  end

  protected

  def queue_ssh_provision
    return unless ssh_provision? and errors.empty?
    new_record? ? queue_ssh_provision_create : queue_ssh_provision_update
  end

  # I guess this is not going to happen on create as we might not have an ip address yet.
  def queue_ssh_provision_create
    post_queue.create(:name   => _("Prepare post installation script for %s") % self, :priority => 2000,
                 :action => [self, :setSSHProvisionScript])
    post_queue.create(:name   => _("Wait for %s to come online") % self, :priority => 2001,
                 :action => [self, :setSSHWaitForResponse])
    post_queue.create(:name   => _("Enable certificate generation for %s") % self, :priority => 2002,
                 :action => [self, :setSSHCert])
    post_queue.create(:name   => _("Configure instance %s via SSH") % self, :priority => 2003,
                 :action => [self, :setSSHProvision])
  end

  def queue_ssh_provision_update; end

  def setSSHProvisionScript
    logger.info "About to start post launch script on #{name}"
    template   = configTemplate(:kind => "finish")
    @host      = self
    logger.info "generating template to upload to #{name}"
    self.template_file = unattended_render_to_temp_file(template)
  end

  def delSSHProvisionScript; end

  def setSSHWaitForResponse
    logger.info "Starting SSH provisioning script - waiting for #{provision_ip} to respond"
    if compute_resource.respond_to?(:key_pair) and compute_resource.key_pair.try(:secret)
      credentials = { :key_data => [compute_resource.key_pair.secret] }
    elsif vm.respond_to?(:password) and vm.password.present?
      credentials = { :password => vm.password, :auth_methods => ["password"] }
    elsif image.respond_to?(:password) and image.password.present?
      credentials = { :password => image.password, :auth_methods => ["password"] }
    else
      raise ::Foreman::Exception.new(N_('Unable to find proper authentication method'))
    end
    self.client = Foreman::Provision::SSH.new provision_ip, image.username, { :template => template_file.path, :uuid => uuid }.merge(credentials)

  rescue => e
    failure _("Failed to login via SSH to %{name}: %{e}") % { :name => name, :e => e }, e.backtrace
  end

  def delSSHWaitForResponse; end

  def setSSHCert
    self.handle_ca
    return false if errors.any?
    logger.info "Revoked old certificates and enabled autosign"
  end

  def delSSHCert
    # since we enable certificates/autosign via here, we also need to make sure we clean it up in case of an error
    if puppetca?
      respond_to?(:initialize_puppetca,true) && initialize_puppetca && delCertificate && delAutosign
    end
  rescue => e
    failure _("Failed to remove certificates for %{name}: %{e}") % { :name => name, :e => e }, e.backtrace
  end

  def setSSHProvision
    logger.info "SSH connection established to #{provision_ip} - executing template"
    if client.deploy!
      # since we are in a after_commit callback, we need to fetch our host again, and clean up puppet ca on our own
      Host.find(id).built
      respond_to?(:initialize_puppetca,true) && initialize_puppetca && delAutosign if puppetca?
    else
      raise ::Foreman::Exception.new(N_("Provision script had a non zero exit, removing instance"))
    end

  rescue => e
    failure _("Failed to launch script on %{name}: %{e}") % { :name => name, :e => e }, e.backtrace
  end

  def delSSHProvision; end

  def validate_ssh_provisioning
    return unless ssh_provision?
    return if Rails.env == "test"
    status = true
    begin
      template = configTemplate(:kind => "finish")
    rescue => e
      logger.error e.message
      logger.error e.backtrace.join("\n")
      status = false
    end
    status = false if template.nil?
    failure(_("No finish templates were found for this host, make sure you define at least one in your %s settings") % os ) unless status
  end

  def provision_ip
    provision_interface.ip
  end
end
