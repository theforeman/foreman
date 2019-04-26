module ReactAppHelper
  def mount_react_app
    mount_react_component('ReactApp', "#react-app-root", react_app_data.to_json)
  end

  def react_app_data
    { layout: layout_data }
  end
end
