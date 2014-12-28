class ConfigTemplatesController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  include Foreman::Renderer
  include Foreman::Controller::ConfigTemplates

  before_filter :handle_template_upload, :only => [:create, :update]
  before_filter :find_resource, :only => [:edit, :update, :destroy, :clone, :lock, :unlock]
  before_filter :load_history, :only => :edit

  def index
    @config_templates = resource_base.search_for(params[:search], :order => params[:order]).paginate(:page => params[:page]).includes(:template_kind, :template_combinations => [:hostgroup, :environment])
  end

  def new
    @config_template = ConfigTemplate.new
  end

  def clone
    @config_template = @config_template.clone
    load_vars_for_form
    flash[:warning] = _("The marked fields will need reviewing")
    @config_template.valid?
    render :action => :new
  end

  def lock
    set_locked true
  end

  def unlock
    set_locked false
  end

  def create
    @config_template = ConfigTemplate.new(foreman_params)
    if @config_template.save
      process_success
    else
      process_error
    end
  end

  def edit
    load_vars_for_form
  end

  def update
    if @config_template.update_attributes(foreman_params)
      process_success
    else
      load_history
      process_error
    end
  end

  def load_vars_for_form
    return unless @config_template

    @locations = @config_template.locations
    @organizations = @config_template.organizations
    @template_kind_id = @config_template.template_kind_id
    @operatingsystems = @config_template.operatingsystems
  end

  def revision
    audit = Audit.find(params[:version])
    render :json => audit.revision.template
  end

  def destroy
    if @config_template.destroy
      process_success
    else
      process_error
    end
  end

  def build_pxe_default
    status, msg = ConfigTemplate.build_pxe_default(self)
    status == 200 ? notice(msg) : error(msg)
    redirect_to :back
  end

  private

  def set_locked(locked)
    @config_template.locked = locked
    if @config_template.save
      process_success :success_msg => (locked ? _('Template locked') : _('Template unlocked')), :success_redirect => :back
    else
      process_error
    end
  end

  def load_history
    return unless @config_template
    @history = Audit.descending.where(:auditable_id => @config_template.id, :auditable_type => 'ConfigTemplate')
  end

  def controller_permission
    'templates'
  end


  def action_permission
    case params[:action]
      when 'lock', 'unlock'
        :lock
      when 'clone'
        :view
      else
        super
    end
  end
end
