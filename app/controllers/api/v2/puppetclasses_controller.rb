module Api
  module V2
    class PuppetclassesController < V1::PuppetclassesController

      include Api::Version2
      include Api::TaxonomyScope

      before_filter :find_nested_object, :only => [:index, :show]

      api :GET, "/puppetclasses/", "List all puppetclasses."
      api :GET, "/hosts/:host_id/puppetclasses", "List all puppetclasses for host"
      api :GET, "/hostgroups/:hostgroup_id/puppetclasses", "List all puppetclasses for hostgroup"
      api :GET, "/environments/:environment_id/puppetclasses", "List all puppetclasses for environment"
      param :host_id, String, :desc => "id of nested host"
      param :hostgroup_id, String, :desc => "id of nested hostgroup"
      param :environment_id, String, :desc => "id of nested environment"

      def index
        return super unless @nested_obj
        if @nested_obj.kind_of?(Environment)
          values = @nested_obj.puppetclasses
        else
          values = @nested_obj.all_puppetclasses
        end
        render :json => Puppetclass.classes2hash(values)
      end

      api :GET, "/puppetclasses/:id", "Show a puppetclass"
      api :GET, "/hosts/:host_id/puppetclasses/:id", "Show a puppetclass for host"
      api :GET, "/hostgroups/:hostgroup_id/puppetclasses/:id", "Show a puppetclass for hostgroup"
      api :GET, "/environments/:environment_id/puppetclasses/:id", "Show a puppetclass for environment"
      param :host_id, String, :desc => "id of nested host"
      param :hostgroup_id, String, :desc => "id of nested hostgroup"
      param :environment_id, String, :desc => "id of nested environment"
      param :id, String, :required => true, :desc => "id of puppetclass"

      def show
        if @nested_obj
          @puppetclass = @nested_obj.puppetclasses.find(params[:id])
        end
      end

      private
      attr_reader :nested_obj

      def find_nested_object
        params.keys.each do |param|
          if param =~ /(\w+)_id$/
            resource_identifying_attributes.each do |key|
              find_method = "find_by_#{key}"
              @nested_obj ||= $1.classify.constantize.send(find_method, params[param])
            end
          end
        end
        return @nested_obj
      end

    end
  end
end
