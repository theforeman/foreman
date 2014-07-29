module Api
  module V2
    class TemplateKindsController < V2::BaseController

      api :GET, "/template_kinds/", N_("List all template kinds")
      param :page, String, :desc => N_("paginate results")
      param :per_page, String, :desc => N_("number of entries per request")

      def index
        @template_kinds = TemplateKind.paginate(paginate_options)
      end
    end
  end
end
