class GlobalLookupKeysController < LookupKeysController
  include Foreman::Controller::Parameters::GlobalLookupKey
  def resource
    @global_lookup_key
  end

  def index
    @global_lookup_key = resource_base.search_for(params[:search], :order => params[:order]).paginate(:page => params[:page])
  end

  def new
    @global_lookup_key = GlobalLookupKey.new
  end

  def create
    @global_lookup_key = GlobalLookupKey.new(resource_params)
    if @global_lookup_key.save
      process_success
    else
      process_error
    end
  end

  def resource_params
    global_lookup_key_params
  end
end
