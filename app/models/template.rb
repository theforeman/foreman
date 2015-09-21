class Template < ActiveRecord::Base
  include Parameterizable::ByIdName

  validates_lengths_from_database

  validates :name, :presence => true
  validates :template, :presence => true
  validates :audit_comment, :length => {:maximum => 255}
  validate :template_changes, :if => ->(template) { (template.locked? || template.locked_changed?) && template.persisted? && !Foreman.in_rake? }

  before_destroy :check_if_template_is_locked

  before_save :remove_trailing_chars

  class Jail < Safemode::Jail
    allow :name
  end

  def skip_strip_attrs
    ['template']
  end

  def locked?
    locked && !Foreman.in_rake?
  end

  # if some child class needs to eager load some associations it can be added to this array
  def self.template_includes
    []
  end

  def preview_host_collection
    Host.authorized(:view_hosts).order(:name).limit(100)
  end

  private

  def allowed_changes
    @allowed_changes ||= %w(locked default)
  end

  def check_if_template_is_locked
    errors.add(:base, _("This template is locked and may not be removed.")) if locked?
  end

  def template_changes
    actual_changes = changes

    # Locked & Default are Special
    if actual_changes.include? 'locked'
      unless User.current.can?("lock_#{self.class.to_s.underscore.pluralize}", self)
        errors.add(:base, _("You are not authorized to lock templates."))
      end
    end

    if actual_changes.include? 'default'
      unless User.current.can?(:create_organizations) || User.current.can?(:create_locations)
        errors.add(:base, _("You are not authorized to make a template default."))
      end
    end

    unless actual_changes.delete_if { |k, v| allowed_changes.include? k }.empty?
      errors.add(:base, _("This template is locked. Please clone it to a new template to customize."))
    end
  end

  def remove_trailing_chars
    self.template.tr!("\r", '') unless template.blank?
  end
end

require_dependency 'provisioning_template'
require_dependency 'ptable'
