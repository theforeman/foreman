require 'facts_importer'

module Host
  class Base < ActiveRecord::Base

    self.table_name = "hosts"

  end
end