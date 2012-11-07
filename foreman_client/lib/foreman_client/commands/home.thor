class Home < Apipie::Client::CliCommand

  desc 'index', 'Show available links.'
  def index
    params = transform_options([])
    data, resp = client.index(params)
    print_data(data)
  end

  desc 'status', 'Show status.'
  def status
    params = transform_options([])
    data, resp = client.status(params)
    print_data(data)
  end

end
