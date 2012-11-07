class Role < Apipie::Client::CliCommand

  desc 'index', 'List all roles.'
  method_option :search, :required => false, :desc => 'filter results', :type => :string
  method_option :order, :required => false, :desc => 'sort results', :type => :string
  def index
    params = transform_options([])
    data, resp = client.index(params)
    print_data(data)
  end

  desc 'show', 'Show an role.'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  def show
    params = transform_options(["id"])
    data, resp = client.show(params)
    print_data(data)
  end

  desc 'create', 'Create an role.'
  method_option :name, :required => true, :desc => '', :type => :string
  def create
    params = transform_options([], {"role"=>["name"]})
    data, resp = client.create(params)
    print_data(data)
  end

  desc 'update', 'Update an role.'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  method_option :name, :required => false, :desc => '', :type => :string
  def update
    params = transform_options(["id"], {"role"=>["name"]})
    data, resp = client.update(params)
    print_data(data)
  end

  desc 'destroy', 'Delete an role.'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  def destroy
    params = transform_options(["id"])
    data, resp = client.destroy(params)
    print_data(data)
  end

end
