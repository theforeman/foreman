class AuditsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch

  before_action :setup_search_options, :only => :index

  def index
    @audits = resource_base_search_and_page.preload(:user)
    render :json => {
      :audits => helpers.construct_additional_info(@audits),
      :itemCount => @audits.count,
    }
  end

  private

  def resource_base(*args)
    super(*args).taxed_and_untaxed
  end

  def controller_permission
    'audit_logs'
  end
end
