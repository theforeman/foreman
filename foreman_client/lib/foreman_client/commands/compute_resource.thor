class ComputeResource < Apipie::Client::CliCommand

  desc 'index', 'List all compute resources.'
  method_option :search, :required => false, :desc => 'filter results', :type => :string
  method_option :order, :required => false, :desc => 'sort results', :type => :string
  def index
    params = transform_options([])
    data, resp = client.index(params)
    print_data(data)
  end

  desc 'show', 'Show an compute resource.'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  def show
    params = transform_options(["id"])
    data, resp = client.show(params)
    print_data(data)
  end

  desc 'create', 'Create a compute resource.'
  method_option :name, :required => true, :desc => '', :type => :string
  method_option :provider, :required => true, :desc => '', :type => :string
  method_option :url, :required => true, :desc => '', :type => :string
  def create
    params = transform_options([], {"compute_resource"=>["name", "provider", "url"]})
    data, resp = client.create(params)
    print_data(data)
  end

  desc 'update', 'Update a compute resource.'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  method_option :name, :required => false, :desc => '', :type => :string
  method_option :provider, :required => false, :desc => '', :type => :string
  method_option :url, :required => false, :desc => '', :type => :string
  def update
    params = transform_options(["id"], {"compute_resource"=>["name", "provider", "url"]})
    data, resp = client.update(params)
    print_data(data)
  end

  desc 'destroy', 'Delete a compute resource.'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  def destroy
    params = transform_options(["id"])
    data, resp = client.destroy(params)
    print_data(data)
  end

end
