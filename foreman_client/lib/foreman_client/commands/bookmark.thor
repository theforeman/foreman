class Bookmark < Apipie::Client::CliCommand

  desc 'index', 'List all bookmarks.'
  def index
    params = transform_options([])
    data, resp = client.index(params)
    print_data(data)
  end

  desc 'show', 'Show a bookmark.'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  def show
    params = transform_options(["id"])
    data, resp = client.show(params)
    print_data(data)
  end

  desc 'create', 'Create a bookmark.'
  method_option :name, :required => true, :desc => '', :type => :string
  method_option :controller, :required => true, :desc => '', :type => :string
  method_option :query, :required => true, :desc => '', :type => :string
  def create
    params = transform_options([], {"bookmark"=>["name", "controller", "query"]})
    data, resp = client.create(params)
    print_data(data)
  end

  desc 'update', 'Update a bookmark.'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  method_option :name, :required => false, :desc => '', :type => :string
  method_option :controller, :required => false, :desc => '', :type => :string
  method_option :query, :required => false, :desc => '', :type => :string
  def update
    params = transform_options(["id"], {"bookmark"=>["name", "controller", "query"]})
    data, resp = client.update(params)
    print_data(data)
  end

  desc 'destroy', 'Delete a bookmark.'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  def destroy
    params = transform_options(["id"])
    data, resp = client.destroy(params)
    print_data(data)
  end

end
