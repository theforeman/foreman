collection @settings.map { |s| SettingPresenter.from_setting(s) }

extends "api/v2/settings/main"
