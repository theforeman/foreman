require_relative 'snapshot_source'

class TemplateSnapshotService
  def self.sources
    new.sources
  end

  def self.host
    new.host
  end

  def sources
    files.map { |path| SnapshotSource.new(path) }
  end

  def host
    interface = FactoryBot.build(:nic_primary_and_provision, identifier: 'eth0',
                                                             mac: '00-f0-54-1a-7e-e0',
                                                             ip: '127.0.0.1')
    domain = FactoryBot.build(:domain, name: 'snapshotdomain.com')
    subnet = FactoryBot.build(:subnet_ipv4, name: 'one', network: interface.ip)
    architecture = FactoryBot.build(:architecture, name: 'x86_64')
    medium = FactoryBot.build(:medium, name: 'CentOS mirror')
    ptable = FactoryBot.build(:ptable, name: 'ptable')
    operatingsystem = FactoryBot.build(:operatingsystem, name: 'Redhat',
                                                         major: 7,
                                                         architectures: [architecture],
                                                         media: [medium],
                                                         ptables: [ptable])
    FactoryBot.build(:host, :managed, hostname: 'snapshothost',
                                      domain: domain,
                                      subnet: subnet,
                                      architecture: architecture,
                                      medium: medium,
                                      ptable: ptable,
                                      operatingsystem: operatingsystem,
                                      interfaces: [interface])
  end

  private

  def files
    @files ||= YAML.load_file(File.join(__dir__, 'snapshots.yaml')).fetch('files', []).map { |path| Rails.root.join(path) }
  end
end
