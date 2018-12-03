class AuditsController < ReactController
  include Foreman::Controller::AutoCompleteSearch

  before_action :setup_search_options, :only => :index

  def index
    @audits = resource_base_search_and_page.preload(:user)
    @host = resource_finder(Host.authorized(:view_hosts), params[:host_id]) if params[:host_id]
  end

  private

  def resource_base(*args)
    super(*args).taxed_and_untaxed
  end

  def controller_permission
    'audit_logs'
  end
end
