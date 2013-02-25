require 'facts_importer'

module Host
  class Base < ActiveRecord::Base
    set_table_name = "hosts"
  end
end
