# The audit class is part of audited plugin
module AuditExtensions
  extend ActiveSupport::Concern

  REDACTED = N_('[redacted]')

  included do
    before_save :fix_auditable_type, :ensure_username, :ensure_auditable_and_associated_name, :set_taxonomies
    before_save :filter_encrypted, :if => proc { |audit| audit.audited_changes.present? }
    before_save :filter_passwords, :if => proc { |audit| audit.audited_changes.try(:has_key?, 'password') }
    after_create :log_audit

    scope :untaxed, -> { by_auditable_types(untaxable) }
    scope :by_auditable_types, ->(auditable_types) { where(:auditable_type => auditable_types.map(&:to_s)).readonly(false) }

    include Authorizable
    include Taxonomix
    include Foreman::TelemetryHelper

    # audits can be created regardless of permissions
    def check_permissions_after_save
      true
    end

    def self.humanize_class_name
      N_("Audit")
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
          auditable_type.constantize
        rescue NameError
        end.compact
      end

      def taxed_only_by_location
        join_user_locations.where(arel_taxed_only_by_location)
      end

      def taxed_only_by_organization
        join_user_organizations.where(arel_taxed_only_by_organization)
      end

      def taxed_and_untaxed
        clauses = []
        if filter_taxonomy?(Organization)
          clauses << org_join_arel[:taxonomy_id].in(user_taxonomy_ids(Organization))
        end

        if filter_taxonomy?(Location)
          clauses << loc_join_arel[:taxonomy_id].in(user_taxonomy_ids(Location))
        end

        clauses << arel_table[:auditable_type].in(fully_taxable.map(&:to_s))
        fully_taxed_arel = clauses.reduce(:and)
        fully_taxed_arel = arel_table.grouping(fully_taxed_arel) if clauses.size > 1
        statement = fully_taxed_arel.
          or(arel_table[:auditable_type].in(untaxable.map(&:to_s))).
          or(arel_table.grouping(arel_taxed_only_by_organization)).
          or(arel_table.grouping(arel_taxed_only_by_location))

        taxonomy_join_scope.where(statement)
      end

      def arel_taxed_only_by_location
        arel_table[:auditable_type].in(location_taxable.map(&:to_s)).
          and(loc_join_arel[:taxonomy_id].in(user_taxonomy_ids(Location)))
      end

      def arel_taxed_only_by_organization
        arel_table[:auditable_type].in(organization_taxable.map(&:to_s)).
          and(org_join_arel[:taxonomy_id].in(user_taxonomy_ids(Organization)))
      end

      def join_taxonomies(taxonomy_ids, tax_arel, taxonomy_class)
        class_arel = base_class.arel_table
        statement = class_arel.join(tax_arel, Arel::Nodes::OuterJoin).on(
          class_arel[:id].eq(tax_arel[:taxable_id]).
          and(tax_arel[:taxable_type].eq(base_class.name)).
          and(tax_arel[:taxonomy_id].in(taxonomy_ids))
        )
        joins(statement.join_sources)
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
      main_classes = audited_classes.reject { |cl| cl.audited_options.key?(:associated_with) }
      main_classes.concat(non_abstract_parents(main_classes))
    end

    def main_object_names
      main_objects.map(&:name)
    end

    def non_abstract_parents(classes_list)
      parents_list = classes_list.map(&:superclass).uniq
      parents_list.select { |cl| cl != ActiveRecord::Base && !cl.abstract_class? && cl.table_exists? }.compact
    end
  end

  private

  def log_audit
    telemetry_increment_counter(:audit_records_created, 1, type: auditable_type)
    audit_logger = Foreman::Logging.logger('audit')
    return unless (audited_changes && audit_logger.info?)
    audited_changes.each_pair do |attribute, change|
      audited_fields = {
        audit_action: action,
        audit_type: auditable_type,
        audit_id: auditable_id,
        audit_attribute: attribute,
      }
      if action == 'update'
        audited_fields[:audit_field_old] = change[0]
        audited_fields[:audit_field_new] = change[1]
        log_line = change.join(', ')
      else
        audited_fields[:audit_field] = change
        log_line = change
      end
      Foreman::Logging.with_fields(audited_fields) do
        audit_logger.info "#{auditable_type} (#{auditable_id}) #{action} event on #{attribute} #{log_line}"
      end
    end
    telemetry_increment_counter(:audit_records_logged, audited_changes.count, type: auditable_type)
  end

  def filter_encrypted
    audited_changes.each do |name, change|
      next if change.nil? || change.to_s.empty?
      if change.is_a? Array
        change.map! { |c| c.to_s.start_with?(EncryptValue::ENCRYPTION_PREFIX) ? REDACTED : c }
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
    previous_state = auditable.class.unscoped.find_by(id: auditable_id) if auditable
    previous_state ||= auditable
    self.auditable_name ||= previous_state.try(:to_label)
    self.associated_name ||= associated.try(:to_label)
  end

  def set_taxonomies
    set_taxonomy_for(:location)
    set_taxonomy_for(:organization)
  end

  def set_taxonomy_for(taxonomy)
    taxonomy_attribute = "#{taxonomy}_id".to_sym
    taxonomy_attribute_plural = taxonomy_attribute.to_s.pluralize.to_sym

    if auditable.respond_to?(taxonomy_attribute)
      send("#{taxonomy_attribute_plural}=", [
        auditable.send(taxonomy_attribute), audited_changes[taxonomy_attribute.to_s]
      ].flatten.compact.uniq)
    elsif auditable.respond_to?(taxonomy_attribute_plural)
      send("#{taxonomy_attribute_plural}=", auditable.send(taxonomy_attribute_plural).uniq)
    elsif associated
      set_taxonomies_using_associated(taxonomy.to_s)
    end

    if auditable.is_a? taxonomy.capitalize.to_s.constantize
      send("#{taxonomy_attribute_plural}=", [auditable_id])
    end
  end

  def set_taxonomies_using_associated(key_name)
    ids_arr = []
    if associated.respond_to?(:"#{key_name}_id")
      ids_arr = [associated.send("#{key_name}_id")]
    elsif associated.respond_to?(:"#{key_name}_ids")
      ids_arr = associated.send("#{key_name}_ids")
    end
    send("#{key_name}_ids=", ids_arr.compact.uniq)
  end
end
