class TemplatesController < ApplicationController
  include Foreman::Controller::ProvisioningTemplates
  include Foreman::Controller::AutoCompleteSearch
  include AuditsHelper

  before_action :handle_template_upload, :only => [:create, :update]
  before_action :find_resource, :only => [:edit, :update, :destroy, :clone_template, :lock, :unlock, :export]
  before_action :load_history, :only => :edit
  before_action :type_name_plural, :type_name_singular, :resource_class

  include TemplatePathsHelper

  def index
    @templates = resource_base_search_and_page
    @templates = @templates.includes(resource_base.template_includes)
  end

  def new
    @template = resource_class.new
    @dsl_cache = ApipieDSL.docs
  end

  # we can't use `clone` here, ActionController disables public method that are inherited and present in Base
  # parent classes (so all controllers don't have actions like id, clone, dup, ...), unfortunatelly they don't
  # detect method definitions in controller ancestors, only methods defined directly in child controller
  def clone_template
    @template = @template.dup
    @template.name += ' clone'
    @template.locked = false
    load_vars_from_template
    @template.valid?
    @dsl_cache = ApipieDSL.docs
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
      load_vars_from_template
      @dsl_cache = ApipieDSL.docs
      process_error :object => @template
    end
  end

  def edit
    load_vars_from_template
    @dsl_cache = ApipieDSL.docs
  end

  def update
    if @template.update(resource_params)
      process_success :object => @template
    else
      load_history
      load_vars_from_template
      @dsl_cache = ApipieDSL.docs
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

    template_kind = TemplateKind.find_by(id: params[:template_kind_id]) if params[:template_kind_id]

    unless template_kind&.name == 'registration'
      scope = template_kind&.name == 'host_init_config' ? Template : @template.class
      base  = scope.preview_host_collection
      @host = params[:preview_host_id].present? ? base.find(params[:preview_host_id]) : base.first

      if @host.nil?
        render :plain => _('No host could be found for rendering the template'), :status => :not_found
        return
      end
    end
    @template.template = params[:template]

    renderer = params.delete('force_safemode') ? Foreman::Renderer::SafeModeRenderer : Foreman::Renderer
    safe_render(@template, Foreman::Renderer::PREVIEW_MODE, renderer, escape_json: true)
  end

  def export
    send_data @template.to_erb, :type => 'text/plain', :disposition => 'attachment', :filename => @template.filename
  end

  def resource_class
    @resource_class ||= controller_name.singularize.classify.constantize
  end

  def resource_name
    'template'
  end

  private

  def safe_render(template, mode = Foreman::Renderer::REAL_MODE, renderer = Foreman::Renderer, render_on_error: :plain, **params)
    escape = params.delete :escape_json

    rendered_text = template.render(renderer: renderer, host: @host, params: params, mode: mode, **params)
    rendered_text = rendered_text.to_json if escape
    render :plain => rendered_text
  rescue => error
    Foreman::Logging.exception("Error rendering the #{template.name} template", error)
    if error.is_a?(Foreman::Renderer::Errors::RenderingError)
      text = error.message
    else
      text = _("There was an error rendering the %{name} template: %{error}") % {:name => template.name, :error => error.message}
    end

    if render_on_error == :plain
      render :plain => text, :status => :internal_server_error
    else
      error error.message, :now => true
      render render_on_error, :status => :internal_server_error
    end
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
    @history = Audit.descending
                    .where(:auditable_id => @template.id,
                           :auditable_type => @template.class.base_class.name,
                           :action => %w(update create))
                    .select { |audit| audit_template? audit }
  end

  def action_permission
    case params[:action]
      when 'lock', 'unlock'
        :lock
      when 'clone_template', 'preview', 'export'
        :view
      else
        super
    end
  end

  def type_name_plural
    @type_name_plural ||= type_name_singular.pluralize
  end

  def resource_params
    public_send "#{type_name_singular}_params".to_sym
  end
end
