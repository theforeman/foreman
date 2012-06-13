module Orchestration::SSHProvision
  def self.included(base)
    base.send :include, InstanceMethods
    base.class_eval do
      after_validation :validate_ssh_provisioning, :queue_ssh_provision
      attr_accessor :template_file, :client
    end
  end

  module InstanceMethods
    def ssh_provision?
      compute_attributes.present? && capabilities.include?(:image)
    end

    protected
    def queue_ssh_provision
      return unless ssh_provision? and errors.empty?
      new_record? ? queue_ssh_provision_create : queue_ssh_provision_update
    end

    # I guess this is not going to happen on create as we might not have an ip address yet.
    def queue_ssh_provision_create

      post_queue.create(:name   => "Preparing Post installation script for #{self}", :priority => 2000,
                   :action => [self, :setSSHProvisionScript])
      post_queue.create(:name   => "Waiting for #{self} to come online", :priority => 2001,
                   :action => [self, :setSSHWaitForResponse])
      post_queue.create(:name   => "Enable Certificate generation for #{self}", :priority => 2002,
                   :action => [self, :setSSHCert])
      post_queue.create(:name   => "Configuring instance #{self} via SSH", :priority => 2003,
                   :action => [self, :setSSHProvision])
    end

    def queue_ssh_provision_update; end

    def setSSHProvisionScript
      logger.info "About to start post launch script on #{name}"
      template   = configTemplate(:kind => "finish")
      @host      = self
      logger.info "generating template to upload to #{name}"
      self.template_file = unattended_render_to_temp_file(template.template)
    end

    def delSSHProvisionScript; end

    def setSSHWaitForResponse
      logger.info "Starting SSH provisioning script - waiting for #{ip} to respond"
      self.client = Foreman::Provision::SSH.new ip, image.username, :template => template_file.path, :uuid => uuid, :key_data => [compute_resource.key_pair.secret]

    rescue => e
      failure "Failed to login via SSH to #{name}: #{e}", e.backtrace
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
        respond_to?(:initialize_puppetca) && initialize_puppetca && delCertificate && delAutosign
      end
    rescue => e
      failure "Failed to remove certificates for #{name}: #{e}", e.backtrace
    end

    def setSSHProvision
      logger.info "SSH connection established to #{ip} - executing template"
      if client.deploy!
        # since we are in a after_commit callback, we need to fetch our host again
        h = Host.find(id)
        h.build = false
        h.installed_at = Time.now.utc
        # calling valiadtions would trigger the whole orchestartion layer again, we don't want it while we are inside an orchestation action ourself.
        h.save(:validate => false)
        # but it does mean we need to manually remove puppetca autosign, remove this when we no longer part of after_commit callback
        respond_to?(:initialize_puppetca) && initialize_puppetca && delAutosign if puppetca?

      else
        raise "Provision script had a non zero exit, removing instance"
      end

    rescue => e
      failure "Failed to launch script on #{name}: #{e}", e.backtrace
    end

  end

  def delSSHProvision; end

  def validate_ssh_provisioning
    return unless ssh_provision?
    return if Rails.env == "test"
    status = true
    begin
      template = configTemplate(:kind => "finish")
    rescue => e
      status = false
    end
    status = false if template.nil?
    failure "No finish templates were found for this host, make sure you define at least one in your #{os} settings" unless status
    image_uuid = compute_attributes[:image_id]
    unless (self.image = Image.find_by_uuid(image_uuid))
      status &= failure("Must define an Image to use")
    end

    status
  end

end
