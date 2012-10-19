class FactValuesController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch

  skip_before_filter :require_ssl,               :only => :create
  skip_before_filter :require_login,             :only => :create
  skip_before_filter :authorize,                 :only => :create
  skip_before_filter :verify_authenticity_token, :only => :create
  skip_before_filter :set_taxonomy,              :only => :create
  skip_before_filter :session_expiry, :update_activity_time, :only => :create
  before_filter :set_admin_user, :only => :create
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
      imported = Host.importHostAndFacts params.delete("facts")
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

end
