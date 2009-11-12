$:.unshift File.dirname(__FILE__)
require 'gchart/version'
require 'gchart/theme'
require "open-uri"
require "uri"

class Gchart

  include GchartInfo
  
  @@url = "http://chart.apis.google.com/chart?"  
  @@types = ['line', 'line_xy', 'scatter', 'bar', 'venn', 'pie', 'pie_3d', 'jstize', 'sparkline', 'meter']
  @@simple_chars = ('A'..'Z').to_a + ('a'..'z').to_a + ('0'..'9').to_a
  @@chars = @@simple_chars + ['-', '.']
  @@ext_pairs = @@chars.map { |char_1| @@chars.map { |char_2| char_1 + char_2 } }.flatten
  @@file_name = 'chart.png'
  
  attr_accessor :title, :type, :width, :height, :horizontal, :grouped, :legend, :data, :encoding, :max_value, :bar_colors,
                :title_color, :title_size, :custom, :axis_with_labels, :axis_labels, :bar_width_and_spacing, :id, :alt, :class
    
  # Support for Gchart.line(:title => 'my title', :size => '400x600')
  def self.method_missing(m, options={})
    # Start with theme defaults if a theme is set
    theme = options[:theme]
    options = theme ? Chart::Theme.load(theme).to_options.merge(options) : options 
    # Extract the format and optional filename, then clean the hash
    format = options[:format] || 'url'
    @@file_name = options[:filename] unless options[:filename].nil?
    options.delete(:format)
    options.delete(:filename)
    # create the chart and return it in the format asked for
    if @@types.include?(m.to_s)  
      chart = new(options.merge!({:type => m}))
      chart.send(format)
    elsif m.to_s == 'version' 
      Gchart::VERSION::STRING
    else
      "#{m} is not a supported chart format, please use one of the following: #{supported_types}."
    end  
  end
  
  def initialize(options={})
      @type = :line
      @data = []
      @width = 300
      @height = 200
      @horizontal = false
      @grouped = false
      @encoding = 'simple'
      @max_value = 'auto'
      # Sets the alt tag when chart is exported as image tag
      @alt = 'Google Chart'
      # Sets the CSS id selector when chart is exported as image tag
      @id = false
      # Sets the CSS class selector when chart is exported as image tag
      @class = false

      # set the options value if definable
      options.each do |attribute, value| 
          send("#{attribute.to_s}=", value) if self.respond_to?("#{attribute}=")
      end
  end
  
  def self.supported_types
    @@types.join(' ')
  end
  
  # Defines the Graph size using the following format:
  # width X height
  def size=(size='300x200')
    @width, @height = size.split("x").map { |dimension| dimension.to_i }
  end
  
  def size
    "#{@width}x#{@height}"
  end
  
  # Sets the orientation of a bar graph
  def orientation=(orientation='h')
    if orientation == 'h' || orientation == 'horizontal'
      self.horizontal = true
    elsif orientation == 'v' || orientation == 'vertical'
      self.horizontal = false
    end
  end
  
  # Sets the bar graph presentation (stacked or grouped)
  def stacked=(option=true)
   @grouped = option ? false : true
  end
  
  def bg=(options)
    if options.is_a?(String)
      @bg_color = options
    elsif options.is_a?(Hash)
      @bg_color = options[:color]
      @bg_type = options[:type]
      @bg_angle = options[:angle]
    end
  end
  
  def graph_bg=(options)
    if options.is_a?(String)
      @chart_color = options
    elsif options.is_a?(Hash)
      @chart_color = options[:color]
      @chart_type = options[:type]
      @chart_angle = options[:angle]
    end
  end
  
  def self.jstize(string)
    string.gsub(' ', '+').gsub(/\[|\{|\}|\||\\|\^|\[|\]|\`|\]/) {|c| "%#{c[0].to_s(16).upcase}"}
  end    
  # load all the custom aliases
  require 'gchart/aliases'
  
  protected
  
  # Returns the chart's generated PNG as a blob. (borrowed from John's gchart.rubyforge.org)
  def fetch
    open(query_builder) { |io| io.read }
  end

  # Writes the chart's generated PNG to a file. (borrowed from John's gchart.rubyforge.org)
  def write(io_or_file=@@file_name)
    return io_or_file.write(fetch) if io_or_file.respond_to?(:write)
    open(io_or_file, "w+") { |io| io.write(fetch) }
  end
  
  # Format
  
  def image_tag
    image = "<img"
    image += " id=\"#{@id}\"" if @id  
    image += " class=\"#{@class}\"" if @class      
    image += " src=\"#{query_builder(:html)}\""
    image += " width=\"#{@width}\""
    image += " height=\"#{@height}\""
    image += " alt=\"#{@alt}\""
    image += " title=\"#{@title}\"" if @title
    image += " />"
  end
  
  alias_method :img_tag, :image_tag
  
  def url
    query_builder
  end
  
  def file
    write
  end
  
  #
  def jstize(string)
    Gchart.jstize(string)
  end
  
  private
  
  # The title size cannot be set without specifying a color.
  # A dark key will be used for the title color if no color is specified 
  def set_title
    title_params = "chtt=#{title}"
    unless (title_color.nil? && title_size.nil? )
      title_params << "&chts=" + (color, size = (@title_color || '454545'), @title_size).compact.join(',')
    end
    title_params
  end
  
  def set_size
    "chs=#{size}"
  end
  
  def set_data
    data = send("#{@encoding}_encoding", @data)
    "chd=#{data}"
  end
  
  def set_colors
    bg_type = fill_type(@bg_type) || 's' if @bg_color
    chart_type = fill_type(@chart_type) || 's' if @chart_color
    
    "chf=" + {'bg' => fill_for(bg_type, @bg_color, @bg_angle), 'c' => fill_for(chart_type, @chart_color, @chart_angle)}.map{|k,v| "#{k},#{v}" unless v.nil?}.compact.join('|')      
  end
  
  # set bar, line colors
  def set_bar_colors
    @bar_colors = @bar_colors.join(',') if @bar_colors.is_a?(Array)
    "chco=#{@bar_colors}"
  end
  
  # set bar spacing
  # chbh=
  # <bar width in pixels>,
  # <optional space between bars in a group>,
  # <optional space between groups>
  def set_bar_width_and_spacing
    width_and_spacing_values = case @bar_width_and_spacing
    when String
      @bar_width_and_spacing
    when Array
      @bar_width_and_spacing.join(',')
    when Hash
      width = @bar_width_and_spacing[:width] || 23
      spacing = @bar_width_and_spacing[:spacing] || 4
      group_spacing = @bar_width_and_spacing[:group_spacing] || 8
      [width,spacing,group_spacing].join(',')
    else
      @bar_width_and_spacing.to_s
    end
    "chbh=#{width_and_spacing_values}"
  end
  
  def fill_for(type=nil, color='', angle=nil)
    unless type.nil? 
      case type
        when 'lg'
          angle ||= 0
          color = "#{color},0,ffffff,1" if color.split(',').size == 1
          "#{type},#{angle},#{color}"
        when 'ls'
          angle ||= 90
          color = "#{color},0.2,ffffff,0.2" if color.split(',').size == 1
          "#{type},#{angle},#{color}"
        else
          "#{type},#{color}"
        end
    end
  end
  
  # A chart can have one or many legends. 
  # Gchart.line(:legend => 'label')
  # or
  # Gchart.line(:legend => ['first label', 'last label'])
  def set_legend
    return set_labels if @type == :pie || @type == :pie_3d || @type == :meter
    
    if @legend.is_a?(Array)
      "chdl=#{@legend.map{|label| "#{label}"}.join('|')}"
    else
      "chdl=#{@legend}"
    end
    
  end
  
  def set_labels
     if @legend.is_a?(Array)
        "chl=#{@legend.map{|label| "#{label}"}.join('|')}"
      else
        "chl=#{@legend}"
      end
  end
  
  def set_axis_with_labels
    @axis_with_labels = @axis_with_labels.join(',') if @axis_with_labels.is_a?(Array)
    "chxt=#{@axis_with_labels}"
  end
  
  def set_axis_labels
    labels_arr = []
    axis_labels.each_with_index do |labels,index| 
      if labels.is_a?(Array)
        labels_arr << "#{index}:|#{labels.join('|')}"
      else
        labels_arr << "#{index}:|#{labels}"
      end
    end
    "chxl=#{labels_arr.join('|')}"
  end
  
  def set_type
    case @type
      when :line
        "cht=lc"
      when :line_xy
        "cht=lxy"
      when :bar
        "cht=b" + (horizontal? ? "h" : "v") + (grouped? ? "g" : "s")
      when :pie_3d
        "cht=p3"
      when :pie
        "cht=p"
      when :venn
        "cht=v"
      when :scatter
        "cht=s"
      when :sparkline
        "cht=ls"
      when :meter
        "cht=gom"
      end
  end
  
  def fill_type(type)
    case type
    when 'solid'
      's'
    when 'gradient'
      'lg'
    when 'stripes'
      'ls'
    end
  end
  
  # Wraps a single dataset inside another array to support more datasets
  def prepare_dataset(ds)
    ds = [ds] unless ds.first.is_a?(Array)
    ds
  end
  
  def convert_to_simple_value(number)
    if number.nil?
      "_"
    else
      value = @@simple_chars[number.to_i]
      value.nil? ? "_" : value
    end
  end
  
  # http://code.google.com/apis/chart/#simple
  # Simple encoding has a resolution of 62 different values. 
  # Allowing five pixels per data point, this is sufficient for line and bar charts up
  # to about 300 pixels. Simple encoding is suitable for all other types of chart regardless of size.
  def simple_encoding(dataset=[])
    dataset = prepare_dataset(dataset)
    @max_value = dataset.compact.map{|ds| ds.compact.max}.max if @max_value == 'auto'
    
    if @max_value == false || @max_value == 'false' || @max_value == :false || @max_value == 0
      "s:" + dataset.map { |ds| ds.map { |number| number.nil? ? '_' : convert_to_simple_value(number) }.join }.join(',')
    else
      "s:" + dataset.map { |ds| ds.map { |number| number.nil? ? '_' : convert_to_simple_value( (@@simple_chars.size - 1) * number / @max_value) }.join }.join(',')
    end
    
  end
  
  # http://code.google.com/apis/chart/#text
  # Text encoding has a resolution of 1,000 different values, 
  # using floating point numbers between 0.0 and 100.0. Allowing five pixels per data point, 
  # integers (1.0, 2.0, and so on) are sufficient for line and bar charts up to about 500 pixels. 
  # Include a single decimal place (35.7 for example) if you require higher resolution. 
  # Text encoding is suitable for all other types of chart regardless of size.
  def text_encoding(dataset=[])
    dataset = prepare_dataset(dataset)
    "t:" + dataset.map{ |ds| ds.join(',') }.join('|')
  end
  
  def convert_to_extended_value(number)
    if number.nil?
      '__'
    else
      value = @@ext_pairs[number.to_i]
      value.nil? ? "__" : value
    end
  end
  
  # http://code.google.com/apis/chart/#extended
  # Extended encoding has a resolution of 4,096 different values 
  # and is best used for large charts where a large data range is required.
  def extended_encoding(dataset=[])
    
    dataset = prepare_dataset(dataset)
    @max_value = dataset.compact.map{|ds| ds.compact.max}.max if @max_value == 'auto'
    
    if @max_value == false || @max_value == 'false' || @max_value == :false
      "e:" +  dataset.map { |ds| ds.map { |number| number.nil? ? '__' : convert_to_extended_value(number)}.join }.join(',')
    else
      "e:" + dataset.map { |ds| ds.map { |number| number.nil? ? '__' : convert_to_extended_value( (@@ext_pairs.size - 1) * number / @max_value) }.join }.join(',')
    end
    
  end
  
  
  def query_builder(options="")
    query_params = instance_variables.map do |var|
      case var
      # Set the graph size  
      when '@width'
        set_size unless @width.nil? || @height.nil?
      when '@type'
        set_type
      when '@title'
        set_title unless @title.nil?
      when '@legend'
        set_legend unless @legend.nil?
      when '@bg_color'
        set_colors
      when '@chart_color'
        set_colors if @bg_color.nil?
      when '@data'
        set_data unless @data == []
      when '@bar_colors'
        set_bar_colors
      when '@bar_width_and_spacing'
        set_bar_width_and_spacing
      when '@axis_with_labels'
        set_axis_with_labels
      when '@axis_labels'
        set_axis_labels
      when '@custom'
        @custom
      end
    end.compact
    
    # Use ampersand as default delimiter
    unless options == :html
      delimiter = '&'
    # Escape ampersand for html image tags
    else
      delimiter = '&amp;'
    end
    
    jstize(@@url + query_params.join(delimiter))
  end
  
end
