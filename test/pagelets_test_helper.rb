# Backup and restore the main pagelets manager instance so any global
# modifications made in tests are lost, but also any plugin or Foreman pagelets
# remain registered after the test.
module PageletsIsolation
  extend ActiveSupport::Concern

  included do
    setup :pagelets_backup
    teardown :pagelets_restore
  end

  def pagelets_backup
    @pagelets_backup = Pagelets::Manager.instance.dup
  end

  def pagelets_restore
    Pagelets::Manager.instance = @pagelets_backup
  end
end
