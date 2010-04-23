# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def graph(type,opts = {})
    Gchart.send(type, {:size => '400x150', :bg => "E6DFCF", :format => "image_tag"}.merge(opts))
  end

  def show_habtm associations
    render :partial => 'common/show_habtm', :collection => associations, :as => :association
  end

  def edit_habtm klass, association
    render :partial => 'common/edit_habtm', :locals =>{ :klass => klass, :associations => association.all}
  end

  def link_to_remove_fields(name, f)
    f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this)")
  end

  def link_to_add_fields(name, f, association, partial = nil)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render((partial.nil? ? association.to_s.singularize + "_fields" : partial), :f => builder)
    end
    link_to_function(name, h("add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")"))
  end

  def toggle_div div
    update_page do |page|
      page << "if ($('#{div}').visible()) {"
      page[div].visual_effect :BlindUp
      page << "} else {"
      page[div].visual_effect :BlindDown
      page << "}"
    end
  end

  def link_to_remove_puppetclass klass
    link_to_function klass.name do |page|
      page["selected_puppetclass_#{klass.id}"].remove
    end
  end

  def link_to_add_puppetclass klass, type
    # link to remote is faster than inline js when having many classes
    link_to_remote klass.klass,
      :url => assign_puppetclass_path(klass, :type => type),
      :position => {:after => {:success => "selected_classes" }}
  end

end
