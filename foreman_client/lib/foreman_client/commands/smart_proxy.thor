class SmartProxy < Apipie::Client::CliCommand

  desc 'index', 'List all smart_proxies.'
  def index
    params = transform_options([])
    data, resp = client.index(params)
    print_data(data)
  end

  desc 'show', 'Show a smart proxy.'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  def show
    params = transform_options(["id"])
    data, resp = client.show(params)
    print_data(data)
  end

  desc 'create', 'Create a smart proxy.'
  method_option :name, :required => true, :desc => '', :type => :string
  method_option :url, :required => true, :desc => '', :type => :string
  def create
    params = transform_options([], {"smart_proxy"=>["name", "url"]})
    data, resp = client.create(params)
    print_data(data)
  end

  desc 'update', 'Update a smart proxy.'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  method_option :name, :required => true, :desc => '', :type => :string
  method_option :url, :required => true, :desc => '', :type => :string
  def update
    params = transform_options(["id"], {"smart_proxy"=>["name", "url"]})
    data, resp = client.update(params)
    print_data(data)
  end

  desc 'destroy', 'Delete a smart_proxy.'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  def destroy
    params = transform_options(["id"])
    data, resp = client.destroy(params)
    print_data(data)
  end

end
