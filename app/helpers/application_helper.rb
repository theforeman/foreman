# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def graph(type,opts = {})
    Gchart.send(type, {:size => '400x150', :bg => "E6DFCF", :format => "image_tag"}.merge(opts))
  end

end
