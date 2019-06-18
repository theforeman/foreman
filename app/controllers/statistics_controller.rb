class StatisticsController < ApplicationController
  before_action :find_stat, :only => [:show]

  def index
    render :json => charts.map(&:metadata)
  end

  def show
    render :json => {:id => @stat.id, :data => @stat.calculate.map(&:values)}
  end

  private

  def find_stat
    @stat = charts.detect {|ch| ch.id.to_s == params[:id]}
    @stat || not_found
  end

  def charts
    ::Statistics.charts(Organization.current.try(:id), Location.current.try(:id))
  end
end
