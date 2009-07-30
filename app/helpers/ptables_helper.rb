module PtablesHelper
  def layout_column record
    text_area :record, :layout, :disabled => true
  end

  def layout_form_column(record, field_name)
    text_area :record, :layout
  end
end
