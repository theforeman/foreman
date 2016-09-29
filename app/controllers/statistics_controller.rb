class StatisticsController < ApplicationController
  before_action :find_stat, :only => [:show]

  def index
    @stats = charts
  end

  def show
    render :show, :layout => false
  end

  private

  def find_stat
    @stat = charts.detect{|ch| ch.id.to_s == params[:id]}
    @stat || not_found
  end

  def charts
    ::Statistics.charts
  end
end
