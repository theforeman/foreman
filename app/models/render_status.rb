class RenderStatus < ApplicationRecord
  include Authorizable

  belongs_to :host, class_name: 'Host::Managed'
  belongs_to :hostgroup
  belongs_to :provisioning_template, foreign_key: :template_id

  validate :host_or_hostgroup_presence
  validates :host, uniqueness: { scope: [:provisioning_template, :safemode] }
  validates :hostgroup, uniqueness: { scope: [:provisioning_template, :safemode] }
  validates :provisioning_template, presence: true
  validates :safemode, inclusion: [true, false]
  validates :success, inclusion: [true, false]

  scoped_search on: :updated_at, default_order: :asc
  scoped_search on: :safemode

  private

  def host_or_hostgroup_presence
    errors.add(:base, "can only have host or hostgroup") if host.present? && hostgroup.present?
    errors.add(:base, "host or hostgroup is required") if host.blank? && hostgroup.blank?
  end
end
