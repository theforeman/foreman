# -*- encoding: utf-8 -*-
require File.expand_path('../lib/foreman_client/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["TODO"]
  gem.email         = ["TODO"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "foreman_client"
  gem.require_paths = ["lib"]
  gem.version       = ForemanClient::VERSION

  
  gem.add_dependency 'apipie-rails', '~> 0.0.12'
  gem.add_dependency 'json'
  gem.add_dependency 'rest-client', '>= 1.6.1'
  gem.add_dependency 'oauth'
end
