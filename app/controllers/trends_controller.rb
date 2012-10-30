class TrendsController < ApplicationController

  def index
    @trends  = Trend.group(:trendable_type, :fact_name).where(:fact_value => nil)
  end

  def new
    @trend = Trend.new
  end

  def show
    trend = Trend.find(params[:id])
    if trend.fact_value == nil
      opts = trend.is_a?(FactTrend) ? {:trendable_id => trend.trendable_id} : {}
      @trends= Trend.has_value.where(opts.merge(:trendable_type => trend.trendable_type))
      @title = "#{trend.type_name.camelcase}"
    else # Display Single Trend
      @trends= Trend.has_value.where(:id => trend.id)
      @hosts = trend.is_a?(FactTrend) ? FactValue.my_facts.no_timestamp_facts.search_for(params[:search]).required_fields : trend.trendable.hosts
      @title = "#{trend.type_name.camelcase} - #{trend.fact_value}"
    end
    @range = (params["range"].empty? ? 30 : params["range"].to_i)
  end

  def create
    return unless params[:trend]

    @trend = params[:trend][:trendable_type] == 'FactName' ? FactTrend.new(params[:trend]) : ForemanTrend.new(params[:trend])
    @trend.fact_name = FactName.find(@trend.trendable_id).name if @trend.is_a?(FactTrend) && @trend.trendable_id
    if @trend.save
      process_success
    else
      process_error
    end
  end

  def update
    @trend = Trend.find(params[:id])
    if @trend.update_attributes(params[:trend])
      process_success
    else
      process_error
    end
  end

  def edit
    @trend = Trend.find(params[:id])
  end

  def destroy
    @trend = Trend.find(params[:id])

    if @trend.destroy
      notice "Successfully destroyed trend."
    else
      error @trend.errors.full_messages.join("<br/>")
    end

    redirect_to trends_url
  end

  def count
    TrendImporter.update!
    redirect_to trends_url
  end
end
