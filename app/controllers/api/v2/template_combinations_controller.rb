module Api
  module V2
    class TemplateCombinationsController < V2::BaseController
      include Foreman::Renderer

      before_filter :find_resource, :only => [:show, :destroy]
      before_filter :find_parent_config_template, :only => [:index, :create]

      api :GET, "/config_templates/:config_template_id/template_combinations", "List Template Combination"
      param :config_template_id, :identifier, :required => true
      def index
        @template_combinations = @config_template.template_combinations
      end

      api :POST, "/config_templates/:config_template_id/template_combinations", "Add a Template Combination"
      param :config_template_id, :identifier, :required => true
      param :template_combination, Hash, :required => true do
        param :environment_id, :number, :allow_nil => true, :desc => "environment id"
        param :hostgroup_id, :number, :allow_nil => true, :desc => "hostgroup id"
      end

      def create
        @template_combination = @config_template.template_combinations.build(params[:template_combination])
        process_response @template_combination.save
      end

      api :GET, "/template_combinations/:id", "Show Template Combination"
      param :id, :identifier, :required => true
      def show
      end
      
      api :DELETE, "/template_combinations/:id", "Delete a template"
      param :id, :identifier, :required => true

      def destroy
        process_response @template_combination.destroy
      end

      def find_parent_config_template
        @config_template = ConfigTemplate.find(params[:config_template_id])
        unless @config_template
          render_error 'not_found', :status => :not_found and return false
        end
        @config_template
      end
    end
  end
end
