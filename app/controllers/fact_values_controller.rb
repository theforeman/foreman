class FactValuesController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  include Foreman::Controller::CsvResponder

  before_action :setup_search_options, :only => :index

  def index
    base = resource_base
    begin
      values = base.my_facts.search_for(params[:search], :order => params[:order])
    rescue => e
      error e.to_s
      values = base.search_for ""
    end

    conds = (original_search_parameter || '').split(/AND|OR/i)
    conds = conds.flatten.reject { |c| c.include?('host') }

    if (parent = params[:parent_fact]).present? && (@parent = ::FactName.where(:name => parent)).present?
      values = values.with_fact_parent_id(@parent.map(&:id))
      @parent = @parent.first
    elsif conds.present?
      values
    else
      values = values.root_only
    end

    @fact_values = values.no_timestamp_facts

    respond_to do |format|
      format.html do
        @fact_values = @fact_values.preload(related_tables).paginate :page => params[:page]
        render :index
      end
      format.csv do
        csv_response(@fact_values.joins(related_tables).includes(related_tables))
      end
    end
  end

  def csv_columns
    [:host, :fact_name, :value, :origin, :updated_at]
  end

  private

  def controller_permission
    'facts'
  end

  def related_tables
    [:host, :fact_name]
  end
end
