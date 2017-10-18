module Api
  module TaxonomyScope
    extend ActiveSupport::Concern

    included do
      Foreman::Deprecation.deprecation_warning('1.18', 'Api::TaxonomyScope has been removed, if your plugin includes it, please remove it. Including it has no effect and the empty concern will be removed.')
    end

    def set_taxonomy_scope
      Foreman::Deprecation.deprecation_warning('1.18', 'Api::TaxonomyScope#set_taxonomy_scope has been removed, if your plugin uses it, please remove it. The method has no effect and is replaced by set_taxonomy which is automatically executed before every controller action.')
    end
  end
end
