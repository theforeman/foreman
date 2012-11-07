class Setting < Apipie::Client::CliCommand

  desc 'index', 'List all settings.'
  method_option :search, :required => false, :desc => 'Filter results', :type => :string
  method_option :order, :required => false, :desc => 'Sort results', :type => :string
  def index
    params = transform_options([])
    data, resp = client.index(params)
    print_data(data)
  end

  desc 'show', 'Show an setting.'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  def show
    params = transform_options(["id"])
    data, resp = client.show(params)
    print_data(data)
  end

  desc 'update', 'Update a setting.'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  method_option :value, :required => true, :desc => '', :type => :string
  def update
    params = transform_options(["id"], {"setting"=>["value"]})
    data, resp = client.update(params)
    print_data(data)
  end

end
