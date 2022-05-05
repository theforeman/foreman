class ConfigReportsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  include Foreman::Controller::CsvResponder

  before_action :setup_search_options, :only => :index

  def index
    respond_to do |format|
      format.json do
        reports = resource_base_search_and_page(:host)
        render json: {
          itemCount: reports.count,
          reports: reports.map do |r|
            r.attributes.except('metrics', 'created_at', 'updated_at', 'status', 'type').merge(
              can_delete: can_delete?(r),
              can_view: can_view?(r),
              origin: origin_image_path(r),
              applied: r.applied,
              restarted: r.restarted,
              failed: r.failed,
              failed_restarts: r.failed_restarts,
              skipped: r.skipped,
              pending: r.pending
            )
          end,
        }, status: :ok
      end
      format.html do
        @host = resource_finder(Host.authorized(:view_hosts), params[:host_id]) if params[:host_id]
        @config_reports = resource_base_search_and_page(:host)
        render :index
      end
      format.csv do
        @config_reports = resource_base_with_search.preload(:host)
        csv_response(@config_reports)
      end
    end
  end

  def show
    # are we searching for the last report?
    if params[:id] == "last"
      conditions = { :host_id => resource_finder(Host.authorized(:view_hosts), params[:host_id]).try(:id) } if params[:host_id].present?
      params[:id] = resource_base.where(conditions).maximum(:id)
    end

    return not_found if params[:id].blank?

    @config_report = resource_base.includes(:logs => [:message, :source]).find(params[:id])
    @offset = @config_report.reported_at - @config_report.created_at
  end

  def destroy
    @config_report = resource_base.find(params[:id])
    if @config_report.destroy
      process_success(:success_msg => _("Successfully deleted report."), :success_redirect => config_reports_path)
    else
      process_error
    end
  end

  def csv_columns
    [:host, :reported_at, :applied, :restarted, :failed, :failed_restarts, :skipped, :pending]
  end

  private

  def resource_base
    super.my_reports
  end

  def can_delete?(report)
    authorized_for(auth_object: report, authorizer: authorizer, permission: "destroy_#{controller_permission}")
  end

  def can_view?(report)
    authorized_for(auth_object: report, authorizer: authorizer, permission: "view_#{controller_permission}")
  end

  def origin_image_path(report)
    @origin_image_paths ||= {
      Ansible: helpers.image_path('Ansible.png'),
      Puppet: helpers.image_path('Puppet.png'),
    }
    { src: @origin_image_paths[:"#{report.origin}"], label: report.origin }
  end
end
