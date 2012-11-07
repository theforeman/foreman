class Hostgroup < Apipie::Client::CliCommand

  desc 'index', 'List all hostgroups.'
  method_option :search, :required => false, :desc => 'filter results', :type => :string
  method_option :order, :required => false, :desc => 'sort results', :type => :string
  def index
    params = transform_options([])
    data, resp = client.index(params)
    print_data(data)
  end

  desc 'show', 'Show a hostgroup.'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  def show
    params = transform_options(["id"])
    data, resp = client.show(params)
    print_data(data)
  end

  desc 'create', 'Create an hostgroup.'
  method_option :name, :required => true, :desc => '', :type => :string
  method_option :environment_id, :required => false, :desc => '', :type => :string
  method_option :operatingsystem_id, :required => false, :desc => '', :type => :string
  method_option :architecture_id, :required => false, :desc => '', :type => :string
  method_option :medium_id, :required => false, :desc => '', :type => :string
  method_option :ptable_id, :required => false, :desc => '', :type => :string
  method_option :puppet_ca_proxy_id, :required => false, :desc => '', :type => :string
  method_option :subnet_id, :required => false, :desc => '', :type => :string
  method_option :domain_id, :required => false, :desc => '', :type => :string
  method_option :puppet_proxy_id, :required => false, :desc => '', :type => :string
  def create
    params = transform_options([], {"hostgroup"=>["name", "environment_id", "operatingsystem_id", "architecture_id", "medium_id", "ptable_id", "puppet_ca_proxy_id", "subnet_id", "domain_id", "puppet_proxy_id"]})
    data, resp = client.create(params)
    print_data(data)
  end

  desc 'update', 'Update an hostgroup.'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  method_option :name, :required => true, :desc => '', :type => :string
  method_option :environment_id, :required => false, :desc => '', :type => :string
  method_option :operatingsystem_id, :required => false, :desc => '', :type => :string
  method_option :architecture_id, :required => false, :desc => '', :type => :string
  method_option :medium_id, :required => false, :desc => '', :type => :string
  method_option :ptable_id, :required => false, :desc => '', :type => :string
  method_option :puppet_ca_proxy_id, :required => false, :desc => '', :type => :string
  method_option :subnet_id, :required => false, :desc => '', :type => :string
  method_option :domain_id, :required => false, :desc => '', :type => :string
  method_option :puppet_proxy_id, :required => false, :desc => '', :type => :string
  def update
    params = transform_options(["id"], {"hostgroup"=>["name", "environment_id", "operatingsystem_id", "architecture_id", "medium_id", "ptable_id", "puppet_ca_proxy_id", "subnet_id", "domain_id", "puppet_proxy_id"]})
    data, resp = client.update(params)
    print_data(data)
  end

  desc 'destroy', 'Delete an hostgroup.'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  def destroy
    params = transform_options(["id"])
    data, resp = client.destroy(params)
    print_data(data)
  end

end
