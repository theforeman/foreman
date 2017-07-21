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
  def setCertificate; end

  # Adds the host's name to the autosign.conf file
  def setAutosign
    logger.info "Adding autosign entry for #{name}"
    puppetca.set_autosign certname
  end

  # Removes the host's name from the autosign.conf file
  def delAutosign
    logger.info "Delete the autosign entry for #{name}"
    puppetca.del_autosign certname
  end

  private

  def queue_puppetca
    return log_orchestration_errors unless puppetca? && errors.empty?
    return unless Setting[:manage_puppetca]
    new_record? ? queue_puppetca_create : queue_puppetca_update
  end

  # we don't perform any actions upon create
  # PuppetCA is set only when a provisioning script (such as a kickstart) is being requested.
  def queue_puppetca_create; end

  def queue_puppetca_update
    # Host has been built --> remove auto sign
    queue_puppetca_autosign_destroy if old.build? && !build?
    true
  end

  def queue_puppetca_destroy
    return unless puppetca? && errors.empty?
    return unless Setting[:manage_puppetca]
    queue.create(:name => _("Delete PuppetCA certificates for %s") % self, :priority => 50,
                 :action => [self, :delCertificate])
    queue_puppetca_autosign_destroy
    true
  end

  def queue_puppetca_autosign_destroy
    queue.create(:name => _("Delete PuppetCA autosign entry for %s") % self, :priority => 55,
                 :action => [self, :delAutosign])
  end
end
