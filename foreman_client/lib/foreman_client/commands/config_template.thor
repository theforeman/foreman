class ConfigTemplate < Apipie::Client::CliCommand

  desc 'index', 'List templates'
  method_option :search, :required => false, :desc => 'filter results', :type => :string
  method_option :order, :required => false, :desc => 'sort results', :type => :string
  def index
    params = transform_options([])
    data, resp = client.index(params)
    print_data(data)
  end

  desc 'show', 'Show template details'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  def show
    params = transform_options(["id"])
    data, resp = client.show(params)
    print_data(data)
  end

  desc 'create', 'Create a template'
  method_option :name, :required => true, :desc => 'template name', :type => :string
  method_option :template, :required => true, :desc => '', :type => :string
  method_option :snippet, :required => false, :desc => '', :type => :string
  method_option :audit_comment, :required => false, :desc => '', :type => :string
  method_option :template_kind_id, :required => false, :desc => 'not relevant for snippet', :type => :string
  method_option :template_combinations_attributes, :required => false, :desc => 'Array of template combinations (hostgroupid, environmentid)', :type => :string
  method_option :operatingsystem_ids, :required => false, :desc => 'Array of operating systems ID to associate the template with', :type => :string
  def create
    params = transform_options([], {"config_template"=>["name", "template", "snippet", "audit_comment", "template_kind_id", "template_combinations_attributes", "operatingsystem_ids"]})
    data, resp = client.create(params)
    print_data(data)
  end

  desc 'update', 'Update a template'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  method_option :name, :required => false, :desc => 'template name', :type => :string
  method_option :template, :required => false, :desc => '', :type => :string
  method_option :snippet, :required => false, :desc => '', :type => :string
  method_option :audit_comment, :required => false, :desc => '', :type => :string
  method_option :template_kind_id, :required => false, :desc => 'not relevant for snippet', :type => :string
  method_option :template_combinations_attributes, :required => false, :desc => 'Array of template combinations (hostgroupid, environmentid)', :type => :string
  method_option :operatingsystem_ids, :required => false, :desc => 'Array of operating systems ID to associate the template with', :type => :string
  def update
    params = transform_options(["id"], {"config_template"=>["name", "template", "snippet", "audit_comment", "template_kind_id", "template_combinations_attributes", "operatingsystem_ids"]})
    data, resp = client.update(params)
    print_data(data)
  end

  desc 'revision', ''
  method_option :version, :required => false, :desc => 'template version', :type => :string
  def revision
    params = transform_options([])
    data, resp = client.revision(params)
    print_data(data)
  end

  desc 'destroy', 'Delete a template'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  def destroy
    params = transform_options(["id"])
    data, resp = client.destroy(params)
    print_data(data)
  end

  desc 'build_pxe_default', 'Change the default PXE menu on all configured TFTP servers'
  def build_pxe_default
    params = transform_options([])
    data, resp = client.build_pxe_default(params)
    print_data(data)
  end

end
