# The audit class is part of audited plugin
module AuditExtensions
  extend ActiveSupport::Concern

  REDACTED = N_('[redacted]')

  included do
    before_save :fix_auditable_type, :ensure_username, :ensure_auditable_and_associated_name, :set_taxonomies
    before_save :filter_encrypted, :if => Proc.new {|audit| audit.audited_changes.present?}
    before_save :filter_passwords, :if => Proc.new {|audit| audit.audited_changes.try(:has_key?, 'password')}
    after_create :log_audit
    after_create :telemetry_create

    include Authorizable
    include Taxonomix
    include Foreman::TelemetryHelper

    # audits can be created regardless of permissions
    def check_permissions_after_save
      true
    end

    def self.humanize_class_name
      _("Audit")
    end

    serialize :audited_changes

    # don't check user's permissions when setting the audit's taxonomies
    def ensure_taxonomies_not_escalated
      true
    end
  end

  private

  def log_audit
    Foreman::Logging.with_fields(self.audited_changes) do
      Foreman::Logging.logger('audit').info { "#{self.action} event for #{self.auditable_type} with id #{self.auditable_id}" }
    end
  end

  def telemetry_create
    telemetry_increment_counter(:audit_records_created, 1, type: self.auditable_type)
  end

  def filter_encrypted
    self.audited_changes.each do |name, change|
      next if change.nil? || change.to_s.empty?
      if change.is_a? Array
        change.map! {|c| c.to_s.start_with?(EncryptValue::ENCRYPTION_PREFIX) ? REDACTED : c}
      else
        audited_changes[name] = REDACTED if change.to_s.start_with?(EncryptValue::ENCRYPTION_PREFIX)
      end
    end
  end

  def filter_passwords
    if action == 'update'
      audited_changes['password'] = [REDACTED, REDACTED]
    else
      audited_changes['password'] = REDACTED
    end
  end

  def ensure_username
    self.user_as_model = User.current
    self.username = User.current.try(:to_label)
  end

  def fix_auditable_type
    # STI Host class should use the stub module instead of Host::Base
    self.auditable_type = "Host::Base" if auditable_type =~ /Host::/
    self.associated_type = "Host::Base" if associated_type =~ /Host::/
    self.auditable_type = auditable.type if ["Taxonomy", "LookupKey"].include?(auditable_type) && auditable
    self.associated_type = associated.type if ["Taxonomy", "LookupKey"].include?(associated_type) && associated
    self.auditable_type = auditable.type if auditable_type =~ /Nic::/
  end

  def ensure_auditable_and_associated_name
    # If the label changed we want to record the old one, not the new one.
    # We need to load old version from db since the auditable in memory is the
    # updated version that hasn't been saved yet.
    previous_state = auditable.class.find_by(id: auditable_id) if auditable
    previous_state ||= auditable
    self.auditable_name  ||= previous_state.try(:to_label)
    self.associated_name ||= self.associated.try(:to_label)
  end

  def set_taxonomies
    if SETTINGS[:locations_enabled]
      if auditable.respond_to?(:location_id)
        self.location_ids = [auditable.location_id, audited_changes['location_id']].flatten.compact.uniq
      elsif auditable.respond_to?(:location_ids)
        self.location_ids = auditable.location_ids
      elsif auditable.is_a? Location
        self.location_ids = [auditable_id]
      end
    end
    if SETTINGS[:organizations_enabled]
      if auditable.respond_to?(:organization_id)
        self.organization_ids = [auditable.organization_id, audited_changes['organization_id']].flatten.compact.uniq
      elsif auditable.respond_to?(:organization_ids)
        self.organization_ids = auditable.organization_ids
      elsif auditable.is_a? Organization
        self.organization_ids = [auditable_id]
      end
    end
  end
end
