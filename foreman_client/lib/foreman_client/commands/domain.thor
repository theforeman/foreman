class Domain < Apipie::Client::CliCommand

  desc 'index', 'List of domains'
  method_option :search, :required => false, :desc => 'Filter results', :type => :string
  method_option :order, :required => false, :desc => 'Sort results', :type => :string
  def index
    params = transform_options([])
    data, resp = client.index(params)
    print_data(data)
  end

  desc 'show', 'Show a domain.'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  def show
    params = transform_options(["id"])
    data, resp = client.show(params)
    print_data(data)
  end

  desc 'create', 'Create a domain.'
  method_option :name, :required => true, :desc => 'The full DNS Domain name', :type => :string
  method_option :fullname, :required => false, :desc => 'Full name describing the domain', :type => :string
  method_option :dns_id, :required => false, :desc => 'DNS Proxy to use within this domain', :type => :string
  method_option :domain_parameters_attributes, :required => false, :desc => 'Array of parameters (name, value)', :type => :string
  def create
    params = transform_options([], {"domain"=>["name", "fullname", "dns_id", "domain_parameters_attributes"]})
    data, resp = client.create(params)
    print_data(data)
  end

  desc 'update', 'Update a domain.'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  method_option :name, :required => true, :desc => 'The full DNS Domain name', :type => :string
  method_option :fullname, :required => false, :desc => 'Full name describing the domain', :type => :string
  method_option :dns_id, :required => false, :desc => 'DNS Proxy to use within this domain', :type => :string
  method_option :domain_parameters_attributes, :required => false, :desc => 'Array of parameters (name, value)', :type => :string
  def update
    params = transform_options(["id"], {"domain"=>["name", "fullname", "dns_id", "domain_parameters_attributes"]})
    data, resp = client.update(params)
    print_data(data)
  end

  desc 'destroy', 'Delete a domain.'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  def destroy
    params = transform_options(["id"])
    data, resp = client.destroy(params)
    print_data(data)
  end

end
