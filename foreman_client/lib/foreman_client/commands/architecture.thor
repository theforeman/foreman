class Architecture < Apipie::Client::CliCommand

  desc 'index', 'List all architectures.'
  method_option :search, :required => false, :desc => 'filter results', :type => :string
  method_option :order, :required => false, :desc => 'sort results', :type => :string
  def index
    params = transform_options([])
    data, resp = client.index(params)
    print_data(data)
  end

  desc 'show', 'Show an architecture.'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  def show
    params = transform_options(["id"])
    data, resp = client.show(params)
    print_data(data)
  end

  desc 'create', 'Create an architecture.'
  method_option :name, :required => true, :desc => '', :type => :string
  method_option :operatingsystem_ids, :required => false, :desc => 'Operatingsystem ID&#39;s', :type => :string
  def create
    params = transform_options([], {"architecture"=>["name", "operatingsystem_ids"]})
    data, resp = client.create(params)
    print_data(data)
  end

  desc 'update', 'Update an architecture.'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  method_option :name, :required => false, :desc => '', :type => :string
  method_option :operatingsystem_ids, :required => false, :desc => 'Operatingsystem ID&#39;s', :type => :string
  def update
    params = transform_options(["id"], {"architecture"=>["name", "operatingsystem_ids"]})
    data, resp = client.update(params)
    print_data(data)
  end

  desc 'destroy', 'Delete an architecture.'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  def destroy
    params = transform_options(["id"])
    data, resp = client.destroy(params)
    print_data(data)
  end

end
