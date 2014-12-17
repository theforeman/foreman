class PuppetclassesController < ApplicationController
  include Foreman::Controller::Environments
  include Foreman::Controller::AutoCompleteSearch
  before_filter :find_resource, :only => [:edit, :update, :destroy, :override]
  before_filter :setup_search_options, :only => :index

  def index
    @puppetclasses = resource_base.search_for(params[:search], :order => params[:order]).includes(:config_group_classes, :class_params, :environments, :hostgroups).paginate(:page => params[:page])
    @hostgroups_authorizer = Authorizer.new(User.current, :collection => HostgroupClass.where(:puppetclass_id => @puppetclasses.map(&:id)).to_a.compact.uniq.map(&:hostgroup_id))
  end

  def edit
  end

  def update
    if @puppetclass.update_attributes(foreman_params)
      process_success
    else
      process_error
    end
  end

  def destroy
    if @puppetclass.destroy
      process_success
    else
      process_error
    end
  end

  def override
    if @puppetclass.class_params.present?
      @puppetclass.class_params.each do |class_param|
        class_param.update_attribute(:override, params[:enable])
      end
      if [true, :true, 'true'].include?(params[:enable])
        notice _("Successfully overridden all parameters of Puppet class %s") % @puppetclass.name
      else
        notice _("Successfully reset all parameters of Puppet class %s to their default values") % @puppetclass.name
      end
    else
      error _("No parameters to override for Puppet class %s") % @puppetclass.name
    end
    redirect_to puppetclasses_url
  end

  # form AJAX methods
  def parameters
    puppetclass = Puppetclass.find(params[:id])
    render :partial => "puppetclasses/class_parameters",
           :locals => { :puppetclass => puppetclass,
                        :obj         => get_host_or_hostgroup }
  end

  private

  def get_host_or_hostgroup
    # params['host_id'] = 'null' if NEW since hosts/form and hostgroups/form has data-id="null"
    if params['host_id'] == 'null'
      @obj = Host::Managed.new(params.require(:host).permit(permitted_host_attributes)) if params['host']
      @obj ||= Hostgroup.new(params.require(:hostgroup).permit(permitted_hostgroup_attributes)) if params['hostgroup']
    else
      if params['host']
        @obj = Host::Base.friendly.find(params['host_id'])
        unless @obj.is_a?(Host::Managed)
          @obj      = @obj.becomes(Host::Managed)
          @obj.type = "Host::Managed"
        end
        # puppetclass_ids and config_group_ids need to be removed so they don't cause automatic inserts
        @obj.attributes = params.require(:host).permit(permitted_host_attributes).except!(:puppetclass_ids, :config_group_ids)
      elsif params['hostgroup']
        # hostgroup.id is assigned to params['host_id'] by host_edit.js#load_puppet_class_parameters
        @obj = Hostgroup.find(params['host_id'])
        @obj.attributes = params.require(:hostgroup).permit(permitted_hostgroup_attributes).except!(:puppetclass_ids, :config_group_ids)
      end
    end
    @obj
  end

  def action_permission
    case params[:action]
      when 'override'
        :override
      else
        super
    end
  end
end
