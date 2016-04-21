class TemplateKind < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name
  validates_lengths_from_database
  has_many :provisioning_templates, :inverse_of => :template_kind
  has_many :os_default_templates
  validates :name, :presence => true, :uniqueness => true
  scoped_search :on => :name

  def self.jar
    @jar ||= { "PXELinux" => N_("PXELinux template"),
               "PXEGrub" => N_("PXEGrub template"),
               "iPXE" => N_("iPXE template"),
               "provision" => N_("Provisioning template"),
               "finish" => N_("Finish template"),
               "script" => N_("Script template"),
               "user_data" => N_("User data template"),
               "ZTP" => N_("ZTP template"),
               "POAP" => N_("POAP template")
             }
  end

  def self.add_to_jar(hash)
    jar.merge!(hash) { |key| raise Foreman::Exception.new(N_("Cannot add template with key %s, it already exists"), key) }
  end

  def to_s
    TemplateKind.jar[name] || name
  end
end
