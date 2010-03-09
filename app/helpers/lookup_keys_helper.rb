module LookupKeysHelper
  def add_value_link(name)
    link_to_function name do |page|
    page.insert_html :bottom, :values, :partial => 'value', :object => LookupValue.new
    end
  end
end
