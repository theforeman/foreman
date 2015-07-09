class FactValuesController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch

  before_filter :setup_search_options, :only => :index

  def index
    base = resource_base.no_timestamp_facts
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

    @fact_values = values.no_timestamp_facts.required_fields.paginate :page => params[:page]
  end

  private

  def controller_permission
    'facts'
  end
end
