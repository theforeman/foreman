module Orchestration::Realm
  extend ActiveSupport::Concern
  include Orchestration::Common

  included do
    after_validation  :queue_realm
    before_destroy    :queue_realm_destroy
  end

  def realm?
    name.present? && realm.present?
  end

  def initialize_realm
    return unless realm?
    @realm_api = ProxyAPI::Realm.new :url => realm.realm_proxy.url, :realm_name => realm.name
  rescue => e
    failure _("Failed to initialize the realm proxy: %s") % e, e
  end

  # Removes the host from the realm
  def del_realm
    initialize_realm
    logger.info "Delete realm entry for #{name}"
    @realm_api.delete name
  end

  # Adds the host to the realm, and sets otp if we get one back
  def set_realm(options = {})
    initialize_realm
    logger.info "#{options[:update] ? 'Update' : 'Add'} realm entry for #{options[:rebuild] ? 'reprovisioned' : 'new'} host #{name}"
    options[:hostname]  = name
    options[:userclass] = hostgroup.title unless hostgroup.nil?
    result = @realm_api.create options
    raise ::Foreman::Exception.new(N_('Realm proxy did not return a one-time password')) unless options[:update] || result.has_key?("randompassword")
    self.otp = result["randompassword"]
    result
  rescue => e
    failure _("Failed to create %{name}'s realm entry: %{e}") % { :name => name, :e => e }, e
  end

  def update_realm
    set_realm :update => true
  end

  private

  def queue_realm
    return log_orchestration_errors unless realm? && errors.empty?
    new_record? ? queue_realm_create : queue_realm_update
  end

  def queue_realm_create
    queue.create(:name => _("Create realm entry for %s") % self, :priority => 1,
                 :action => [self, :set_realm])
  end

  def queue_realm_update
    # Update if the hostgroup is changed or if the realm is changed
    if hostgroup_id_changed? || realm_id_changed?
      queue.create(:name => _("Update realm entry for %s") % self, :priority => 1,
                   :action => [self, :update_realm])
    end
  end

  def queue_realm_destroy
    return unless realm? && errors.empty?
    queue.create(:name => _("Delete realm entry for %s") % self, :priority => 50,
                 :action => [self, :del_realm])
  end
end
