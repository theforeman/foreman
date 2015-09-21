class PuppetclassLookupKeysController < LookupKeysController
  before_filter :setup_search_options, :only => :index

  def index
    @lookup_keys = resource_base.search_for(params[:search], :order => params[:order])
                                .paginate(:page => params[:page])
                                .includes(:param_classes)
    @puppetclass_authorizer = Authorizer.new(User.current, :collection => @lookup_keys.pluck(:puppetclass_id).compact.uniq)
  end

  def resource
    @puppetclass_lookup_key
  end
end
