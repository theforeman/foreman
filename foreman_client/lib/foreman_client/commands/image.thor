class Image < Apipie::Client::CliCommand

  desc 'index', 'List all images for compute resource.'
  method_option :id, :required => 'true'
  method_option :search, :required => false, :desc => 'filter results', :type => :string
  method_option :order, :required => false, :desc => 'sort results', :type => :string
  def index
    params = transform_options(["id"])
    data, resp = client.index(params)
    print_data(data)
  end

  desc 'show', 'Show an image.'
  method_option :id, :required => 'true'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  def show
    params = transform_options(["id", "id"])
    data, resp = client.show(params)
    print_data(data)
  end

  desc 'create', 'Create a image.'
  method_option :id, :required => 'true'
  method_option :name, :required => true, :desc => '', :type => :string
  method_option :username, :required => true, :desc => '', :type => :string
  method_option :uuid, :required => true, :desc => '', :type => :string
  method_option :compute_resource_id, :required => true, :desc => '', :type => :string
  method_option :architecture_id, :required => true, :desc => '', :type => :string
  method_option :operatingsystem_id, :required => true, :desc => '', :type => :string
  def create
    params = transform_options(["id"], {"image"=>["name", "username", "uuid", "compute_resource_id", "architecture_id", "operatingsystem_id"]})
    data, resp = client.create(params)
    print_data(data)
  end

  desc 'update', 'Update a image.'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  method_option :name, :required => true, :desc => '', :type => :string
  method_option :username, :required => true, :desc => '', :type => :string
  method_option :uuid, :required => true, :desc => '', :type => :string
  method_option :compute_resource_id, :required => true, :desc => '', :type => :string
  method_option :architecture_id, :required => true, :desc => '', :type => :string
  method_option :operatingsystem_id, :required => true, :desc => '', :type => :string
  def update
    params = transform_options(["id"], {"image"=>["name", "username", "uuid", "compute_resource_id", "architecture_id", "operatingsystem_id"]})
    data, resp = client.update(params)
    print_data(data)
  end

  desc 'destroy', 'Delete an image.'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  def destroy
    params = transform_options(["id"])
    data, resp = client.destroy(params)
    print_data(data)
  end

end
