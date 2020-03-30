# Drops the support of foreign keys for sqlite as they do not support naming
module Foreman
  module DisableForeignKeys
    def supports_foreign_keys?
      false
    end

    def add_foreign_key(from_table, to_table, **options)
      # pass
    end

    def remove_foreign_key(from_table, to_table = nil, **options)
      # pass
    end
  end
end

ActiveSupport.on_load(:active_record_sqlite3adapter) do
  prepend Foreman::DisableForeignKeys
end
