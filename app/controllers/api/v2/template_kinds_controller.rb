module Api
  module V2
    class TemplateKindsController < V2::BaseController

      api :GET, "/template_kinds/", N_("List all template kinds")
      param :search, String, :desc => N_("filter results"), :required => false
      param :order, String, :desc => N_("sort results"), :required => false
      param :page, String, :desc => N_("paginate results")
      param :per_page, String, :desc => N_("number of entries per request")

      def index
        @template_kinds = TemplateKind.search_for(*search_options).paginate(paginate_options)
      end
    end
  end
end
