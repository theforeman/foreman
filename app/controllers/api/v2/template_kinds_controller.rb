module Api
  module V2
    class TemplateKindsController < V2::BaseController

      api :GET, "/template_kinds/", "List all template kinds."
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def index
        @template_kinds = TemplateKind.paginate(paginate_options)
      end
    end
  end
end
