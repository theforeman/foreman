module Api
  module V2
    class PuppetclassesController < V2::BaseController
      include Api::Version2
      include Foreman::Controller::Parameters::Puppetclass

      before_action :find_optional_nested_object
      before_action :find_resource, :only => %w{show update destroy}

      api :GET, "/puppetclasses/", N_("List all Puppet classes")
      api :GET, "/hosts/:host_id/puppetclasses", N_("List all Puppet classes for a host")
      api :GET, "/hostgroups/:hostgroup_id/puppetclasses", N_("List all Puppet classes for a host group")
      api :GET, "/environments/:environment_id/puppetclasses", N_("List all Puppet classes for an environment")
      param :host_id, String, :desc => N_("ID of host")
      param :hostgroup_id, String, :desc => N_("ID of host group")
      param :environment_id, String, :desc => N_("ID of environment")
      param_group :search_and_pagination, ::Api::V2::BaseController
      add_scoped_search_description_for(Puppetclass)

      def index
        values   = Puppetclass.authorized(:view_puppetclasses).search_for(*search_options) unless nested_obj
        values ||= case nested_obj
                     when Host::Base, Hostgroup
                       #NOTE: no search_for on array generated by all_puppetclasses
                       nested_obj.all_puppetclasses
                     else
                       nested_obj.puppetclasses.search_for(*search_options)
                   end
        @total   = Puppetclass.count unless nested_obj
        @total ||= case nested_obj
                     when Host::Base, Hostgroup
                       values.count
                     else
                       nested_obj.puppetclasses.count
                   end
        @subtotal = values.count
        if params[:style] == 'list'
          @puppetclasses = values
          render :list
        else
          @puppetclasses = Puppetclass.classes2hash_v2(values.paginate(paginate_options))
        end
      end

      api :GET, "/puppetclasses/:id", N_("Show a Puppet class")
      api :GET, "/hosts/:host_id/puppetclasses/:id", N_("Show a Puppet class for host")
      api :GET, "/hostgroups/:hostgroup_id/puppetclasses/:id", N_("Show a Puppet class for a host group")
      api :GET, "/environments/:environment_id/puppetclasses/:id", N_("Show a Puppet class for an environment")
      param :host_id, String, :desc => N_("ID of host")
      param :hostgroup_id, String, :desc => N_("ID of host group")
      param :environment_id, String, :desc => N_("ID of environment")
      param :id, String, :required => true, :desc => N_("ID of Puppet class")

      def show
      end

      def_param_group :puppetclass do
        param :puppetclass, Hash, :required => true, :action_aware => true do
          param :name, String, :required => true
        end
      end

      api :POST, "/puppetclasses/", N_("Create a Puppet class")
      param_group :puppetclass, :as => :create

      def create
        @puppetclass = Puppetclass.new(puppetclass_params)
        process_response @puppetclass.save
      end

      api :PUT, "/puppetclasses/:id/", N_("Update a Puppet class")
      param :id, String, :required => true
      param_group :puppetclass

      def update
        class_params = puppetclass_params.merge(:smart_class_parameter_ids => @puppetclass.smart_class_parameters.map(&:id))
        process_response @puppetclass.update_attributes(class_params)
      end

      api :DELETE, "/puppetclasses/:id/", N_("Delete a Puppet class")
      param :id, String, :required => true

      def destroy
        process_response @puppetclass.destroy
      end

      private

      def allowed_nested_id
        %w(environment_id host_id hostgroup_id)
      end
    end
  end
end
