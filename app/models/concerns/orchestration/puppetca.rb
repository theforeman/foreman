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
    @puppetca = ProxyAPI::Puppetca.new(:url => puppet_ca_proxy.url)
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
  def setCertificate; end

  # Generate a new token for the host
  # so we can verify if a CSR is legit
  # and should be signed
  def set_puppetca_token
    self.create_puppetca_token
  end

  # Disables all puppetCA tokens for this host
  def del_puppetca_token
    self.puppetca_token.delete if self.puppetca_token.present?
  end

  private

  def queue_puppetca
    return log_orchestration_errors unless puppetca? && errors.empty?
    return unless Setting[:manage_puppetca]
    new_record? ? queue_puppetca_create : queue_puppetca_update
  end

  def queue_puppetca_create
    return unless self.build?
    queue_puppetca_autosign_create
    true
  end

  def queue_puppetca_update
    return unless self.build? && !self.old.build?
    queue_puppetca_autosign_destroy(priority: 11)
    queue_puppetca_autosign_create
    true
  end

  def queue_puppetca_destroy
    return unless puppetca? && errors.empty?
    return unless Setting[:manage_puppetca]
    post_queue.create(:name => _('Delete PuppetCA certificates for %s') % self, :priority => 50,
                      :action => [self, :delCertificate])
    queue_puppetca_autosign_destroy
    true
  end

  def queue_puppetca_autosign_create(priority: 12)
    post_queue.create(:name => _('Enable PuppetCA autosign for %s') % self, :priority => priority,
                      :action => [self, :set_puppetca_token])
  end

  def queue_puppetca_autosign_destroy(priority: 55)
    post_queue.create(:name => _('Disable PuppetCA autosign for %s') % self, :priority => priority,
                      :action => [self, :del_puppetca_token])
  end
end
