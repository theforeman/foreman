class PuppetclassesController < ApplicationController
  include Foreman::Controller::Environments
  include Foreman::Controller::AutoCompleteSearch
  before_filter :find_resource, :only => [:edit, :update, :destroy, :override]
  before_filter :setup_search_options, :only => :index
  before_filter :reset_redirect_to_url, :only => :index
  before_filter :store_redirect_to_url, :only => :edit

  def index
    @puppetclasses = resource_base.search_for(params[:search], :order => params[:order]).includes(:environments, :hostgroups).paginate(:page => params[:page])
    @hostgroups_authorizer = Authorizer.new(User.current, :collection => HostgroupClass.find_all_by_puppetclass_id(@puppetclasses.map(&:id)).compact.uniq.map(&:hostgroup_id))
  end

  def edit
  end

  def update
    if @puppetclass.update_attributes(params[:puppetclass])
      notice _("Successfully updated %s." % @puppetclass.to_s)
      redirect_back_or_default(puppetclasses_url)
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
      @obj = Host::Managed.new(params['host']) if params['host']
      @obj ||= Hostgroup.new(params['hostgroup']) if params['hostgroup']
    else
      if params['host']
        @obj = Host::Base.find(params['host_id'])
        unless @obj.kind_of?(Host::Managed)
          @obj      = @obj.becomes(Host::Managed)
          @obj.type = "Host::Managed"
        end
        # puppetclass_ids and config_group_ids need to be removed so they don't cause automatic inserts
        @obj.attributes = params['host'].except!(:puppetclass_ids, :config_group_ids)
      elsif params['hostgroup']
        # hostgroup.id is assigned to params['host_id'] by host_edit.js#load_puppet_class_parameters
        @obj = Hostgroup.find(params['host_id'])
        @obj.attributes = params['hostgroup'].except!(:puppetclass_ids, :config_group_ids)
      end
    end
    @obj
  end

  def reset_redirect_to_url
    session[:redirect_to_url] = nil
  end

  def store_redirect_to_url
    session[:redirect_to_url] ||= request.referer
  end

  def redirect_back_or_default(default)
    redirect_to(session[:redirect_to_url] || default)
    session[:redirect_to_url] = nil
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
