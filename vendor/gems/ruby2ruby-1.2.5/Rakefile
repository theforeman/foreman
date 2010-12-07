# -*- ruby -*-

require 'rubygems'
require 'hoe'

Hoe.add_include_dirs("lib",
                     "../../ParseTree/dev/test",
                     "../../ruby_parser/dev/lib",
                     "../../sexp_processor/dev/lib")

Hoe.plugin :seattlerb

Hoe.spec 'ruby2ruby' do
  developer 'Ryan Davis', 'ryand-ruby@zenspider.com'

  self.rubyforge_name = 'seattlerb'

  extra_deps     << ["sexp_processor", "~> 3.0"]
  extra_deps     << ["ruby_parser",    "~> 2.0"]
  extra_dev_deps << ["ParseTree",      "~> 3.0"]
end

task :stress do
  $: << "lib"
  $: << "../../ruby_parser/dev/lib"
  require "ruby_parser"
  require "ruby2ruby"
  require "pp"

  files = Dir["../../*/dev/**/*.rb"]

  warn "Stress testing against #{files.size} files"
  parser    = RubyParser.new
  ruby2ruby = Ruby2Ruby.new

  bad = {}

  files.each do |file|
    warn file
    ruby = File.read(file)

    begin
      sexp = parser.process(ruby, file)

      # $stderr.puts sexp.pretty_inspect

      ruby2ruby.process(sexp)
    rescue Interrupt => e
      raise e
    rescue Exception => e
      bad[file] = e
    end
  end

  pp bad
end

# vim: syntax=ruby
