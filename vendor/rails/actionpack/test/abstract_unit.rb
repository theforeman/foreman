$:.unshift(File.dirname(__FILE__) + '/../lib')
$:.unshift(File.dirname(__FILE__) + '/../../activesupport/lib')
$:.unshift(File.dirname(__FILE__) + '/fixtures/helpers')
$:.unshift(File.dirname(__FILE__) + '/fixtures/alternate_helpers')

require 'rubygems'
require 'yaml'
require 'stringio'
require 'test/unit'

gem 'mocha', '>= 0.9.5'
require 'mocha'

begin
  require 'ruby-debug'
  Debugger.settings[:autoeval] = true
  Debugger.start
rescue LoadError
  # Debugging disabled. `gem install ruby-debug` to enable.
end

require 'action_controller'
require 'action_controller/cgi_ext'
require 'action_controller/test_process'
require 'action_view/test_case'

# Show backtraces for deprecated behavior for quicker cleanup.
ActiveSupport::Deprecation.debug = true

ActionController::Base.logger = nil
ActionController::Routing::Routes.reload rescue nil

ActionController::Base.session_store = nil

# Register danish language for testing
I18n.backend.store_translations 'da', {}
I18n.backend.store_translations 'pt-BR', {}
ORIGINAL_LOCALES = I18n.available_locales.map(&:to_s).sort

FIXTURE_LOAD_PATH = File.join(File.dirname(__FILE__), 'fixtures')
ActionView::Base.cache_template_loading = true
ActionController::Base.view_paths = FIXTURE_LOAD_PATH
CACHED_VIEW_PATHS = ActionView::Base.cache_template_loading? ?
                      ActionController::Base.view_paths :
                      ActionController::Base.view_paths.map {|path| ActionView::Template::EagerPath.new(path.to_s)}
