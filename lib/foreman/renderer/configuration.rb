module Foreman
  module Renderer
    class Configuration
      DEFAULT_ALLOWED_GENERIC_HELPERS = [
        :foreman_url,
        :snippet, :snippets,
        :snippet_if_exists,
        :indent,
        :foreman_server_fqdn, :foreman_server_url,
        :log_debug, :log_info, :log_warn, :log_error, :log_fatal,
        :template_name,
        :dns_lookup,
        :pxe_kernel_options,
        :save_to_file,
        :subnet_param, :subnet_has_param?,
        :global_setting,
        :default_template_url,
        :medium_provider,
        :medium_uri,
        :load_hosts,
        :all_host_statuses,
        :host_status,
        :preview?
      ]

      DEFAULT_ALLOWED_HOST_HELPERS = [
        :grub_pass,
        :ks_console,
        :root_pass,
        :media_path,
        :match,
        :host_param_true?, :host_param_false?,
        :host_param, :host_param!,
        :host_puppet_classes,
        :host_enc
      ]

      DEFAULT_ALLOWED_VARIABLES = [
        :arch,
        :dynamic,
        :host,
        :initrd,
        :kernel,
        :mediapath,
        :mediaserver,
        :osver,
        :preseed_path,
        :preseed_server,
        :provisioning_type,
        :repos,
        :static,
        :template_name,
        :xen
      ]

      DEFAULT_ALLOWED_GLOBAL_SETTINGS = [
        :administrator,
        :proxy_request_timeout,
        :http_proxy,
        :http_proxy_except_list,
        :email_reply_address,
        :safemode_render,
        :manage_puppetca,
        :ignored_interface_identifiers,
        :remote_addr,
        :token_duration,
        :dns_conflict_timeout,
        :name_generator_type,
        :default_pxe_item_global,
        :default_pxe_item_local,
        :puppet_interval,
        :outofsync_interval,
        :default_puppet_environment,
        :modulepath,
        :puppetrun,
        :puppet_server,
        :update_ip_from_built_request
      ]

      def initialize
        @allowed_variables = DEFAULT_ALLOWED_VARIABLES
        @allowed_global_settings = DEFAULT_ALLOWED_GLOBAL_SETTINGS
        @allowed_generic_helpers = DEFAULT_ALLOWED_GENERIC_HELPERS
        @allowed_host_helpers = DEFAULT_ALLOWED_HOST_HELPERS
      end

      attr_accessor :allowed_variables, :allowed_global_settings,
                    :allowed_generic_helpers, :allowed_host_helpers

      def allowed_helpers
        allowed_generic_helpers + allowed_host_helpers
      end
    end
  end
end
