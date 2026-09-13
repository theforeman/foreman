class RenameCentosStreamMirrorToCentos < ActiveRecord::Migration[6.1]
  OLD_NAME = "CentOS Stream 9 mirror"
  NEW_NAME = "CentOS mirror"

  def up
    # Name column isn't unique, so we can't just rename and catch
    # ActiveRecord::RecordNotUnique
    old = Medium.unscoped.where(name: OLD_NAME)
    return unless old.exists?

    if Medium.unscoped.where(name: NEW_NAME).exists?
      logger.warn("Couldn't rename medium '#{OLD_NAME}' to '#{NEW_NAME}': already exists")
    else
      old.update_all(name: NEW_NAME)
    end
  end

  def down
    Medium.unscoped.where(name: NEW_NAME).update_all(name: OLD_NAME)
  end
end
