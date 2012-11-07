class User < Apipie::Client::CliCommand

  desc 'index', 'List all users.'
  method_option :search, :required => false, :desc => 'filter results', :type => :string
  method_option :order, :required => false, :desc => 'sort results', :type => :string
  def index
    params = transform_options([])
    data, resp = client.index(params)
    print_data(data)
  end

  desc 'show', 'Show an user.'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  def show
    params = transform_options(["id"])
    data, resp = client.show(params)
    print_data(data)
  end

  desc 'create', 'Create an user.'
  method_option :login, :required => true, :desc => '', :type => :string
  method_option :firstname, :required => false, :desc => '', :type => :string
  method_option :lastname, :required => false, :desc => '', :type => :string
  method_option :mail, :required => true, :desc => '', :type => :string
  method_option :admin, :required => false, :desc => 'Is an admin account?', :type => :string
  method_option :password, :required => true, :desc => '', :type => :string
  method_option :auth_source_id, :required => true, :desc => '', :type => :numeric
  def create
    params = transform_options([], {"user"=>["login", "firstname", "lastname", "mail", "admin", "password", "auth_source_id"]})
    data, resp = client.create(params)
    print_data(data)
  end

  desc 'update', 'Update an user.'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  method_option :login, :required => false, :desc => '', :type => :string
  method_option :firstname, :required => false, :desc => '', :type => :string
  method_option :lastname, :required => false, :desc => '', :type => :string
  method_option :mail, :required => false, :desc => '', :type => :string
  method_option :admin, :required => false, :desc => 'Is an admin account?', :type => :string
  method_option :password, :required => true, :desc => '', :type => :string
  def update
    params = transform_options(["id"], {"user"=>["login", "firstname", "lastname", "mail", "admin", "password"]})
    data, resp = client.update(params)
    print_data(data)
  end

  desc 'destroy', 'Delete an user.'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  def destroy
    params = transform_options(["id"])
    data, resp = client.destroy(params)
    print_data(data)
  end

end
