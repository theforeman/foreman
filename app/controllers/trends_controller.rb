class TrendsController < ApplicationController
  before_filter :find_resource, :only => [:show, :edit, :update, :destroy]

  def index
    @trends = Trend.types.includes(:trendable).sort_by {|e| e.type_name.downcase }.paginate(:page => params[:page])
  end

  def new
    @trend = Trend.new
  end

  def show
  end

  def create
    params[:trend] ||= { }
    @trend         = params[:trend][:trendable_type] == 'FactName' ? FactTrend.new(foreman_params) : ForemanTrend.new(foreman_params)
    if @trend.save
      process_success
    else
      process_error
    end
  end

  def update
    @trends = Trend.update(params[:trend].keys, params[:trend].values).reject { |p| p.errors.empty? }
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
    TrendImporter.update!
    redirect_to trends_url
  end
end
