module Foreman
  class RenderTemplatesFromFolder
    class ProvisioningTemplateFromFolder < ::ProvisioningTemplate
      self.table_name = 'templates'
      attr_accessor :template_path, :source_directory
    end

    attr_reader :source_directory
    attr_accessor :errors

    delegate :logger, to: :Rails

    def self.instance(source_directory:)
      @instances ||= {}
      @instances[source_directory] ||= new(source_directory: source_directory)
    end

    def self.clear_instances
      @instances = {}
    end

    def initialize(source_directory:)
      @source_directory = source_directory
      @errors = {}
    end

    def render_all
      self.errors = {}
      templates.each do |template|
        next if template.snippet
        if template.operatingsystems.empty?
          logger.debug "Skipping template #{template.name} because it's not associated to any operating system."
          next
        end
        begin
          render_template(template)
        rescue StandardError => e
          errors[template] = e.message
        end
      end
      errors.empty?
    end

    def render_template(template)
      source = source_klass.new(template)
      scope = Foreman::Renderer.get_scope(host: host(template), source: source)
      Foreman::Renderer.render(source, scope)
    end

    def templates
      @templates ||= files.map { |filepath| load_file(filepath) }
    end

    def snippets
      templates.select(&:snippet?)
    end

    def load_file(filepath)
      content = File.read(filepath)
      metadata = Template.parse_metadata(content).deep_symbolize_keys
      name = metadata[:name]
      raise "Could not read name from metadata in template #{filepath}." unless name.present?
      kind = metadata[:kind]
      snippet = (kind == 'snippet') || !!metadata[:snippet]
      oses = metadata[:oses] || []
      operatingsystems = oses.map { |os| build_operatingsystem(name: os) }.compact
      ProvisioningTemplateFromFolder.new(
        template_path: filepath, source_directory: source_directory,
        name: name, template: content,
        template_kind: TemplateKind.new(name: kind),
        snippet: snippet, operatingsystems: operatingsystems
      )
    end

    def host(template)
      operatingsystem = template.operatingsystems.first
      build_host(operatingsystem: operatingsystem)
    end

    private

    def source_klass
      Foreman::Renderer::Source::Directory
    end

    def files
      @files ||= Dir.glob(File.join(source_directory, '**', '*.erb'))
    end

    def build_architecture(osfamily:)
      architecture_name = case osfamily
                          when 'Solaris'
                            'sparc'
                          when 'VRP'
                            'ASIC'
                          else
                            'x86_64'
                          end
      Architecture.new(
        name: architecture_name
      )
    end

    def build_operatingsystem(name:)
      family = Operatingsystem.deduce_family(name)
      return unless family
      architecture = build_architecture(osfamily: family)
      family.constantize.new(
        name: name,
        major: 7,
        minor: 6,
        family: family,
        architectures: [architecture]
      )
    end

    def build_medium(operatingsystem:)
      case operatingsystem.family
      when 'Solaris'
        Medium.new(
          name: 'Solaris Medium',
          path: 'http://www.example.com/vol/solgi_5.10/sol$minor_$release_$arch',
          media_path: 'www.example.com:/vol/solgi_5.10/sol$minor_$release_$arch',
          config_path: 'www.example.com:/vol/jumpstart',
          image_path: 'www.example.com:/vol/solgi_5.10/sol$minor_$release_$arch/flash/',
          os_family: operatingsystem.family
        )
      else
        Medium.new(
          name: 'Example Medium',
          path: 'http://www.example.com/path/',
          os_family: operatingsystem.family
        )
      end
    end

    def build_host(operatingsystem:)
      medium = build_medium(operatingsystem: operatingsystem)
      domain = Domain.new(
        name: 'example.com'
      )
      subnet = Subnet.new(
        name: 'TEST-NET-1',
        network: '192.0.2.0'
      )
      medium.operatingsystems << operatingsystem
      operatingsystem.media << medium
      Host.new(
        architecture: operatingsystem.architectures.first,
        medium: medium,
        domain: domain,
        operatingsystem: operatingsystem,
        subnet: subnet,
        root_pass: 'securepassword',
        disk: 'fake disk layout',
        name: 'testhost',
        pxe_loader: 'Grub2 UEFI SecureBoot',
        mac: '00-11-22-33-44-55',
        managed: true
      )
    end
  end
end
