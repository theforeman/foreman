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
    return unless ssh_provision? && errors.empty?
    new_record? ? queue_ssh_provision_create : queue_ssh_provision_update
  end

  # I guess this is not going to happen on create as we might not have an ip address yet.
  def queue_ssh_provision_create
    post_queue.create(:name   => _("Prepare post installation script for %s") % self, :priority => 2000,
                 :action => [self, :setSSHProvisionScript])
    post_queue.create(:name   => _("Wait for %s to come online") % self, :priority => 2001,
                 :action => [self, :setSSHWaitForResponse])
    post_queue.create(:name   => _("Configure instance %s via SSH") % self, :priority => 2003,
                 :action => [self, :setSSHProvision])
  end

  def queue_ssh_provision_update
  end

  def setSSHProvisionScript
    logger.info "About to start post launch script on #{name}"
    template = provisioning_template(:kind => "finish")
    logger.info "generating template to upload to #{name}"
    self.template_file = Foreman::Renderer.render_template_to_tempfile(template: template, prefix: id.to_s, host: self)
  end

  def delSSHProvisionScript
  end

  def setSSHWaitForResponse
    logger.info "Starting SSH provisioning script - waiting for #{provision_host} to respond"
    if compute_resource.respond_to?(:key_pair) && compute_resource.key_pair.try(:secret)
      credentials = { :key_data => [compute_resource.key_pair.secret] }
    elsif vm.respond_to?(:password) && vm.password.present?
      credentials = { :password => vm.password, :auth_methods => ["password", "keyboard-interactive"] }
    elsif image.respond_to?(:password) && image.password.present?
      credentials = { :password => image.password, :auth_methods => ["password", "keyboard-interactive"] }
    else
      raise ::Foreman::Exception.new(N_('Unable to find proper authentication method'))
    end
    self.client = Foreman::Provision::SSH.new provision_host, image.try(:username), { :template => template_file.path, :uuid => uuid }.merge(credentials)
  rescue => e
    failure _("Failed to login via SSH to %{name}: %{e}") % { :name => name, :e => e }, e
  end

  def delSSHWaitForResponse
  end

  def setSSHProvision
    logger.info "SSH connection established to #{provision_host} - executing template"
    if client.deploy!
      # since we are in a after_commit callback, we need to fetch our host again, and clean up puppet ca on our own
      Host.find(id).built
      if puppetca? && respond_to?(:initialize_puppetca, true)
        initialize_puppetca && delAutosign
      else
        true
      end
    else
      if Setting[:clean_up_failed_deployment]
        logger.info "Deleting host #{name} because of non zero exit code of deployment script."
        Host.find(id).destroy
      end
      raise ::Foreman::Exception.new(N_("Provision script had a non zero exit"))
    end
  rescue => e
    failure _("Failed to launch script on %{name}: %{e}") % { :name => name, :e => e }, e
  end

  def delSSHProvision
  end

  def validate_ssh_provisioning
    return unless ssh_provision?
    return if Rails.env.test?
    status = true
    begin
      template = provisioning_template(:kind => "finish")
    rescue => e
      Foreman::Logging.exception("Error while validating ssh provisioning", e)
      status = false
    end
    status = false if template.nil?
    failure(_("No finish templates were found for this host, make sure you define at least one in your %s settings") % os) unless status
  end

  def provision_host
    # usually cloud compute resources provide IPs but virtualization do not
    provision_interface.ip || provision_interface.fqdn
  end
end
