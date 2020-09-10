module Foreman
  module Renderer
    module Scope
      module Variables
        module Base
          def self.included(base)
            base.register_loader('load_variables_base')
          end

          private

          delegate :diskLayout, :disk_layout_source, :medium, :architecture, :ptable, :use_image, :arch,
            :image_file, :default_image_file, to: :host, allow_nil: true
          delegate :mediumpath, :additional_media, :supports_image, :major, :preseed_path, :preseed_server,
            :xen, :kernel, :initrd, to: :operatingsystem, allow_nil: true
          delegate :name, to: :architecture, allow_nil: true, prefix: true
          delegate :content, to: :disk_layout_source, allow_nil: true, prefix: true

          def operatingsystem
            host.try(:operatingsystem)
          end

          def disk
            host.try(:disk)
          end

          def load_variables_base
            @medium_provider = Foreman::Plugin.medium_providers.find_provider(host) if host
            if operatingsystem&.respond_to?(:pxe_type)
              send "#{operatingsystem.pxe_type}_attributes"
              pxe_config
            end
            @additional_media = @medium_provider.nil? ? [] : additional_media(@medium_provider)
            @provisioning_type = host.is_a?(Hostgroup) ? 'hostgroup' : 'host'
            @static = !params[:static].empty?
            @template_url = params['url']
          end

          %w(coreos aif memdisk ZTP).each do |name|
            define_method("#{name}_attributes") do
              @mediapath = mediumpath(@medium_provider) if medium
            end
          end

          def rancheros_attributes
            @mediapath = mediumpath(host)
          end

          def waik_attributes
          end

          def alterator_attributes
            @mediapath   = mediumpath(@medium_provider) if medium
            @mediaserver = URI(@mediapath).host
            @metadata    = params[:metadata].to_s
          end

          def jumpstart_attributes
            if supports_image && use_image
              @install_type     = "flash_install"
              # We have an individual override for the host's image file
              @archive_location = image_file || default_image_file
            else
              @install_type = "initial_install"
              @system_type  = "standalone"
              @cluster      = "SUNWCreq"
              @packages     = "SUNWgzip"
              @locale       = "C"
            end
            @disk = disk_layout_source_content
          end

          def kickstart_attributes
            @dynamic   = !!(disk_layout_source_content =~ /^#Dynamic/) if disk_layout_source_content
            @arch      = architecture_name
            @osver     = major.try(:to_i)
            @mediapath = mediumpath(@medium_provider) if @medium_provider
          end

          def preseed_attributes
            if operatingsystem && medium && architecture
              @preseed_path   = preseed_path(@medium_provider)
              @preseed_server = preseed_server(@medium_provider)
            end
          end

          def yast_attributes
            @dynamic   = !!(disk_layout_source_content =~ /^#Dynamic/) if disk_layout_source_content
            @mediapath = mediumpath(@medium_provider) if @medium_provider
          end

          def xenserver_attributes
            return unless @medium_provider
            @mediapath = mediumpath(@medium_provider)
            @xen = xen(@medium_provider)
          end

          def pxe_config
            return unless @medium_provider
            @kernel = kernel(@medium_provider)
            @initrd = initrd(@medium_provider)
            @kernel_uri, @initrd_uri = operatingsystem.boot_files_uri(@medium_provider)
          end
        end
      end
    end
  end
end
