class ConfigTemplatesController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  include Foreman::Renderer

  before_filter :load_history, :only => :edit
  before_filter :handle_template_upload, :only => [:create, :update]

  def index
    @config_templates = ConfigTemplate.authorized(:view_templates).search_for(params[:search], :order => params[:order]).paginate(:page => params[:page]).includes(:template_kind, :template_combinations => [:hostgroup, :environment])
  end

  def new
    @config_template = ConfigTemplate.new
  end

  def create
    @config_template = ConfigTemplate.new(params[:config_template])
    if @config_template.save
      process_success
    else
      process_error
    end
  end

  def edit
    @config_template = find_by_id(:edit_templates)
  end

  def update
    @config_template = find_by_id(:edit_templates)
    if @config_template.update_attributes(params[:config_template])
      process_success
    else
      load_history
      process_error
    end
  end

  def revision
    audit = Audit.find(params[:version])
    render :json => audit.revision.template
  end

  def destroy
    @config_template = find_by_id(:destroy_templates)
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

  # convert the file upload into a simple string to save in our db.
  def handle_template_upload
    return unless params[:config_template] and (t=params[:config_template][:template])
    params[:config_template][:template] = t.read if t.respond_to?(:read)
  end

  def load_history
    return unless @config_template
    @history = Audit.descending.where(:auditable_id => @config_template.id, :auditable_type => 'ConfigTemplate')
  end

  def default_template_url template, hostgroup
    url_for :only_path => false, :action => :template, :controller => '/unattended',
      :id => template.name, :hostgroup => hostgroup.name
  end

  def find_by_id(permission = :view_templates)
    ConfigTemplate.authorized(permission).find(params[:id])
  end
end
