#!/usr/bin/ruby -ws

$f ||= false

$:.unshift "../../ruby_parser/dev/lib"
$:.unshift "../../ruby2ruby/dev/lib"

require 'rubygems'
require 'ruby2ruby'
require 'ruby_parser'

require 'gauntlet'

class RubyParserGauntlet < Gauntlet
  def initialize
    super

    self.data = Hash.new { |h,k| h[k] = {} }
    old_data = load_yaml data_file
    self.data.merge! old_data
  end

  def should_skip? name
    if $f then
      if Hash === data[name] then
        ! data[name].empty?
      else
        data[name]
      end
    else
      data[name] == true # yes, == true on purpose
    end
  end

  def diff_pp o1, o2
    require 'pp'

    File.open("/tmp/a.#{$$}", "w") do |f|
      PP.pp o1, f
    end

    File.open("/tmp/b.#{$$}", "w") do |f|
      PP.pp o2, f
    end

    `diff -u /tmp/a.#{$$} /tmp/b.#{$$}`
  ensure
    File.unlink "/tmp/a.#{$$}" rescue nil
    File.unlink "/tmp/b.#{$$}" rescue nil
  end

  def broke name, file, msg
    warn "bad"
    self.data[name][file] = msg
    self.dirty = true
  end

  def process path, name
    begin
      $stderr.print "  #{path}: "
      rp = RubyParser.new
      r2r = Ruby2Ruby.new

      old_ruby = File.read(path)

      begin
        old_sexp = rp.process old_ruby
      rescue Racc::ParseError => e
        self.data[name][path] = :unparsable
        self.dirty = true
        return
      end

      new_ruby = r2r.process old_sexp.deep_clone

      begin
        new_sexp = rp.process new_ruby
      rescue Racc::ParseError => e
        broke name, path, "couldn't parse new_ruby: #{e.message.strip}"
        return
      end

      if old_sexp != new_sexp then
        broke name, path, diff_pp(old_sexp, new_sexp)
        return
      end

      self.data[name][path] = true
      self.dirty = true

      warn "good"
    rescue Interrupt
      puts "User cancelled"
      exit 1
    rescue Exception => e
      broke name, path, "    UNKNOWN ERROR: #{e}: #{e.message.strip}"
    end
  end

  def run name
    warn name
    Dir["**/*.rb"].sort.each do |path|
      next if path =~ /gemspec.rb/ # HACK
      next if data[name][path] == true
      process path, name
    end

    if self.data[name].values.all? { |v| v == true } then
      warn "  ALL GOOD!"
      self.data[name] = true
      self.dirty = true
    end
  end
end

filter = ARGV.shift
filter = Regexp.new filter if filter

gauntlet = RubyParserGauntlet.new
gauntlet.run_the_gauntlet filter
