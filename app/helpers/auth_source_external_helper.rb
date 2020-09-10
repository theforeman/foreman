module AuthSourceExternalHelper
  def tab_classes_for_edit_auth_source_external
    if show_location_tab?
      { :location => 'active' }
    elsif show_organization_tab?
      { :organization => 'active' }
    else
      {}
    end
  end
end
