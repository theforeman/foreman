class Model < Apipie::Client::CliCommand

  desc 'index', 'List all models.'
  method_option :search, :required => false, :desc => 'filter results', :type => :string
  method_option :order, :required => false, :desc => 'sort results', :type => :string
  def index
    params = transform_options([])
    data, resp = client.index(params)
    print_data(data)
  end

  desc 'show', 'Show a model.'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  def show
    params = transform_options(["id"])
    data, resp = client.show(params)
    print_data(data)
  end

  desc 'create', 'Create a model.'
  method_option :name, :required => true, :desc => '', :type => :string
  method_option :info, :required => false, :desc => '', :type => :string
  method_option :vendor_class, :required => false, :desc => '', :type => :string
  method_option :hardware_model, :required => false, :desc => '', :type => :string
  def create
    params = transform_options([], {"model"=>["name", "info", "vendor_class", "hardware_model"]})
    data, resp = client.create(params)
    print_data(data)
  end

  desc 'update', 'Update a model.'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  method_option :name, :required => true, :desc => '', :type => :string
  method_option :info, :required => false, :desc => '', :type => :string
  method_option :vendor_class, :required => false, :desc => '', :type => :string
  method_option :hardware_model, :required => false, :desc => '', :type => :string
  def update
    params = transform_options(["id"], {"model"=>["name", "info", "vendor_class", "hardware_model"]})
    data, resp = client.update(params)
    print_data(data)
  end

  desc 'destroy', 'Delete a model.'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  def destroy
    params = transform_options(["id"])
    data, resp = client.destroy(params)
    print_data(data)
  end

end
