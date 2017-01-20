object @parameter

if @object.editable_by_user? && (params["show_hidden"] == "true" || params["show_hidden_parameters"] == "true")
  attribute locals[:value]
else
  attribute :safe_value => locals[:value]
end
