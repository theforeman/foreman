class TemplatesController < ApplicationController
  include UnattendedHelper # includes also Foreman::Renderer
  include Foreman::Controller::ProvisioningTemplates
  include Foreman::Controller::AutoCompleteSearch

  before_action :handle_template_upload, :only => [:create, :update]
  before_action :find_resource, :only => [:edit, :update, :destroy, :clone_template, :lock, :unlock]
  before_action :load_history, :only => :edit
  before_action :type_name_plural, :type_name_singular, :resource_class

  include TemplatePathsHelper

  def index
    @templates = resource_base_search_and_page
    @templates = @templates.includes(resource_base.template_includes)
  end

  def new
    @template = resource_class.new
  end

  # we can't use `clone` here, ActionController disables public method that are inherited and present in Base
  # parent classes (so all controllers don't have actions like id, clone, dup, ...), unfortunatelly they don't
  # detect method definitions in controller ancestors, only methods defined directly in child controller
  def clone_template
    @template = @template.dup
    @template.locked = false
    load_vars_from_template
    flash[:warning] = _("The marked fields will need reviewing")
    @template.valid?
    render :action => :new
  end

  def lock
    set_locked true
  end

  def unlock
    set_locked false
  end

  def create
    @template = resource_class.new(resource_params)
    if @template.save
      process_success :object => @template
    else
      process_error :object => @template
    end
  end

  def edit
    load_vars_from_template
  end

  def update
    if @template.update_attributes(resource_params)
      process_success :object => @template
    else
      load_history
      process_error :object => @template
    end
  end

  def revision
    audit = Audit.find(params[:version])
    render :json => audit.revision.template
  end

  def destroy
    if @template.destroy
      process_success :object => @template
    else
      process_error :object => @template
    end
  end

  def auto_complete_controller_name
    type_name_plural
  end

  def preview
    # Not using before_action :find_resource method because we have enabled preview to work for unsaved templates hence no resource could be found in those cases
    if params[:id]
      find_resource
    else
      @template = resource_class.new(params[type_name_plural])
    end
    base = @template.preview_host_collection
    @host = params[:preview_host_id].present? ? base.find(params[:preview_host_id]) : base.first
    if @host.nil?
      render :text => _('No host could be found for rendering the template'), :status => :not_found
      return
    end
    @template.template = params[:template]
    safe_render(@template)
  end

  private

  def safe_render(template)
    load_template_vars
    render :text => unattended_render(template)
  rescue => error
    Foreman::Logging.exception("Error rendering the #{template.name} template", error)
    render :text => _("There was an error rendering the %{name} template: %{error}") % {:name => template.name, :error => error.message},
           :status => :internal_server_error
  end

  def set_locked(locked)
    @template.locked = locked
    if @template.save
      process_success :success_msg => (locked ? _('Template locked') : _('Template unlocked')), :success_redirect => :back, :object => @template
    else
      process_error :object => @template
    end
  end

  def load_history
    return unless @template
    @history = Audit.descending.where(:auditable_id => @template.id, :auditable_type => @template.class.base_class, :action => 'update')
  end

  def action_permission
    case params[:action]
      when 'lock', 'unlock'
        :lock
      when 'clone_template', 'preview'
        :view
      else
        super
    end
  end

  def resource_name
    'template'
  end

  def resource_class
    @resource_class ||= controller_name.singularize.classify.constantize
  end

  def type_name_plural
    @type_name_plural ||= type_name_singular.pluralize
  end

  def resource_params
    public_send "#{type_name_singular}_params".to_sym
  end
end
