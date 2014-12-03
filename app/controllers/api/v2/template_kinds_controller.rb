module Api
  module V2
    class TemplateKindsController < V2::BaseController

      api :GET, "/template_kinds/", N_("List all template kinds")
      param_group :search_and_pagination, ::Api::V2::BaseController

      def index
        @template_kinds = TemplateKind.search_for(*search_options).paginate(paginate_options)
      end
    end
  end
end
