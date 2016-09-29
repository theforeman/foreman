module UserTime
  extend ActiveSupport::Concern

  included do
    validate :validate_timezone

    def validate_timezone
      errors.add(:timezone, _("is not valid")) unless timezone.blank? || Time.find_zone(timezone)
    end
  end
end
