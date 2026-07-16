module NormalizeCacert
  extend ActiveSupport::Concern

  included do
    before_validation :normalize_cacert_line_endings
  end

  private

  def normalize_cacert_line_endings
    self.cacert = Foreman::Util.normalize_line_endings(cacert) if cacert.present?
  end
end
