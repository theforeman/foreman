require 'rake'

Gem::Specification.new do |s|
  s.name = %q{safemode}
  s.version = 1.0
  s.date = %q{2010-11-30}
  s.authors = %q{foobar}
  s.email = %q{foo@foobar.org}
  s.summary = %q{safemode does stuff that is safe}
  s.homepage = %q{http://safemode.org}
  s.description = %q{this is a desc}
  s.add_dependency 'ruby2ruby'
  s.add_dependency 'sexp'
  s.add_dependency 'ruby_parser'
  s.files = FileList["LICENCSE", "README.markdown", "init.rb", "lib/safemode.rb", "lib/**/*"].to_a
#"lib/safemode.rb", "lib/safemode/*", "lib/haml/*", "lib/action_view/*"].to_a
end
