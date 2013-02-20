module Api
  module V2
    class ConfigTemplatesController < V1::ConfigTemplatesController
      include Api::Version2
      include Api::TaxonomyScope

      before_filter :process_operatingsystems, :only => [:create, :update]

      def index
        super
        render :template => "api/v1/config_templates/index"
      end

      def show
        super
        render :template => "api/v1/config_templates/show"
      end

      def process_operatingsystems
        return unless (ct = params[:config_template]) and (operatingsystems = ct.delete(:operatingsystems))
        ct[:operatingsystem_ids] = operatingsystems.collect {|os| os[:id]}
      end

    end
  end
end
