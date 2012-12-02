module Api
  module V1
    class TemplateKindsController < V1::BaseController

      api :GET, "/template_kinds/", "List all template kinds."
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def index
        @template_kinds = TemplateKind.all.paginate(paginate_options)
      end
    end
  end
end
