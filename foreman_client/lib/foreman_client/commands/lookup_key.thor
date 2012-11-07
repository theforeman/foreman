class LookupKey < Apipie::Client::CliCommand

  desc 'index', 'List all lookup_keys.'
  method_option :search, :required => false, :desc => 'filter results', :type => :string
  method_option :order, :required => false, :desc => 'sort results', :type => :string
  def index
    params = transform_options([])
    data, resp = client.index(params)
    print_data(data)
  end

  desc 'show', 'Show a lookup key.'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  def show
    params = transform_options(["id"])
    data, resp = client.show(params)
    print_data(data)
  end

  desc 'create', 'Create a lookup key.'
  method_option :key, :required => true, :desc => '', :type => :string
  method_option :puppetclass_id, :required => false, :desc => '', :type => :string
  method_option :default_value, :required => false, :desc => '', :type => :string
  method_option :path, :required => false, :desc => '', :type => :string
  method_option :description, :required => false, :desc => '', :type => :string
  method_option :lookup_values_count, :required => false, :desc => '', :type => :string
  def create
    params = transform_options([], {"lookup_key"=>["key", "puppetclass_id", "default_value", "path", "description", "lookup_values_count"]})
    data, resp = client.create(params)
    print_data(data)
  end

  desc 'update', 'Update a lookup key.'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  method_option :key, :required => true, :desc => '', :type => :string
  method_option :puppetclass_id, :required => false, :desc => '', :type => :string
  method_option :default_value, :required => false, :desc => '', :type => :string
  method_option :path, :required => false, :desc => '', :type => :string
  method_option :description, :required => false, :desc => '', :type => :string
  method_option :lookup_values_count, :required => false, :desc => '', :type => :string
  def update
    params = transform_options(["id"], {"lookup_key"=>["key", "puppetclass_id", "default_value", "path", "description", "lookup_values_count"]})
    data, resp = client.update(params)
    print_data(data)
  end

  desc 'destroy', 'Delete a lookup key.'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  def destroy
    params = transform_options(["id"])
    data, resp = client.destroy(params)
    print_data(data)
  end

end
