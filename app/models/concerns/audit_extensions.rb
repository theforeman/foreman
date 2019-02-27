# The audit class is part of audited plugin
module AuditExtensions
  extend ActiveSupport::Concern

  REDACTED = N_('[redacted]')

  included do
    before_save :fix_auditable_type, :ensure_username, :ensure_auditable_and_associated_name, :set_taxonomies
    before_save :filter_encrypted, :if => Proc.new {|audit| audit.audited_changes.present?}
    before_save :filter_passwords, :if => Proc.new {|audit| audit.audited_changes.try(:has_key?, 'password')}
    after_create :log_audit

    scope :untaxed, -> { by_auditable_types(untaxable) }
    scope :taxed_only_by_location, -> { by_auditable_types(location_taxable) }
    scope :taxed_only_by_location_in_taxonomy_scope, lambda {
      with_taxonomy_scope(Location.current, nil, :subtree_ids, [:organization]) { taxed_only_by_location }
    }
    scope :taxed_only_by_organization, -> { by_auditable_types(organization_taxable) }
    scope :taxed_only_by_organization_in_taxonomy_scope, lambda {
      with_taxonomy_scope(nil, Organization.current, :subtree_ids, [:location]) { taxed_only_by_organization }
    }
    scope :fully_taxable_auditables, -> { by_auditable_types(fully_taxable) }
    scope :fully_taxable_auditables_in_taxonomy_scope, -> { with_taxonomy_scope { fully_taxable_auditables } }
    scope :by_auditable_types, ->(auditable_types) { where(:auditable_type => auditable_types.map(&:to_s)).readonly(false) }
    scope :taxed_and_untaxed, lambda {
      untaxed.or(fully_taxable_auditables_in_taxonomy_scope)
             .or(taxed_only_by_organization_in_taxonomy_scope)
             .or(taxed_only_by_location_in_taxonomy_scope)
    }

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

    # Audits should never execute what Taxonomix#set_current_taxonomy does
    def set_current_taxonomy
    end

    class << self
      def allows_organization_filtering?
        false
      end

      def allows_location_filtering?
        false
      end

      def location_taxable
        known_auditable_types.select do |model|
          has_any_association_to?(:location, model) &&
          !has_any_association_to?(:organization, model)
        end
      end

      def organization_taxable
        known_auditable_types.select do |model|
          has_any_association_to?(:organization, model) &&
          !has_any_association_to?(:location, model)
        end
      end

      def fully_taxable
        known_auditable_types.select do |model|
          [:location, :organization].map do |taxable|
            has_any_association_to?(taxable, model)
          end.all?
        end
      end

      def untaxable
        untaxed = known_auditable_types.select do |model|
          !has_taxonomix?(model)
          !has_any_association_to?(:organization, model) &&
          !has_any_association_to?(:location, model)
        end
        untaxed -= Nic::Base.descendants unless User.current.admin?
        untaxed
      end

      def known_auditable_types
        unscoped.distinct.pluck(:auditable_type).map do |auditable_type|
          begin
            auditable_type.constantize
          rescue NameError
          end
        end.compact
      end

      private

      def has_association?(association, model = self)
        associations = model.reflect_on_all_associations.map(&:name)
        associations.include?(association)
      end

      def has_any_association_to?(tax_type, model)
        [has_association?(tax_type.to_sym, model), has_association?(tax_type.to_s.pluralize.to_sym, model)].any?
      end

      def has_taxonomix?(model)
        model.include?(Taxonomix)
      end
    end
  end

  module ClassMethods
    def main_objects
      audited_classes.reject { |cl| cl.audited_options.key?(:associated_with) }
    end

    def main_object_names
      main_objects.map(&:name)
    end
  end

  private

  def log_audit
    telemetry_increment_counter(:audit_records_created, 1, type: self.auditable_type)
    audit_logger = Foreman::Logging.logger('audit')
    return unless (self.audited_changes && audit_logger.info?)
    self.audited_changes.each_pair do |attribute, change|
      audited_fields = {
        audit_action: self.action,
        audit_type: self.auditable_type,
        audit_id: self.auditable_id,
        audit_attribute: attribute
      }
      if self.action == 'update'
        audited_fields[:audit_field_old] = change[0]
        audited_fields[:audit_field_new] = change[1]
        log_line = change.join(', ')
      else
        audited_fields[:audit_field] = change
        log_line = change
      end
      Foreman::Logging.with_fields(audited_fields) do
        audit_logger.info "#{self.auditable_type} (#{self.auditable_id}) #{self.action} event on #{attribute} #{log_line}"
      end
    end
    telemetry_increment_counter(:audit_records_logged, self.audited_changes.count, type: self.auditable_type)
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
      set_taxonomy_for(:location)
    end
    if SETTINGS[:organizations_enabled]
      set_taxonomy_for(:organization)
    end
  end

  def set_taxonomy_for(taxonomy)
    taxonomy_attribute = "#{taxonomy}_id".to_sym
    taxonomy_attribute_plural = taxonomy_attribute.to_s.pluralize.to_sym

    if auditable.respond_to?(taxonomy_attribute)
      self.send("#{taxonomy_attribute_plural}=", [
        auditable.send(taxonomy_attribute), audited_changes[taxonomy_attribute.to_s]
      ].flatten.compact.uniq)
    elsif auditable.respond_to?(taxonomy_attribute_plural)
      self.send("#{taxonomy_attribute_plural}=", auditable.send(taxonomy_attribute_plural))
    elsif associated
      set_taxonomies_using_associated(taxonomy.to_s)
    end

    if auditable.is_a? taxonomy.capitalize.to_s.constantize
      self.send("#{taxonomy_attribute_plural}=", [auditable_id])
    end
  end

  def set_taxonomies_using_associated(key_name)
    ids_arr = []
    if associated.respond_to?(:"#{key_name}_id")
      ids_arr = [associated.send("#{key_name}_id")].compact.uniq
    elsif associated.respond_to?(:"#{key_name}_ids")
      ids_arr = associated.send("#{key_name}_ids")
    end
    self.send("#{key_name}_ids=", ids_arr)
  end
end
