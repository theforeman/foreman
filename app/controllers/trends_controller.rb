class TrendsController < ApplicationController
  before_filter :find_trend, :only => %w{show edit update destroy}

  def index
    @trends = Trend.group(:trendable_type, :fact_name).where(:fact_value => nil).includes(:trendable).sort_by {|e| e.type_name.downcase }.paginate(:page => params[:page])
  end

  def new
    @trend = Trend.new
  end

  def show
    if @trend.fact_value == nil
      @title = "#{@trend.type_name.camelcase}"
    else # Display single Trend
      @trends= Trend.has_value.where(:id => @trend.id)
      if @trend.is_a?(FactTrend)
        @hosts = FactValue.my_facts.no_timestamp_facts.search_for(params[:search]).required_fields.sort_by {|e| e.host }
      else
        @hosts = @trend.trendable.hosts.find(:all, :order => 'name')
      end
      @title = "#{@trend.type_name.camelcase} - #{@trend.fact_value}"
    end
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
    @trend = Trend.find(params[:id])
    @trends = Trend.includes(:trendable).find(params[:id]).values
  end

end
