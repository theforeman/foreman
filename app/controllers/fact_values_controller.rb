class FactValuesController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  include Foreman::Controller::CsvResponder

  before_action :setup_search_options, :only => :index
  before_action :find_facts, :only => :index

  def index
    respond_to do |format|
      format.html do
        @fact_values = @fact_values.preload(related_tables).paginate(:page => params[:page], :per_page => params[:per_page])
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

  def find_facts
    @parent = FactName.where(:name => params[:parent_fact]).first
    values = resource_base_with_search.my_facts.no_timestamp_facts

    @fact_values = if @parent
                     values.with_fact_parent_id(@parent)
                   elsif has_conditions? || request.format.csv?
                     values
                   else
                     values.root_only
                   end
  end

  def has_conditions?
    (original_search_parameter || '').split(/AND|OR/i)
      .flatten.reject { |c| c.include?('host') }
      .present?
  end

  def controller_permission
    'facts'
  end

  def related_tables
    [:host, :fact_name]
  end
end
