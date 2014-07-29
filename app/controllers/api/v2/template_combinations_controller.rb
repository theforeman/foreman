module Api
  module V2
    class TemplateCombinationsController < V2::BaseController
      before_filter :find_resource, :only => [:show, :destroy]
      before_filter :find_parent_config_template, :only => [:index, :create]

      api :GET, "/config_templates/:config_template_id/template_combinations", N_("List template combination")
      param :config_template_id, :identifier, :required => true
      def index
        @template_combinations = @config_template.template_combinations
        @total = @template_combinations.count
      end

      api :POST, "/config_templates/:config_template_id/template_combinations", N_("Add a template combination")
      param :config_template_id, :identifier, :required => true
      param :template_combination, Hash, :required => true do
        param :environment_id, :number, :allow_nil => true, :desc => N_("environment id")
        param :hostgroup_id, :number, :allow_nil => true, :desc => N_("host group id")
      end

      def create
        @template_combination = @config_template.template_combinations.build(params[:template_combination])
        process_response @template_combination.save
      end

      api :GET, "/template_combinations/:id", N_("Show template combination")
      param :id, :identifier, :required => true
      def show
      end

      api :DELETE, "/template_combinations/:id", N_("Delete a template combination")
      param :id, :identifier, :required => true

      def destroy
        process_response @template_combination.destroy
      end

      def find_parent_config_template
        @config_template = ConfigTemplate.authorized(:view_templates).find(params[:config_template_id])
        not_found unless @config_template
        @config_template
      end
    end
  end
end
