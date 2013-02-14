require 'facts_importer'

module Host
  class Base < ActiveRecord::Base
    include Foreman::STI
    set_table_name :hosts

  end
end
