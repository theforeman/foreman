require 'foreman/controller/smart_proxy_auth'

class FactValuesController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  include Foreman::Controller::SmartProxyAuth

  add_puppetmaster_filters :create
  before_filter :setup_search_options, :only => :index

  def index
    begin
      values = FactValue.my_facts.no_timestamp_facts.search_for(params[:search],:order => params[:order])
    rescue => e
      error e.to_s
      values = FactValue.no_timestamp_facts.search_for ""
    end

    respond_to do |format|
      format.html do
        @fact_values = values.required_fields.paginate :page => params[:page]
      end
      format.json do
        render :json => FactValue.build_facts_hash(values.all(:include => [:fact_name, :host]))
      end
    end
  end

  def create
    Taxonomy.no_taxonomy_scope do
      imported = detect_host_type.importHostAndFacts params.delete("facts")
      respond_to do |format|
        format.yml {
          if imported
            render :text => "Imported facts", :status => 200 and return
          else
            render :text => "Failed to import facts", :status => 400
          end
        }
      end
    end
  rescue Exception => e
    logger.warn "Failed to import facts: #{e}"
    render :text => "Failed to import facts: #{e}", :status => 400
  end

  private

  def detect_host_type
    return Host::Managed if params[:type].blank?
    if params[:type].constantize.new.kind_of?(Host::Base)
      logger.debug "Creating host of type: #{params[:type]}"
      return params[:type].constantize
    else
      raise "Invalid type requested for host creation via facts: #{params[:type]}"
    end
  rescue => e
      logger.warn "A problem occurred when detecting host type: #{e.message}"
  end

end
