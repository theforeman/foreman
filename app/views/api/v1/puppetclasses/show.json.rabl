object @puppetclass

attributes :name, :id

child :lookup_keys do
  extends "api/v1/lookup_keys/show"
end


