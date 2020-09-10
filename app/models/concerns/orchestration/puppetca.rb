module Orchestration::Puppetca
  extend ActiveSupport::Concern
  include Orchestration::Common

  included do
    attr_reader :puppetca
    after_validation :initialize_puppetca, :unless => :skip_orchestration?
    after_validation :queue_puppetca
    before_destroy :initialize_puppetca, :queue_puppetca_destroy
  end

  protected

  def initialize_puppetca
    return unless puppetca?
    return unless Setting[:manage_puppetca]
    @puppetca = ProxyAPI::Puppetca.new :url => puppet_ca_proxy.url
    true
  rescue => e
    failure _("Failed to initialize the PuppetCA proxy: %s") % e, e
  end

  # Removes the host's puppet certificate from the puppetmaster's CA
  def delCertificate
    logger.info "Remove puppet certificate for #{name}"
    puppetca.del_certificate certname
  end

  # Empty method for rollbacks - maybe in the future we would support creating the certificates directly
  def setCertificate
  end

  # Reset certname based on whether to use uuids or the hostname
  def resetCertname
    logger.info "Resetting certname for #{name}"
    self.certname = Setting[:use_uuid_for_certificates] ? Foreman.uuid : hostname
  end

  # Adds the host's name to the autosign.conf file
  def setAutosign
    logger.info "Adding autosign entry for #{name}"
    response = puppetca.set_autosign certname
    # return if puppetca is using basic autosigning
    return response if response.in? [true, false]
    unless response.is_a?(Hash) && response['generated_token'].present?
      logger.warn "Received an unexpected smart proxy response: #{response}"
      return false
    end
    create_puppetca_token value: response['generated_token']
  end

  # Removes the host's name from the autosign.conf file
  def delAutosign
    logger.info "Delete the autosign entry for #{name}"
    puppetca_token.destroy! if puppetca_token.present?
    puppetca.del_autosign certname
  end

  private

  def queue_puppetca
    return log_orchestration_errors unless puppetca? && errors.empty?
    return unless Setting[:manage_puppetca]
    new_record? ? queue_puppetca_create : queue_puppetca_update
  end

  def queue_puppetca_certname_reset
    post_queue.create(:name => _("Reset PuppetCA certname for %s") % self, :priority => 49,
                      :action => [self, :resetCertname])
  end

  def queue_puppetca_create
    post_queue.create(:name => _("Cleanup PuppetCA certificates for %s") % self, :priority => 51,
                      :action => [self, :delCertificate])
    post_queue.create(:name => _("Enable PuppetCA autosigning for %s") % self, :priority => 55,
                      :action => [self, :setAutosign])
  end

  def queue_puppetca_update
    if old.build? && !build?
      # Host has been built --> remove auto sign
      queue_puppetca_autosign_destroy
    elsif !old.build? && build?
      # Host was set to build mode
      # If use_uuid_for_certificates is true, reuse the certname UUID value.
      # If false, then reset the certname if it does not match the hostname.
      if (Setting[:use_uuid_for_certificates] ? !Foreman.is_uuid?(certname) : certname != hostname)
        queue_puppetca_certname_reset
      end
      queue_puppetca_autosign_destroy
      queue_puppetca_create
    end
    true
  end

  def queue_puppetca_destroy
    return unless puppetca? && errors.empty?
    return unless Setting[:manage_puppetca]
    post_queue.create(:name => _("Delete PuppetCA certificates for %s") % self, :priority => 59,
                      :action => [self, :delCertificate])
    queue_puppetca_autosign_destroy
    true
  end

  def queue_puppetca_autosign_destroy
    post_queue.create(:name => _("Disable PuppetCA autosigning for %s") % self, :priority => 50,
                      :action => [self, :delAutosign])
  end
end
