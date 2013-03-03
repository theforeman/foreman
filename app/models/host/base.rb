require 'facts_importer'

module Host
  class Base < ActiveRecord::Base
    include Foreman::STI
    self.table_name = "hosts"
  end
end
