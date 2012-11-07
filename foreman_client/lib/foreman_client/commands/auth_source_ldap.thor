class AuthSourceLdap < Apipie::Client::CliCommand

  desc 'index', 'List all authsource ldaps'
  def index
    params = transform_options([])
    data, resp = client.index(params)
    print_data(data)
  end

  desc 'show', 'Show an authsource ldap.'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  def show
    params = transform_options(["id"])
    data, resp = client.show(params)
    print_data(data)
  end

  desc 'create', 'Create an auth_source_ldap.'
  method_option :name, :required => true, :desc => '', :type => :string
  def create
    params = transform_options([], {"auth_source_ldap"=>["name"]})
    data, resp = client.create(params)
    print_data(data)
  end

  desc 'update', 'Update an auth_source_ldap.'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  method_option :name, :required => false, :desc => '', :type => :string
  def update
    params = transform_options(["id"], {"auth_source_ldap"=>["name"]})
    data, resp = client.update(params)
    print_data(data)
  end

  desc 'destroy', 'Delete an auth_source_ldap.'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  def destroy
    params = transform_options(["id"])
    data, resp = client.destroy(params)
    print_data(data)
  end

end
