object @environment => nil

attributes :name

node(:actions) do |environment|
  actions = []
  actions << 'new' if @changed['new'][environment.name].present?
  actions << 'updated' if @changed['updated'][environment.name].present?
  actions << 'obsolete' if @changed['obsolete'][environment.name].present?
  actions << 'ignored' if @changed['ignored'][environment.name].present?
  actions.as_json
end

node(:new_puppetclasses, :if => ->(environment) { @changed['new'][environment.name].present? }) do |environment|
  JSON.parse(@changed['new'][environment.name]).keys
end

node(:updated_puppetclasses, :if => ->(environment) { @changed['updated'][environment.name].present? }) do |environment|
  JSON.parse(@changed['updated'][environment.name]).keys
end

node(:obsolete_puppetclasses, :if => ->(environment) { @changed['obsolete'][environment.name].present? && !@changed['obsolete'][environment.name].match(/_destroy_/) }) do |environment|
  JSON.parse(@changed['obsolete'][environment.name])
end

node(:ignored_puppetclasses, :if => ->(environment) { @changed['ignored'][environment.name].present? && !@changed['ignored'][environment.name].match(/_ignored_/) }) do |environment|
  JSON.parse(@changed['ignored'][environment.name])
end

node(:removed_environment, :if => ->(environment) { @changed['obsolete'][environment.name].present? && @changed['obsolete'][environment.name].match(/_destroy_/) }) do |environment|
  environment.name
end

node(:ignored_environment, :if => ->(environment) { @changed['ignored'][environment.name].present? && @changed['ignored'][environment.name].match(/_ignored_/) }) do |environment|
  environment.name
end
