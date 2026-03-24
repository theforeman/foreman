module TemporarySettingsTestHelper
  def with_temporary_settings(**kwargs)
    old_settings = SETTINGS.dup
    begin
      SETTINGS.update(kwargs)

      yield
    ensure
      SETTINGS.replace(old_settings)
    end
  end
end
