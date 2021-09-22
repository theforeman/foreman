module Api::ImportPuppetclassesCommonController
  extend ActiveSupport::Concern

  included do
    prepend_before_action :fail_and_inform_about_plugin, only: :import_puppetclasses
  end

  def resource_human_name
    resource_class.model_name.name
  end

  def fail_and_inform_about_plugin
    render json: { message: _('To access import_puppetclasses API you need to install the Foreman Puppet plugin')}, status: :not_implemented
  end

  extend Apipie::DSL::Concern

  api :POST, "/smart_proxies/:id/import_puppetclasses", N_("Import puppet classes from puppet proxy")
  api :POST, "/smart_proxies/:smart_proxy_id/environments/:id/import_puppetclasses", N_("Import puppet classes from puppet proxy for an environment")
  api :POST, "/environments/:environment_id/smart_proxies/:id/import_puppetclasses", N_("Import puppet classes from puppet proxy for an environment")
  param :id, :identifier, :required => true
  param :smart_proxy_id, String, :required => false
  param :environment_id, String, :required => false
  param :dryrun, :bool, :required => false
  param :except, String, :required => false, :desc => N_("Optional comma-delimited string containing either 'new', 'updated', or 'obsolete' that is used to limit the imported Puppet classes")

  def import_puppetclasses
  end
end
