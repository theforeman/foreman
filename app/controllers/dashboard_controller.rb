class DashboardController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  include Foreman::Controller::Parameters::Widget

  before_action :prefetch_data, :only => :index
  before_action :find_resource, :only => [:destroy]
  skip_before_action :welcome

  def index
    respond_to do |format|
      format.html
      format.yaml { render :text => @report.to_yaml }
      format.json
    end
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
      format.json {render :json => params[:id], :status => status}
    end
  end

  def reset_default
    Dashboard::Manager.reset_user_to_default(User.current)
    redirect_to root_path
  end

  def save_positions
    errors = []
    filter = self.class.widget_params_filter
    params[:widgets].each do |id, values|
      widget = User.current.widgets.where("id = #{id}").first
      values = filter.filter_params(values, parameter_filter_context, :none)
      errors << widget.errors unless widget.update_attributes(values)
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

  private

  def prefetch_data
    dashboard = Dashboard::Data.new(params[:search])
    @hosts    = dashboard.hosts
    @report   = dashboard.report
    @latest_events = dashboard.latest_events
  end

  def resource_name
    "widget"
  end
end
