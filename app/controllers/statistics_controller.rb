class StatisticsController < ApplicationController
  before_action :find_stat, :only => [:show]

  def index
    @metadata = charts.map(&:metadata)
  end

  def show
    respond_to do |format|
      format.json do
        render :json => {:id => @stat.id, :data => @stat.calculate.map(&:values)}
      end
    end
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
