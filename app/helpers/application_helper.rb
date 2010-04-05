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

end
