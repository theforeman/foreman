module Foreman
  module Renderer
    class Configuration
      include Foreman::Renderer::DocTemplates::BasicRubyMethods

      DEFAULT_ALLOWED_GENERIC_HELPERS = [
        :foreman_url,
        :snippet, :snippets,
        :snippet_if_exists,
        :indent,
        :foreman_server_fqdn, :foreman_server_url,
        :foreman_request_addr,
        :log_debug, :log_info, :log_warn, :log_error, :log_fatal,
        :template_name,
        :dns_lookup,
        :pxe_kernel_options,
        :save_to_file,
        :subnet_param, :subnet_has_param?,
        :global_setting,
        :default_template_url,
        :plugin_present?,
        :medium_provider,
        :medium_uri,
        :user_auth_source_name,
        :all_host_statuses,
        :all_host_statuses_hash,
        :host_status,
        :preview?,
        :raise,
        :input,
        :input_resource,
        :rand,
        :rand_hex,
        :rand_name,
        :mac_name,
        :host_kernel_release,
        :host_uptime_seconds,
        :host_memory,
        :host_sockets,
        :host_cores,
        :host_virtual,
        :number_to_currency,
        :number_to_human,
        :number_to_percentage,
        :number_with_delimiter,
        :number_with_precision,
        :number_to_human_size,
        :gem_version_compare,
        :sequence_hostgroup_param_next,
        :transpile_coreos_linux_config,
        :transpile_fedora_coreos_config,
        :parse_yaml,
        :parse_json,
        :to_json,
        :to_yaml,
        :foreman_server_ca_cert,
        :format_time,
        :shell_escape,
        :join_with_line_break,
        :current_date,
        :truthy?,
        :falsy?,
        :previous_revision,
        :foreman_short_version
      ]

      DEFAULT_ALLOWED_HOST_HELPERS = [
        :grub_pass,
        :ks_console,
        :root_pass,
        :media_path,
        :match,
        :host_param_true?, :host_param_false?,
        :host_param, :host_param!,
        :host_puppet_server,
        :host_puppet_ca_server,
        :host_puppet_environment,
        :host_enc,
        :install_packages,
        :update_packages
      ]

      DEFAULT_ALLOWED_VARIABLES = [
        :additional_media,
        :arch,
        :dynamic,
        :host,
        :initrd,
        :kernel,
        :initrd_uri,
        :kernel_uri,
        :mediapath,
        :mediaserver,
        :osver,
        :preseed_path,
        :preseed_server,
        :provisioning_type,
        :repos,
        :static,
        :template_name,
        :xen,
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
        :token_duration,
        :dns_timeout,
        :name_generator_type,
        :default_pxe_item_global,
        :default_pxe_item_local,
        :puppet_interval,
        :outofsync_interval,
        :default_puppet_environment,
        :update_ip_from_built_request,
      ]

      DEFAULT_ALLOWED_LOADERS = Foreman::Renderer::Scope::Macros::Loaders::LOADERS.map(&:first)

      def initialize
        @allowed_variables = DEFAULT_ALLOWED_VARIABLES
        @allowed_global_settings = DEFAULT_ALLOWED_GLOBAL_SETTINGS
        @allowed_generic_helpers = DEFAULT_ALLOWED_GENERIC_HELPERS
        @allowed_host_helpers = DEFAULT_ALLOWED_HOST_HELPERS
        @allowed_loaders = DEFAULT_ALLOWED_LOADERS
      end

      attr_accessor :allowed_variables, :allowed_global_settings,
        :allowed_generic_helpers, :allowed_host_helpers, :allowed_loaders

      def allowed_helpers
        allowed_generic_helpers + allowed_host_helpers + allowed_loaders
      end
    end
  end
end
