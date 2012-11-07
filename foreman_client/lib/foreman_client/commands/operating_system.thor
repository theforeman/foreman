class OperatingSystem < Apipie::Client::CliCommand

  desc 'index', 'List all operating systems.'
  method_option :search, :required => false, :desc => 'filter results', :type => :string
  method_option :order, :required => false, :desc => 'for example, name ASC, or name DESC', :type => :string
  def index
    params = transform_options([])
    data, resp = client.index(params)
    print_data(data)
  end

  desc 'show', 'Show an OS.'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  def show
    params = transform_options(["id"])
    data, resp = client.show(params)
    print_data(data)
  end

  desc 'create', 'Create an OS.'
  method_option :name, :required => true, :desc => '', :type => :string
  method_option :major, :required => true, :desc => '', :type => :string
  method_option :minor, :required => true, :desc => '', :type => :string
  method_option :family, :required => false, :desc => '', :type => :string
  method_option :release_name, :required => false, :desc => '', :type => :string
  def create
    params = transform_options([], {"operatingsystem"=>["name", "major", "minor", "family", "release_name"]})
    data, resp = client.create(params)
    print_data(data)
  end

  desc 'update', 'Update an OS.'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  method_option :name, :required => false, :desc => '', :type => :string
  method_option :major, :required => false, :desc => '', :type => :string
  method_option :minor, :required => false, :desc => '', :type => :string
  method_option :family, :required => false, :desc => '', :type => :string
  method_option :release_name, :required => false, :desc => '', :type => :string
  def update
    params = transform_options(["id"], {"operatingsystem"=>["name", "major", "minor", "family", "release_name"]})
    data, resp = client.update(params)
    print_data(data)
  end

  desc 'destroy', 'Delete an OS.'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  def destroy
    params = transform_options(["id"])
    data, resp = client.destroy(params)
    print_data(data)
  end

  desc 'bootfiles', 'List boot files an OS.'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  method_option :medium, :required => false, :desc => '', :type => :string
  method_option :architecture, :required => false, :desc => '', :type => :string
  def bootfiles
    params = transform_options(["id"])
    data, resp = client.bootfiles(params)
    print_data(data)
  end

end
