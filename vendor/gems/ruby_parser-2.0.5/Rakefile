# -*- ruby -*-

require 'rubygems'
require 'hoe'

Hoe.plugin :seattlerb

Hoe.add_include_dirs("../../ParseTree/dev/test",
                     "../../RubyInline/dev/lib",
                     "../../sexp_processor/dev/lib")

hoe = Hoe.spec 'ruby_parser' do
  developer 'Ryan Davis', 'ryand-ruby@zenspider.com'

  self.rubyforge_name = 'parsetree'

  extra_dev_deps << ['ParseTree',      '~> 3.0']
  extra_deps     << ['sexp_processor', '~> 3.0']
end

hoe.spec.files += ['lib/ruby_parser.rb'] # jim.... cmon man

[:default, :multi, :test].each do |t|
  task t => :parser
end

path = "pkg/ruby_parser-#{hoe.version}"
task path => :parser do
  Dir.chdir path do
    sh "rake parser"
  end
end

desc "build the parser"
task :parser => ["lib/ruby_parser.rb"]

rule '.rb' => '.y' do |t|
  # -v = verbose
  # -t = debugging parser ~4% reduction in speed -- keep for now
  # -l = no-line-convert
  sh "racc -v -t -l -o #{t.name} #{t.source}"
end

task :clean do
  rm_rf(Dir["**/*~"] +
        Dir["**/*.diff"] +
        Dir["coverage.info"] +
        Dir["coverage"] +
        Dir["lib/ruby_parser.rb"] +
        Dir["lib/*.output"])
end

def next_num(glob)
  num = Dir[glob].max[/\d+/].to_i + 1
end

desc "Compares PT to RP and deletes all files that match"
task :compare do
  files = Dir["unit/**/*.rb"]
  puts "Parsing #{files.size} files"
  files.each do |file|
    puts file
    system "./cmp.rb -q #{file} && rm #{file}"
  end
  system 'find -d unit -type d -empty -exec rmdir {} \;'
end

desc "Compares PT to RP and stops on first failure"
task :find_bug do
  files = Dir["unit/**/*.rb"]
  puts "Parsing #{files.size} files"
  files.each do |file|
    puts file
    sh "./cmp.rb -q #{file}"
  end
end

task :sort do
  sh 'grepsort "^ +def" lib/ruby_lexer.rb'
  sh 'grepsort "^ +def (test|util)" test/test_ruby_lexer.rb'
end

task :loc do
  loc1  = `wc -l ../1.0.0/lib/ruby_lexer.rb`[/\d+/]
  flog1 = `flog -s ../1.0.0/lib/ruby_lexer.rb`[/\d+\.\d+/]
  loc2  = `cat lib/ruby_lexer.rb lib/ruby_parser_extras.rb | wc -l`[/\d+/]
  flog2 = `flog -s lib/ruby_lexer.rb lib/ruby_parser_extras.rb`[/\d+\.\d+/]

  loc1, loc2, flog1, flog2 = loc1.to_i, loc2.to_i, flog1.to_f, flog2.to_f

  puts "1.0.0: loc = #{loc1} flog = #{flog1}"
  puts "dev  : loc = #{loc2} flog = #{flog2}"
  puts "delta: loc = #{loc2-loc1} flog = #{flog2-flog1}"
end

desc "Validate against all normal files in unit dir"
task :validate do
  sh "./cmp.rb unit/*.rb"
end

def run_and_log cmd, prefix
  files = ENV['FILES'] || 'unit/*.rb'
  p, x = prefix, "txt"
  n = Dir["#{p}.*.#{x}"].map { |s| s[/\d+/].to_i }.max + 1 rescue 1
  f = "#{p}.#{n}.#{x}"

  sh "#{cmd} #{Hoe::RUBY_FLAGS} bin/ruby_parse -q -g #{files} &> #{f}"

  puts File.read(f)
end

desc "Benchmark against all normal files in unit dir"
task :benchmark do
  run_and_log "ruby", "benchmark"
end

desc "Profile against all normal files in unit dir"
task :profile do
  run_and_log "zenprofile", "profile"
end

desc "what was that command again?"
task :huh? do
  puts "ruby #{Hoe::RUBY_FLAGS} bin/ruby_parse -q -g ..."
end

# vim: syntax=Ruby
