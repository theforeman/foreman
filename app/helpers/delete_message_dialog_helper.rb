module DeleteMessageDialogHelper
  def mount_delete_message_dialog(id)
    mount_react_component('DeleteMessageDialog', "##{id}", {}.to_json)
  end
end
