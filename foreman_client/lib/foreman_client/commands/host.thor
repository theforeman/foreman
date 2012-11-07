class Host < Apipie::Client::CliCommand

  desc 'index', 'List all hosts.'
  method_option :search, :required => false, :desc => 'Filter results', :type => :string
  method_option :order, :required => false, :desc => 'Sort results', :type => :string
  def index
    params = transform_options([])
    data, resp = client.index(params)
    print_data(data)
  end

  desc 'show', 'Show a host.'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  def show
    params = transform_options(["id"])
    data, resp = client.show(params)
    print_data(data)
  end

  desc 'create', 'Create a host.'
  method_option :name, :required => true, :desc => '', :type => :string
  method_option :environment_id, :required => true, :desc => '', :type => :string
  method_option :ip, :required => true, :desc => '', :type => :string
  method_option :mac, :required => true, :desc => '', :type => :string
  method_option :architecture_id, :required => true, :desc => '', :type => :string
  method_option :domain_id, :required => true, :desc => '', :type => :string
  method_option :puppet_proxy_id, :required => true, :desc => '', :type => :string
  method_option :operatingsystem_id, :required => false, :desc => '', :type => :string
  method_option :medium_id, :required => false, :desc => '', :type => :string
  method_option :ptable_id, :required => false, :desc => '', :type => :string
  method_option :subnet_id, :required => false, :desc => '', :type => :string
  method_option :sp_subnet_id, :required => false, :desc => '', :type => :string
  method_option :model_id_id, :required => false, :desc => '', :type => :string
  method_option :hostgroup_id, :required => false, :desc => '', :type => :string
  method_option :owner_id, :required => false, :desc => '', :type => :string
  method_option :puppet_ca_proxy_id, :required => false, :desc => '', :type => :string
  method_option :image_id, :required => false, :desc => '', :type => :string
  method_option :host_parameters_attributes, :required => false, :desc => '', :type => :string
  def create
    params = transform_options([], {"host"=>["name", "environment_id", "ip", "mac", "architecture_id", "domain_id", "puppet_proxy_id", "operatingsystem_id", "medium_id", "ptable_id", "subnet_id", "sp_subnet_id", "model_id_id", "hostgroup_id", "owner_id", "puppet_ca_proxy_id", "image_id", "host_parameters_attributes"]})
    data, resp = client.create(params)
    print_data(data)
  end

  desc 'update', 'Update a host.'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  method_option :name, :required => true, :desc => '', :type => :string
  method_option :environment_id, :required => true, :desc => '', :type => :string
  method_option :ip, :required => true, :desc => '', :type => :string
  method_option :mac, :required => true, :desc => '', :type => :string
  method_option :architecture_id, :required => true, :desc => '', :type => :string
  method_option :domain_id, :required => true, :desc => '', :type => :string
  method_option :puppet_proxy_id, :required => true, :desc => '', :type => :string
  method_option :operatingsystem_id, :required => false, :desc => '', :type => :string
  method_option :medium_id, :required => false, :desc => '', :type => :string
  method_option :ptable_id, :required => false, :desc => '', :type => :string
  method_option :subnet_id, :required => false, :desc => '', :type => :string
  method_option :sp_subnet_id, :required => false, :desc => '', :type => :string
  method_option :model_id_id, :required => false, :desc => '', :type => :string
  method_option :hostgroup_id, :required => false, :desc => '', :type => :string
  method_option :owner_id, :required => false, :desc => '', :type => :string
  method_option :puppet_ca_proxy_id, :required => false, :desc => '', :type => :string
  method_option :image_id, :required => false, :desc => '', :type => :string
  method_option :host_parameters_attributes, :required => false, :desc => '', :type => :string
  def update
    params = transform_options(["id"], {"host"=>["name", "environment_id", "ip", "mac", "architecture_id", "domain_id", "puppet_proxy_id", "operatingsystem_id", "medium_id", "ptable_id", "subnet_id", "sp_subnet_id", "model_id_id", "hostgroup_id", "owner_id", "puppet_ca_proxy_id", "image_id", "host_parameters_attributes"]})
    data, resp = client.update(params)
    print_data(data)
  end

  desc 'destroy', 'Delete an host.'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  def destroy
    params = transform_options(["id"])
    data, resp = client.destroy(params)
    print_data(data)
  end

end
