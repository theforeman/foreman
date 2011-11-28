# Usage:  rake db:convert:prod2dev
#
# It assumes the development database has a schema identical to the production
# database, but will delete any data before importing the production data
#
# A couple of the outer loops evolved from
#    http://snippets.dzone.com/posts/show/3393
#
# For further instructions see
#    http://myutil.com/2008/8/31/rake-task-transfer-rails-database-mysql-to-postgres
#
# The master repository for this script is at github:
#    http://github.com/face/rails_db_convert_using_adapters/tree/master
#
#
# Author: Rama McIntosh
#         Matson Systems, Inc.
#         http://www.matsonsystems.com
#
# This rake task is released under this BSD license:
#
# Copyright (c) 2008, Matson Systems, Inc. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# * Redistributions of source code must retain the above copyright
#   notice, this list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in the
#   documentation and/or other materials provided with the distribution.
# * Neither the name of Matson Systems, Inc. nor the names of its
#   contributors may be used to endorse or promote products derived
#   from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
# COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
# ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

# PAGE_SIZE is the number of rows updated in a single transaction.
# This facilitates tables where the number of rows exceeds the systems
# memory
PAGE_SIZE=10000

namespace :db do
  namespace :convert do
    desc 'Convert/import production data to development.   DANGER Deletes all data in the development database.
          Assumes both schemas are already migrated. Optional parameters: access this table for this many records'
    task :prod2dev, [:table, :records] => :environment do |t, args|

      # We need unique classes so ActiveRecord can hash different connections
      # We do not want to use the real Model classes because any business
      # rules will likely get in the way of a database transfer
      class ProductionModelClass < ActiveRecord::Base
      end
      class DevelopmentModelClass < ActiveRecord::Base
      end

      skip_tables = ["schema_info", "schema_migrations", "hosts_backup"]
      ActiveRecord::Base.establish_connection(:production)
      if args.table
        tables = [args.table]
      else
        tables = ActiveRecord::Base.connection.tables - skip_tables
      end

      tables.each do |table_name|

        ProductionModelClass.set_table_name(table_name)
        DevelopmentModelClass.set_table_name(table_name)
        DevelopmentModelClass.establish_connection(:development)
        DevelopmentModelClass.reset_column_information
        ProductionModelClass.reset_column_information
        DevelopmentModelClass.record_timestamps = false

        # Page through the data in case the table is too large to fit in RAM
        offset = count = 0
        print "Converting #{table_name}..."; STDOUT.flush
        # First, delete any old dev data
        DevelopmentModelClass.delete_all
        while ((models = ProductionModelClass.all(:offset=>offset, :limit=>PAGE_SIZE)).size > 0)

          count += models.size
          offset += PAGE_SIZE

          # Now, write out the prod data to the dev db
          DevelopmentModelClass.transaction do
            models.each do |model|
              new_model = DevelopmentModelClass.new(model.attributes)
              new_model.id = model.id
              new_model.save(:validate => false)
            end
          end
          break if args.records and args.records.to_i > offset
        end
        print "#{count} records converted\n"
      end
    end
  end
end
