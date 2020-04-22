class TemplatesController < ApplicationController
  include Foreman::Controller::ProvisioningTemplates
  include Foreman::Controller::AutoCompleteSearch
  include AuditsHelper

  before_action :handle_template_upload, :only => [:create, :update]
  before_action :find_resource, :only => [:edit, :update, :destroy, :clone_template, :lock, :unlock, :export]
  before_action :find_multiple, :only => [:multiple_destroy, :submit_multiple_destroy]
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
    @template.name += ' clone'
    @template.locked = false
    load_vars_from_template
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
    if @template.update(resource_params)
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

  def multiple_destroy
  end

  def submit_multiple_destroy
    missed_templates = @templates.select { |template| !template.destroy }
    if missed_templates.empty?
      success _('Deleted selected templates')
    else
      error _('The following templates were not deleted: %s') % missed_templates.map(&:name).to_sentence
    end
    redirect_to(saved_redirect_url_or(send("#{controller_name}_url")))
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
    base = @template.class.preview_host_collection
    @host = params[:preview_host_id].present? ? base.find(params[:preview_host_id]) : base.first
    if @host.nil?
      render :plain => _('No host could be found for rendering the template'), :status => :not_found
      return
    end
    @template.template = params[:template]
    safe_render(@template, Foreman::Renderer::PREVIEW_MODE, escape_json: true)
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

  def find_multiple
    if params.key?(:template_names) || params.key?(:template_ids) || params.key?(:search)
      @templates = resource_base.search_for(params[:search]) if params.key?(:search)
      @templates ||= resource_base.where("templates.id IN (?) or templates.name IN (?)", params[:template_ids], params[:template_names])
      if @templates.empty?
        error _('No templates were found with that id, name or query filter')
        redirect_to(templates_path)
        return false
      end
    else
      error _('No templates selected')
      redirect_to(templates_path)
      return false
    end

    @templates
  rescue => error
    message = _("Something went wrong while selecting templates - %s") % error
    error(message)
    Foreman::Logging.exception(message, error)
    redirect_to templates_path
    false
  end

  def safe_render(template, mode = Foreman::Renderer::REAL_MODE, render_on_error: :plain, **params)
    escape = params.delete :escape_json
    rendered_text = template.render(host: @host, params: params, mode: mode, **params)
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
      when 'multiple_destroy', 'submit_multiple_destroy'
        :destroy
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
