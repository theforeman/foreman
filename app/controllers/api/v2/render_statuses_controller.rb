module Api
  module V2
    class RenderStatusesController < V2::BaseController
      api :GET, "/hosts/:host_id/render_statuses/", N_("List all render statuses for a given host")
      api :GET, "/hostgroups/:host_id/render_statuses/", N_("List all render statuses for a given hostgroup")
      api :GET, "/provisioning_templates/:provisioning_template_id/render_statuses/", N_("List all render statuses for a given provisioning template")

      param :host_id, :identifier, desc: N_("ID of host")
      param :hostgroup_id, :identifier, desc: N_("ID of hostgroup")
      param :provisioning_template_id, :identifier, desc: N_("ID of provisioning template")
      param_group :search_and_pagination, ::Api::V2::BaseController
      add_scoped_search_description_for(RenderStatus)

      def index
        @render_statuses = resource_scope_for_index.includes(:host, :hostgroup, :provisioning_template)
      end
    end
  end
end
