class PuppetclassLookupKeysController < LookupKeysController
  include Foreman::Controller::Parameters::PuppetclassLookupKey

  before_action :setup_search_options, :only => :index

  def index
    @lookup_keys = resource_base_search_and_page.distinct.preload(:lookup_values)
    environment_classes = EnvironmentClass.where(puppetclass_lookup_key_id: @lookup_keys.map(&:id)).select(:puppetclass_id, :puppetclass_lookup_key_id).distinct.preload(:puppetclass)
    puppetclass_ids = environment_classes.map(&:puppetclass_id).uniq
    @puppetclass_authorizer = Authorizer.new(User.current, :collection => puppetclass_ids)
    @lookup_keys_to_class = Hash[environment_classes.map { |environment_class| [environment_class.puppetclass_lookup_key_id, environment_class.puppetclass] }]
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
