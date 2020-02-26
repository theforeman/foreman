class DashboardController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  include Foreman::Controller::Parameters::Widget

  before_action :init_widget_data, :only => :show
  before_action :find_resource, :only => [:show, :destroy]
  skip_before_action :welcome

  def index
    respond_to do |format|
      format.html
      format.yaml { render :plain => @report.to_yaml }
      format.json
    end
  end

  def show
    if @widget.present? && @widget.user == User.current
      render(:partial => @widget.template, :locals => @widget.data)
    else
      render_403 "User #{User.current} attempted to access another user's widget"
    end
  rescue ActionView::MissingTemplate, ActionView::Template::Error => exception
    process_ajax_error exception, "load widget"
  end

  def create
    widget = Dashboard::Manager.find_default_widget_by_name(params[:name])
    unless widget.present?
      not_found
      return
    end
    Dashboard::Manager.add_widget_to_user(User.current, widget.first)
    render :json => { :name => params[:name] }, :status => :ok
  end

  def destroy
    if @widget.present? && @widget.user == User.current
      User.current.widgets.destroy(@widget)
      status = :ok
    else
      status = :forbidden
      logger.warn "#{User.current} attempted to remove widget id #{params[:id]} and failed."
    end
    respond_to do |format|
      format.json { render :json => params[:id], :status => status }
    end
  end

  def reset_default
    Dashboard::Manager.reset_user_to_default(User.current)
    redirect_to root_path
  end

  def save_positions
    errors = []
    filter = self.class.widget_params_filter
    params.fetch(:widgets, []).each do |id, values|
      widget = User.current.widgets.where(:id => id).first
      values = filter.filter_params(values, parameter_filter_context, :none)
      errors << widget.errors unless widget.update(values)
    end
    respond_to do |format|
      if errors.empty?
        format.json { render :json => {}, :status => :ok }
      else
        format.json { render :json => errors, :status => :bad_request }
      end
    end
  rescue => exception
    process_ajax_error exception, 'save positions'
  end

  def resource_name
    "widget"
  end

  private

  def init_widget_data
    find_resource unless @widget
    @data = Dashboard::Data.new(params[:search], @widget.data[:settings])
  end
end
