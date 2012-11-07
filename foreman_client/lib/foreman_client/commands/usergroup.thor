class Usergroup < Apipie::Client::CliCommand

  desc 'index', 'List all usergroups.'
  def index
    params = transform_options([])
    data, resp = client.index(params)
    print_data(data)
  end

  desc 'show', 'Show a usergroup.'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  def show
    params = transform_options(["id"])
    data, resp = client.show(params)
    print_data(data)
  end

  desc 'create', 'Create a usergroup.'
  method_option :name, :required => true, :desc => '', :type => :string
  def create
    params = transform_options([], {"usergroup"=>["name"]})
    data, resp = client.create(params)
    print_data(data)
  end

  desc 'update', 'Update a usergroup.'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  method_option :name, :required => true, :desc => '', :type => :string
  def update
    params = transform_options(["id"], {"usergroup"=>["name"]})
    data, resp = client.update(params)
    print_data(data)
  end

  desc 'destroy', 'Delete a usergroup.'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  def destroy
    params = transform_options(["id"])
    data, resp = client.destroy(params)
    print_data(data)
  end

end
