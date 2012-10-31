class TrendsController < ApplicationController
  before_filter :find_trend, :only => %w{show edit update destroy}

  def index
    @trends = Trend.group(:trendable_type, :fact_name).where(:fact_value => nil).includes(:trendable).paginate(:page => params[:page])
  end

  def new
    @trend = Trend.new
  end

  def show
  end

  def create
    params[:trend] ||= { }
    @trend         = params[:trend][:trendable_type] == 'FactName' ? FactTrend.new(params[:trend]) : ForemanTrend.new(params[:trend])
    if @trend.save
      process_success
    else
      process_error
    end
  end

  def update
    if @trend.update_attributes(params[:trend])
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

  private
  def find_trend
    @trend = Trend.includes(:trendable).find(params[:id])
  end

end
