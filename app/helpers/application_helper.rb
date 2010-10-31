# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def graph(type,opts = {})
    Gchart.send(type, {:size => '400x150', :bg => "E6DFCF", :format => "image_tag"}.merge(opts))
  end

  def show_habtm associations
    render :partial => 'common/show_habtm', :collection => associations, :as => :association
  end

  def edit_habtm klass, association
    render :partial => 'common/edit_habtm', :locals =>{ :klass => klass, :associations => association.all.delete_if{|e| e == klass}}
  end

  def link_to_remove_fields(name, f)
    f.hidden_field(:_destroy) + link_to_function(image_tag("false.png", :title => "remove"), "remove_fields(this)")
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
    link_to_function image_tag("delete.png") + " " + klass.name do |page|
      page["selected_puppetclass_#{klass.id}"].remove
      #TODO if the class is already selected, removing it will not add it to the avail class list
      page << "if ($('puppetclass_#{klass.id}')) {"
      page["puppetclass_#{klass.id}"].show
      page << "}"
    end
  end

  def link_to_add_puppetclass klass, type
    # link to remote is faster than inline js when having many classes
    link_to_remote "&nbsp;&nbsp;&nbsp;" + image_tag("add.png") + " " + klass.klass,
      :url => assign_puppetclass_path(klass, :type => type),
      :position => {:after => {:success => "selected_classes" }}
  end

  def searchtab title, search, options
    opts = {:action => params[:action], :tab_name => title, :search => search}
    selected_class = options[:selected] ? "selectedtab" : ""
    content_tag(:li) do
      link_to opts, :class => selected_class do
        title + (options[:no_close_button] ? "": (link_to "x", opts.merge(:remove_me => true), :class => "#{selected_class} close"))
      end
    end
  end

  def toggle_searchbar
    update_page do |page|
      page['search'].toggle
      page['tabs'].toggle
    end
  end

  # a simple helper to load the google JS only on pages which requires it
  def gcharts_script
    content_for :head do
      "<script src=http://www.google.com/jsapi></script>"
    end
  end

  def fact_name_select
    param = params[:search]["#{@via}fact_name_id_eq"] if params[:search]
    return param.to_i unless param.empty?
    return @fact_name_id if @fact_name_id
  end
end
