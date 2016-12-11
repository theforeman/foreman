object @parameter

if params["show_hidden"] == "true" && @object.editable_by_user?
  attribute locals[:value]
else
  attribute :safe_value => locals[:value]
end
