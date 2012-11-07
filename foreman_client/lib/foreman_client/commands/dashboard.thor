class Dashboard < Apipie::Client::CliCommand

  desc 'index', 'Get Dashboard results'
  method_option :search, :required => false, :desc => 'filter results', :type => :string
  def index
    params = transform_options([])
    data, resp = client.index(params)
    print_data(data)
  end

end
