module Hostext
  module Ownership
    extend ActiveSupport::Concern

    included do
      OWNER_TYPES = %w(User Usergroup)
      belongs_to :owner, :polymorphic => true

      before_validation :set_default_user
      validates :owner_type, :inclusion =>
                               {:in => OWNER_TYPES,
                               :allow_blank => true,
                               :message     => (_("Owner type needs to be one of the following: %s") % OWNER_TYPES.join(', '))}
      validate :validate_owner
      validate :owner_taxonomies_match, :if => proc { |host| host.owner.is_a?(User) }
    end

    def owner
      case owner_type
        when 'User'
          User.unscoped { super }
        when 'Usergroup'
          Usergroup.unscoped { super }
        when nil, ''
          # not set yet, usually the case for new records
          nil
        else
          raise ArgumentError, "Unknown member type #{owner_type}"
      end
    end

    # method to return the correct owner list for host edit owner select dropbox
    def is_owned_by
      owner&.id_and_type
    end

    # virtual attributes which sets the owner based on the user selection
    # supports a simple user, or a usergroup
    # selection parameter is expected to be an ActiveRecord id_and_type method (see Foreman's AR extentions).
    def is_owned_by=(selection)
      owner = OwnerClassifier.new(selection).user_or_usergroup
      self.owner = owner
    end

    def owner_suggestion
      owner_id_and_type = Setting[:host_owner]
      owner = OwnerClassifier.new(owner_id_and_type).user_or_usergroup
      self.owner || owner || User.current
    end

    private

    def owner_taxonomies_match
      return true if owner.admin?

      if organization_id && !owner.my_organizations.where(:id => organization_id).exists?
        errors.add :is_owned_by, _("does not belong into host's organization")
      end
      if location_id && !owner.my_locations.where(:id => location_id).exists?
        errors.add :is_owned_by, _("does not belong into host's location")
      end
    end

    def set_default_user
      self.owner_type = 'User' if owner_id.present? && owner_type.blank?
      return if owner_type.present? && (!OWNER_TYPES.include?(owner_type) || owner.nil?)
      self.owner = owner_suggestion
    end

    def validate_owner
      return true if owner_type.nil? && owner.nil?

      add_owner_error if owner_type.present? && owner.nil?
    end

    def add_owner_error
      if owner_id.present?
        errors.add(:owner, (_('There is no owner with id %d and type %s') % [owner_id, owner_type]))
      else
        errors.add(:owner, _('If owner type is specified, owner must be specified too.'))
      end
    end
  end
end
