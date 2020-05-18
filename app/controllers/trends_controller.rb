class TrendsController < ApplicationController
  include Foreman::Controller::Parameters::Trend

  before_action :find_resource, :only => [:show, :edit, :update, :destroy]

  def index
    @trends = Trend.types.includes(:trendable).sort_by { |e| e.type_name.downcase }.paginate(:page => params[:page], :per_page => params[:per_page])
  end

  def new
    @trend = Trend.new
  end

  def show
    render 'trends/_empty_data' if @trend.values.joins(:trend_counters).empty?
  end

  def create
    @trend = Trend.build_trend(trend_params)
    if @trend.save
      process_success
    else
      process_error
    end
  end

  def update
    filter = self.class.trend_params_filter
    trend_attrs = params[:trend].values.map { |t| filter.filter_params(ActionController::Parameters.new(t), parameter_filter_context, :none) }
    @trends = Trend.update(params[:trend].keys, trend_attrs).reject { |p| p.errors.empty? }
    if @trends.empty?
      process_success
    else
      process_error
    end
  end

  def edit
  end

  def destroy
    if @trend.destroy
      process_success
    else
      process_error
    end
  end

  def count
    ForemanStatistics::TrendImporter.update!
    redirect_to trends_url
  end
end
