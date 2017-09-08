class TemplateKind < ApplicationRecord
  extend FriendlyId
  friendly_id :name
  validates_lengths_from_database
  has_many :provisioning_templates, :inverse_of => :template_kind
  has_many :os_default_templates
  validates :name, :presence => true, :uniqueness => true
  scoped_search :on => :name

  PXE = ["PXEGrub2", "PXELinux", "PXEGrub"]

  def self.default_template_labels
    {
      "PXELinux" => N_("PXELinux template"),
      "PXEGrub" => N_("PXEGrub template"),
      "PXEGrub2" => N_("PXEGrub2 template"),
      "iPXE" => N_("iPXE template"),
      "provision" => N_("Provisioning template"),
      "finish" => N_("Finish template"),
      "script" => N_("Script template"),
      "user_data" => N_("User data template"),
      "ZTP" => N_("ZTP PXE template"),
      "POAP" => N_("POAP PXE template")
    }
  end

  def self.plugin_template_labels
    Foreman::Plugin.all.map(&:get_template_labels).inject({}, :merge)
  end

  def humanized_name
    [self.class.default_template_labels[name], self.class.plugin_template_labels[name]].detect(&:present?)
  end

  def to_s
    return _(humanized_name) if humanized_name.present?
    name
  end
end
