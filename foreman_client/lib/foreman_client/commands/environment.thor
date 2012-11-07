class Environment < Apipie::Client::CliCommand

  desc 'index', 'List all environments.'
  method_option :search, :required => false, :desc => 'Filter results', :type => :string
  method_option :order, :required => false, :desc => 'Sort results', :type => :string
  def index
    params = transform_options([])
    data, resp = client.index(params)
    print_data(data)
  end

  desc 'show', 'Show an environment.'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  def show
    params = transform_options(["id"])
    data, resp = client.show(params)
    print_data(data)
  end

  desc 'create', 'Create an environment.'
  method_option :name, :required => true, :desc => '', :type => :string
  def create
    params = transform_options([], {"environment"=>["name"]})
    data, resp = client.create(params)
    print_data(data)
  end

  desc 'update', 'Update an environment.'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  method_option :name, :required => false, :desc => '', :type => :string
  def update
    params = transform_options(["id"], {"environment"=>["name"]})
    data, resp = client.update(params)
    print_data(data)
  end

  desc 'destroy', 'Delete an environment.'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  def destroy
    params = transform_options(["id"])
    data, resp = client.destroy(params)
    print_data(data)
  end

end
