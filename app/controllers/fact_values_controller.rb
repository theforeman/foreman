class FactValuesController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch

  before_filter :setup_search_options, :only => :index

  def index
    begin
      values = FactValue.my_facts.search_for(params[:search], :order => params[:order])
    rescue => e
      error e.to_s
      values = FactValue.search_for ""
    end

    conds = values.where_values.map do |cond|
      cond = cond.to_sql unless cond.is_a?(String)
      cond.split(/AND|OR/)
    end
    conds = conds.flatten.reject { |c| c.include?('"hosts"."name"') }

    if (parent = params[:parent_fact]).present? && (@parent = ::FactName.find_all_by_name(parent)).present?
      values = values.with_fact_parent_id(@parent.map(&:id))
      @parent = @parent.first
    elsif conds.present?
      values
    else
      values = values.root_only
    end

    @fact_values = values.no_timestamp_facts.required_fields.paginate :page => params[:page]
  end

end
