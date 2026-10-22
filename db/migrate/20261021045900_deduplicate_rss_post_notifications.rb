class DeduplicateRssPostNotifications < ActiveRecord::Migration[7.0]
  # Keep the oldest notification per message for the rss_post blueprint and
  # drop the rest. Trailing whitespace in feed titles caused the same post to
  # be stored repeatedly (lookup used the unstripped title; StripWhitespace
  # saved the stripped one).
  def up
    blueprint_id = connection.select_value(
      "SELECT id FROM notification_blueprints WHERE name = 'rss_post'"
    )
    return unless blueprint_id

    sql = <<~SQL
      SELECT string_agg(id::text, ',' ORDER BY id)
        FROM notifications
       WHERE notification_blueprint_id = #{blueprint_id.to_i}
       GROUP BY message
      HAVING COUNT(*) > 1
    SQL

    connection.select_values(sql).each do |ids|
      keeper, *extras = ids.split(',')
      next if extras.empty?

      say "rss_post: keeping id #{keeper}, deleting #{extras.size} duplicate(s): #{extras.join(', ')}"
      connection.execute(
        "DELETE FROM notification_recipients WHERE notification_id IN (#{extras.join(',')})"
      )
      connection.execute(
        "DELETE FROM notifications WHERE id IN (#{extras.join(',')})"
      )
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
