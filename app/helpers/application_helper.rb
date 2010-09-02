# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

#  def graph(type,opts = {})
#    Gchart.send(type, {:size => '400x150', :bg => "E6DFCF", :format => "image_tag"}.merge(opts))
#  end

  def  graph(graphs) # data should be an array of arrays for individual graphs
        div =  "var os = Raphael(\"os\");
            os.g.txtattr.font = \"12px 'Fontin Sans', Fontin-Sans, sans-serif\";
            grin = function () {
                this.sector.stop();
                this.sector.scale(1.1, 1.1, this.cx, this.cy);
                if (this.label) {
                    this.label[0].stop();
                    this.label[0].scale(1.5);
                    this.label[1].attr({\"font-weight\": 20});
                }
            },
                grout = function () {
                this.sector.animate({scale: [1, 1, this.cx, this.cy]}, 500, \"bounce\");
                if (this.label) {
                    this.label[0].animate({scale: 1}, 500, \"bounce\");
                    this.label[1].attr({\"font-weight\": 400});
                }
		},
		fin = function () {
                        this.flag = os.g.popup(this.bar.x, this.bar.y, this.bar.value || \"0\").insertBefore(this);
                    },
                    fout = function () {
                        this.flag.animate({opacity: 0}, 300, function () {this.remove();});
                    };
                "
        graphs.each { |graph|
        type, data, title, gx, gy, legend = graph
	if type == "pie" then
        labels = []
        values = []
        # for some reason I am getting nill values in some of the hash which in turn makes the graph not show.
            data.each_pair { |l, d|
                label = l || "unknown"
                value = d || 0
                labels << "#{label} - ( %% - ## )"
                values << value
            }
            div += "os.g.text(#{gx}, #{gy - 85}, \"#{title}\").attr({\"font-size\": 14, \"font-weight\": 800});\n"
            div += "os.g.piechart(#{gx}, #{gy}, 75, #{values.inspect}, {legend: #{labels.inspect}, legendpos: \"east\"}).hover(grin, grout);\n"
	end
	if type == "bar" then
            div += "os.g.text(#{gx + 150 }, #{gy}, \"#{title}\").attr({\"font-size\": 14, \"font-weight\": 800});\n"
	    div += "os.g.barchart(#{gx}, #{gy}, 300, 150, #{data.inspect}, {stacked: false, type: \"soft\"}).hover(fin, fout); \n"

	end
	if type == "text" then
		# this is a total hack.. ugly.. and I am not happy with it..
		data.each { |lbl|
		div += "os.g.text(#{gx}, #{gy}, \"#{lbl.gsub('"', '')}\").attr({\"font-size\": 10}).rotate(#{legend});\n"
		gx = gx + title
		}
	end
        }
        div
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
