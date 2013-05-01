module Orchestration::Puppetca
  extend ActiveSupport::Concern

  included do
    attr_reader :puppetca
    after_validation :initialize_puppetca, :queue_puppetca
    before_destroy :initialize_puppetca, :queue_puppetca_destroy unless Rails.env == "test"
  end

  protected

  def initialize_puppetca
    return unless puppetca?
    return unless Setting[:manage_puppetca]
    @puppetca = ProxyAPI::Puppetca.new :url => puppet_ca_proxy.url
    true
  rescue => e
    failure _("Failed to initialize the PuppetCA proxy: %s") % e
  end

  # Removes the host's puppet certificate from the puppetmaster's CA
  def delCertificate
    logger.info "Remove puppet certificate for #{name}"
    puppetca.del_certificate certname
  rescue => e
    failure _("Failed to remove %{name}'s puppet certificate: %{e}") % { :name => name, :e => proxy_error(e) }
  end

  # Empty method for rollbacks - maybe in the future we would support creating the certificates directly
  def setCertificate; end

  # Adds the host's name to the autosign.conf file
  def setAutosign
    logger.info "Adding autosign entry for #{name}"
    puppetca.set_autosign certname
  rescue => e
    failure _("Failed to add %{name} to autosign file: %{e}") % { :name => name, :e => proxy_error(e) }
  end

  # Removes the host's name from the autosign.conf file
  def delAutosign
    logger.info "Delete the autosign entry for #{name}"
    puppetca.del_autosign certname
  rescue => e
    failure _("Failed to remove %{self} from the autosign file: %{e}") % { :self => self, :e => proxy_error(e) }
  end

  private

  def queue_puppetca
    return unless puppetca? and errors.empty?
    return unless Setting[:manage_puppetca]
    new_record? ? queue_puppetca_create : queue_puppetca_update
  end

  # we don't perform any actions upon create
  # PuppetCA is set only when a provisioning script (such as a kickstart) is being requested.
  def queue_puppetca_create; end

  def queue_puppetca_update
    # Host has been built --> remove auto sign
    if old.build? and !build?
      queue.create(:name => _("Delete autosign entry for %s") % self, :priority => 50,
                   :action => [self, :delAutosign])
    end
  end

  def queue_puppetca_destroy
    return unless puppetca? and errors.empty?
    return unless Setting[:manage_puppetca]
    queue.create(:name => _("Delete PuppetCA certificates for %s") % self, :priority => 50,
                 :action => [self, :delCertificate])
    queue.create(:name => _("Delete PuppetCA certificates for %s") % self, :priority => 55,
                 :action => [self, :delAutosign])
  end
end
