class Medium < Apipie::Client::CliCommand

  desc 'index', 'List all media.'
  method_option :search, :required => false, :desc => 'filter results', :type => :string
  method_option :order, :required => false, :desc => 'for example, name ASC, or name DESC', :type => :string
  def index
    params = transform_options([])
    data, resp = client.index(params)
    print_data(data)
  end

  desc 'show', 'Show a medium.'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  def show
    params = transform_options(["id"])
    data, resp = client.show(params)
    print_data(data)
  end

  desc 'create', 'Create a medium.'
  method_option :name, :required => true, :desc => 'Name of media', :type => :string
  method_option :path, :required => true, :desc => 'The path to the medium, can be a URL or a valid NFS server (exclusive of the architecture).  for example http://mirror.averse.net/centos/$version/os/$arch where $arch will be substituted for the host&#39;s actual OS architecture and $version, $major and $minor will be substituted for the version of the operating system.  Solaris and Debian media may also use $release.', :type => :string
  method_option :os_family, :required => false, :desc => 'The family that the operating system belongs to.  Available families:   Archlinux Debian Redhat Solaris Suse Windows', :type => :string
  def create
    params = transform_options([], {"medium"=>["name", "path", "os_family"]})
    data, resp = client.create(params)
    print_data(data)
  end

  desc 'update', 'Update a medium.'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  method_option :name, :required => false, :desc => 'Name of media', :type => :string
  method_option :path, :required => false, :desc => 'The path to the medium, can be a URL or a valid NFS server (exclusive of the architecture).  for example http://mirror.averse.net/centos/$version/os/$arch where $arch will be substituted for the host&#39;s actual OS architecture and $version, $major and $minor will be substituted for the version of the operating system.  Solaris and Debian media may also use $release.', :type => :string
  method_option :os_family, :required => false, :desc => 'The family that the operating system belongs to.  Available families:   Archlinux Debian Redhat Solaris Suse Windows', :type => :string
  def update
    params = transform_options(["id"], {"medium"=>["name", "path", "os_family"]})
    data, resp = client.update(params)
    print_data(data)
  end

  desc 'destroy', 'Delete a medium.'
  method_option :id, :required => 'true'
  method_option :id, :required => true, :desc => '', :type => :string
  def destroy
    params = transform_options(["id"])
    data, resp = client.destroy(params)
    print_data(data)
  end

end
