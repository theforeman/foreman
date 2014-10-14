module Api
  module V2
    class ManyToManyController < V2::BaseController

      include Api::Version2
      include Api::TaxonomyScope
      skip_before_filter :setup_has_many_params

      before_filter :ensure_association_is_allowed
      before_filter :find_required_nested_object
      before_filter :find_associated_objects_to_add, :only => :create
      before_filter :find_associated_objects_to_remove, :only => :destroy

      def create
        if @associated_objects.any?
          @nested_obj.send(params[:association]) << @associated_objects
          logger.info "Added #{@associated_objects.first.class.to_s} ids #{@associated_objects.pluck(:id).join(', ')} to #{@nested_obj.class.to_s} #{@nested_obj.id}"
          render :json => {}, :status => 204
        else
          error_msg = _("Resource %{association_class} not found for id %{param_id}") % { :association_class => params[:association].classify, :param_id => params[params[:association]] }
          logger.error error_msg
          render :json => {:message => error_msg}, :status => :unprocessable_entity, :layout => 'api/v2/layouts/error_layout'
        end
      end

      def destroy
        if @associated_objects.any?
          @nested_obj.send(params[:association]).delete(@associated_objects)
          logger.info "Removed #{@associated_objects.first.class.to_s} ids #{@associated_objects.pluck(:id).join(', ')} from #{@nested_obj.class.to_s} #{@nested_obj.id} if association previously existed"
          render :json => {}, :status => 204
        else
          error_msg = _("Resource %{association_class} not found for id %{param_id}") % { :association_class => params[:association].classify, :param_id => params[:id] }
          logger.error error_msg
          render :json => {:message => error_msg}, :status => :unprocessable_entity, :layout => 'api/v2/layouts/error_layout'
        end
      end

      private

      def find_associated_objects_to_add
        if params.keys.any? { |k| k == params[:association] }
          key = params[:association]
          ids = params[key]
          find_associated(key, ids)
        else
          raise _("You must pass a parameter '%{association}' with value that is an integer or array of integers") % { :association => params[:association] }
        end
      end

      def find_associated_objects_to_remove
        key = params[:association]
        ids = params[:id]
        find_associated(key, ids)
      end

      def find_associated(key, ids)
        ids = ids.to_s if ids.kind_of?(Integer)
        ids = ids.split(',') if ids.kind_of?(String) #convert to Array in case of a comma-delimitted string ("1,2,3") or number string ("2") rather than Array
        ids = Array(ids).map(&:to_i) #convert array of strings to arrange of integers. Note: "string".to_i = 0
        if ids.all? { |p| p > 0 }
          model = key.classify.constantize
          @associated_objects = model.where(:id => ids)
        else
          raise _("%{key} values must be an integer or array of integers") % {:key => key}
        end
      end

      def allowed_nested_id
        allowed_associations.keys
      end

      def allowed_associations
        {'architecture_id' => ['operatingsystems'],
         'compute_resource_id' => ['locations', 'organizations'],
         'config_template_id' => ['operatingsystems', 'locations', 'organizations'],
         'domain_id' => ['subnets', 'locations', 'organizations'],
         'environment_id' => ['locations', 'organizations'],
         'host_id' => ['puppetclasses', 'config_groups'],
         'hostgroup_id' => ['locations', 'organizations', 'puppetclasses', 'config_groups'],
         'location_id' => ['users', 'smart_proxies', 'subnets', 'compute_resources', 'media', 'config_templates', 'domains',
                         'realms', 'environments', 'hostgroups', 'organizations'],
         'medium_id' => ['operatingsystems', 'locations', 'organizations'],
         'operatingsystem_id' => ['architectures', 'ptables', 'media', 'config_templates'],
         'organization_id' => ['users', 'smart_proxies', 'subnets', 'compute_resources', 'media', 'config_templates', 'domains',
                         'realms', 'environments', 'hostgroups', 'locations'],
         'ptable_id' => ['operatingsystems'],
         'realm_id' => ['locations', 'organizations'],
         'role_id' => ['users', 'usergroups'],
         'smart_proxy_id' => ['locations', 'organizations'],
         'subnet_id' => ['domains', 'locations', 'organizations'],
         'usergroup_id' => ['roles', 'users'],
         'user_id' => ['roles', 'usergroups', 'locations', 'organizations']
        }
      end

      def resource_identifying_attributes
        %w(id)
      end

      def ensure_association_is_allowed
        params.keys.each do |key|
          if key.match(/(\w+)_id$/)
            allowed = allowed_associations[key]
            raise ActionController::RoutingError.new(_("route not found")) unless allowed.include?(params[:association])
          end
        end
      end

    end
  end
end
