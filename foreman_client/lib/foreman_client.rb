module Apipie ; end

require 'apipie/client/base'
require 'json'
require 'yaml'

Object.const_set("ForemanClient", client_module = Module.new do
  def self.client_config
    @client_config ||= YAML.load_file("#{root}/#{name}/config.yml")
  end

  def self.root
    @root ||= File.expand_path(File.dirname(__FILE__))
  end

  def self.name
    "foreman_client"
  end

  def self.doc
    @doc ||= File.open("#{root}/#{name}/documentation.json", 'r') do |f|
      JSON.load(f.read)['docs']
    end
  end
end)

require 'foreman_client/version'
resource_files = Dir[File.expand_path("#{client_module.root}/#{client_module.name}/resources/*.rb", __FILE__)]
resource_files.each { |f| require f }
