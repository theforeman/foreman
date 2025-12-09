# Callback to update OIDC redirect URIs when foreman_url setting changes
# This ensures redirect URIs stay in sync with the configured Foreman URL
# We cannot compose the URI from the setting dynamically because it is not available at boot time.

Rails.application.config.to_prepare do
  Setting.class_eval do
    after_save :update_oidc_redirect_uris_if_foreman_url_changed

    private

    def update_oidc_redirect_uris_if_foreman_url_changed
      return unless name == 'foreman_url' && saved_change_to_value?

      Rails.logger.info "OIDC: foreman_url changed, updating all OIDC redirect URIs"
      AuthSourceOidc.update_all_redirect_uris
    end
  end
end
