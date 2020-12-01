module Hostext
  module OperatingSystem
    extend ActiveSupport::Concern

    included do
      scope :with_os, -> { where('hosts.operatingsystem_id IS NOT NULL') }
      alias_attribute :os, :operatingsystem
      validates :operatingsystem_id, :presence => true,
        :if => ->(host) { host.managed }
    end

    # returns a configuration template (such as kickstart) to a given host
    def provisioning_template(opts = {})
      opts[:kind]               ||= "provision"
      opts[:operatingsystem_id] ||= operatingsystem_id
      opts[:hostgroup_id]       ||= hostgroup_id
      opts[:environment_id]     ||= environment_id

      Taxonomy.as_taxonomy(organization, location) do
        ProvisioningTemplate.find_template opts
      end
    end

    def find_templates
      TemplateKind.order(:name).map do |kind|
        provisioning_template(kind: kind.name)
      end.compact
    end

    def available_template_kinds(provisioning = nil)
      kinds = template_kinds(provisioning)
      kinds.map do |kind|
        ProvisioningTemplate.find_template({ :kind               => kind.name,
                                             :operatingsystem_id => operatingsystem_id,
                                             :hostgroup_id       => hostgroup_id,
                                             :environment_id     => environment_id,
        })
      end.compact
    end

    def template_kinds(provisioning = nil)
      return TemplateKind.all unless provisioning == 'image'
      cr_id  = compute_resource_id || hostgroup&.compute_resource_id
      cr     = ComputeResource.find_by_id(cr_id)
      images = cr.try(:images)
      if images.blank?
        [TemplateKind.friendly.find('finish')]
      else
        uuid       = compute_attributes[cr.image_param_name]
        image_kind = images.find_by_uuid(uuid).try(:user_data) ? 'user_data' : 'finish'
        [TemplateKind.friendly.find(image_kind)]
      end
    end

    def templates_used
      result = {}
      available_template_kinds.map do |template|
        result[template.template_kind_name] = template.name
      end
      result
    end

    def jumpstart?
      operatingsystem.family == "Solaris" && architecture.name =~ /Sparc/i rescue false
    end
  end
end
