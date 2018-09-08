class PuppetclassLookupKeysController < LookupKeysController
  include Foreman::Controller::Parameters::PuppetclassLookupKey

  before_action :setup_search_options, :only => :index

  def index
    @lookup_keys = resource_base_search_and_page(:param_classes).smart_class_parameters
    @puppetclass_authorizer = Authorizer.new(User.current, :collection => @lookup_keys.map {|key| key.param_class.try(:id)}.compact.uniq)
  end

  private

  def resource
    @puppetclass_lookup_key
  end

  def controller_permission
    'external_parameters'
  end

  def resource_params
    puppetclass_lookup_key_params
  end
end
