require File.dirname(__FILE__) + '/spec_helper.rb'
require File.dirname(__FILE__) + '/../lib/gchart'

Chart::Theme.add_theme_file("#{File.dirname(__FILE__)}/fixtures/test_theme.yml")

# Time to add your specs!
# http://rspec.rubyforge.org/
describe "generating a default Gchart" do
  
  before(:each) do
    @chart = Gchart.line
  end
  
  it "should include the Google URL" do
    @chart.include?("http://chart.apis.google.com/chart?").should be_true
  end
  
  it "should have a default size" do
    @chart.include?('chs=300x200').should be_true
  end
  
  it "should be able to have a custom size" do
    Gchart.line(:size => '400x600').include?('chs=400x600').should be_true
    Gchart.line(:width => 400, :height => 600).include?('chs=400x600').should be_true
  end
  
  it "should have a type" do
    @chart.include?('cht=lc').should be_true
  end
  
  it 'should use theme defaults if theme is set' do
    Gchart.line(:theme=>:test).include?('chco=6886B4,FDD84E').should be_true
    Gchart.line(:theme=>:test).include?(Gchart.jstize('chf=c,s,FFFFFF|bg,s,FFFFFF')).should be_true
  end
  
  it "should use the simple encoding by default with auto max value" do
    # 9 is the max value in simple encoding, 26 being our max value the 2nd encoded value should be 9
    Gchart.line(:data => [0, 26]).include?('chd=s:A9').should be_true
    Gchart.line(:data => [0, 26], :max_value => 26).should == Gchart.line(:data => [0, 26])
  end
  
  it "should support simple encoding with and without max_value" do
    Gchart.line(:data => [0, 26], :max_value => 26).include?('chd=s:A9').should be_true
    Gchart.line(:data => [0, 26], :max_value => false).include?('chd=s:Aa').should be_true
  end
  
  it "should support the extended encoding and encode properly" do
    Gchart.line(:data => [0, 10], :encoding => 'extended', :max_value => false).include?('chd=e:AA').should be_true
    Gchart.line(:encoding => 'extended', 
                :max_value => false,
                :data => [[0,25,26,51,52,61,62,63], [64,89,90,115,4084]]
                ).include?('chd=e:AAAZAaAzA0A9A-A.,BABZBaBz.0').should be_true
  end
  
  it "should auto set the max value for extended encoding" do
    Gchart.line(:data => [0, 25], :encoding => 'extended', :max_value => false).include?('chd=e:AAAZ').should be_true
    # Extended encoding max value is '..'
    Gchart.line(:data => [0, 25], :encoding => 'extended').include?('chd=e:AA..').should be_true
  end
  
  it "should be able to have data with text encoding" do
    Gchart.line(:data => [10, 5.2, 4, 45, 78], :encoding => 'text').include?('chd=t:10,5.2,4,45,78').should be_true
  end
  
  it "should be able to have muliple set of data with text encoding" do
    Gchart.line(:data => [[10, 5.2, 4, 45, 78], [20, 40, 70, 15, 99]], :encoding => 'text').include?(Gchart.jstize('chd=t:10,5.2,4,45,78|20,40,70,15,99')).should be_true
  end

  it "should be able to receive a custom param" do
    Gchart.line(:custom => 'ceci_est_une_pipe').include?('ceci_est_une_pipe').should be_true
  end
  
  it "should be able to set label axis" do
    Gchart.line(:axis_with_labels => 'x,y,r').include?('chxt=x,y,r').should be_true
    Gchart.line(:axis_with_labels => ['x','y','r']).include?('chxt=x,y,r').should be_true
  end
  
  it "should be able to have axis labels" do
   Gchart.line(:axis_labels => ['Jan|July|Jan|July|Jan', '0|100', 'A|B|C', '2005|2006|2007']).include?(Gchart.jstize('chxl=0:|Jan|July|Jan|July|Jan|1:|0|100|2:|A|B|C|3:|2005|2006|2007')).should be_true
   Gchart.line(:axis_labels => ['Jan|July|Jan|July|Jan']).include?(Gchart.jstize('chxl=0:|Jan|July|Jan|July|Jan')).should be_true
   Gchart.line(:axis_labels => [['Jan','July','Jan','July','Jan']]).include?(Gchart.jstize('chxl=0:|Jan|July|Jan|July|Jan')).should be_true
   Gchart.line(:axis_labels => [['Jan','July','Jan','July','Jan'], ['0','100'], ['A','B','C'], ['2005','2006','2007']]).include?(Gchart.jstize('chxl=0:|Jan|July|Jan|July|Jan|1:|0|100|2:|A|B|C|3:|2005|2006|2007')).should be_true
  end
  
end

describe "generating different type of charts" do
  
  it "should be able to generate a line chart" do
    Gchart.line.should be_an_instance_of(String)
    Gchart.line.include?('cht=lc').should be_true
  end
  
  it "should be able to generate a sparkline chart" do
    Gchart.sparkline.should be_an_instance_of(String)
    Gchart.sparkline.include?('cht=ls').should be_true
  end
  
  it "should be able to generate a line xy chart" do
    Gchart.line_xy.should be_an_instance_of(String)
    Gchart.line_xy.include?('cht=lxy').should be_true
  end
  
  it "should be able to generate a scatter chart" do
    Gchart.scatter.should be_an_instance_of(String)
    Gchart.scatter.include?('cht=s').should be_true
  end
  
  it "should be able to generate a bar chart" do
    Gchart.bar.should be_an_instance_of(String)
    Gchart.bar.include?('cht=bvs').should be_true
  end
  
  it "should be able to generate a Venn diagram" do
    Gchart.venn.should be_an_instance_of(String)
    Gchart.venn.include?('cht=v').should be_true
  end
  
  it "should be able to generate a Pie Chart" do
    Gchart.pie.should be_an_instance_of(String)
    Gchart.pie.include?('cht=p').should be_true
  end
  
  it "should be able to generate a Google-O-Meter" do
    Gchart.meter.should be_an_instance_of(String)
    Gchart.meter.include?('cht=gom').should be_true
  end
  
  it "should not support other types" do
    Gchart.sexy.should == "sexy is not a supported chart format, please use one of the following: #{Gchart.supported_types}."
  end
  
end

describe "a bar graph" do
  
  it "should have a default vertical orientation" do
    Gchart.bar.include?('cht=bvs').should be_true
  end
  
  it "should be able to have a different orientation" do
    Gchart.bar(:orientation => 'vertical').include?('cht=bvs').should be_true
    Gchart.bar(:orientation => 'v').include?('cht=bvs').should be_true
    Gchart.bar(:orientation => 'h').include?('cht=bhs').should be_true
    Gchart.bar(:orientation => 'horizontal').include?('cht=bhs').should be_true
    Gchart.bar(:horizontal => false).include?('cht=bvs').should be_true
  end
  
  it "should be set to be stacked by default" do
    Gchart.bar.include?('cht=bvs').should be_true
  end
  
  it "should be able to stacked or grouped" do
    Gchart.bar(:stacked => true).include?('cht=bvs').should be_true
    Gchart.bar(:stacked => false).include?('cht=bvg').should be_true
    Gchart.bar(:grouped => true).include?('cht=bvg').should be_true
    Gchart.bar(:grouped => false).include?('cht=bvs').should be_true
  end
  
  it "should be able to have different bar colors" do
    Gchart.bar(:bar_colors => 'efefef,00ffff').include?('chco=').should be_true
    Gchart.bar(:bar_colors => 'efefef,00ffff').include?('chco=efefef,00ffff').should be_true
    # alias
    Gchart.bar(:bar_color => 'efefef').include?('chco=efefef').should be_true
  end
  
  it "should be able to have different bar colors when using an array of colors" do
    Gchart.bar(:bar_colors => ['efefef','00ffff']).include?('chco=efefef,00ffff').should be_true
  end
  
  it 'should be able to accept a string of width and spacing options' do
    Gchart.bar(:bar_width_and_spacing => '25,6').include?('chbh=25,6').should be_true
  end
  
  it 'should be able to accept a single fixnum width and spacing option to set the bar width' do
    Gchart.bar(:bar_width_and_spacing => 25).include?('chbh=25').should be_true
  end
  
  it 'should be able to accept an array of width and spacing options' do
    Gchart.bar(:bar_width_and_spacing => [25,6,12]).include?('chbh=25,6,12').should be_true
    Gchart.bar(:bar_width_and_spacing => [25,6]).include?('chbh=25,6').should be_true
    Gchart.bar(:bar_width_and_spacing => [25]).include?('chbh=25').should be_true
  end
  
  describe "with a hash of width and spacing options" do
    
    before(:each) do
      @default_width         = 23
      @default_spacing       = 4
      @default_group_spacing = 8
    end
    
    it 'should be able to have a custom bar width' do
      Gchart.bar(:bar_width_and_spacing => {:width => 19}).include?("chbh=19,#{@default_spacing},#{@default_group_spacing}").should be_true
    end
    
    it 'should be able to have custom spacing' do
      Gchart.bar(:bar_width_and_spacing => {:spacing => 19}).include?("chbh=#{@default_width},19,#{@default_group_spacing}").should be_true
    end
    
    it 'should be able to have custom group spacing' do
      Gchart.bar(:bar_width_and_spacing => {:group_spacing => 19}).include?("chbh=#{@default_width},#{@default_spacing},19").should be_true
    end
    
  end
  
end

describe "a line chart" do
  
  before(:each) do
    @title = 'Chart Title'
    @legend = ['first data set label', 'n data set label']
    @chart = Gchart.line(:title => @title, :legend => @legend)
  end
  
  it 'should be able have a chart title' do
    @chart.include?("chtt=Chart+Title").should be_true
  end
  
  it "should be able to a custom color and size title" do
     Gchart.line(:title => @title, :title_color => 'FF0000').include?('chts=FF0000').should be_true
     Gchart.line(:title => @title, :title_size => '20').include?('chts=454545,20').should be_true
  end
  
  it "should be able to have multiple legends" do
    @chart.include?(Gchart.jstize("chdl=first+data+set+label|n+data+set+label")).should be_true
  end
  
  it "should be able to have one legend" do
    chart = Gchart.line(:legend => 'legend label')
    chart.include?("chdl=legend+label").should be_true
  end
  
  it "should be able to set the background fill" do
    Gchart.line(:bg => 'efefef').include?("chf=bg,s,efefef").should be_true
    Gchart.line(:bg => {:color => 'efefef', :type => 'solid'}).include?("chf=bg,s,efefef").should be_true
    
    Gchart.line(:bg => {:color => 'efefef', :type => 'gradient'}).include?("chf=bg,lg,0,efefef,0,ffffff,1").should be_true
    Gchart.line(:bg => {:color => 'efefef,0,ffffff,1', :type => 'gradient'}).include?("chf=bg,lg,0,efefef,0,ffffff,1").should be_true
    Gchart.line(:bg => {:color => 'efefef', :type => 'gradient', :angle => 90}).include?("chf=bg,lg,90,efefef,0,ffffff,1").should be_true
    
    Gchart.line(:bg => {:color => 'efefef', :type => 'stripes'}).include?("chf=bg,ls,90,efefef,0.2,ffffff,0.2").should be_true
  end
  
  it "should be able to set a graph fill" do
    Gchart.line(:graph_bg => 'efefef').include?("chf=c,s,efefef").should be_true
    Gchart.line(:graph_bg => {:color => 'efefef', :type => 'solid'}).include?("chf=c,s,efefef").should be_true
    Gchart.line(:graph_bg => {:color => 'efefef', :type => 'gradient'}).include?("chf=c,lg,0,efefef,0,ffffff,1").should be_true
    Gchart.line(:graph_bg => {:color => 'efefef,0,ffffff,1', :type => 'gradient'}).include?("chf=c,lg,0,efefef,0,ffffff,1").should be_true
    Gchart.line(:graph_bg => {:color => 'efefef', :type => 'gradient', :angle => 90}).include?("chf=c,lg,90,efefef,0,ffffff,1").should be_true
  end
  
  it "should be able to set both a graph and a background fill" do
    Gchart.line(:bg => 'efefef', :graph_bg => '76A4FB').include?("bg,s,efefef").should be_true
    Gchart.line(:bg => 'efefef', :graph_bg => '76A4FB').include?("c,s,76A4FB").should be_true
    Gchart.line(:bg => 'efefef', :graph_bg => '76A4FB').include?(Gchart.jstize("chf=c,s,76A4FB|bg,s,efefef")).should be_true
  end
  
  it "should be able to have different line colors" do
    Gchart.line(:line_colors => 'efefef|00ffff').include?(Gchart.jstize('chco=efefef|00ffff')).should be_true
    Gchart.line(:line_color => 'efefef|00ffff').include?(Gchart.jstize('chco=efefef|00ffff')).should be_true
  end
  
  it "should be able to render a graph where all the data values are 0" do
    Gchart.line(:data => [0, 0, 0]).include?("chd=s:AAA").should be_true
  end
  
end

describe "a sparkline chart" do
  
  before(:each) do
    @title = 'Chart Title'
    @legend = ['first data set label', 'n data set label']
    @jstized_legend = Gchart.jstize(@legend.join('|'))
    @data = [27,25,25,25,25,27,100,31,25,36,25,25,39,25,31,25,25,25,26,26,25,25,28,25,25,100,28,27,31,25,27,27,29,25,27,26,26,25,26,26,35,33,34,25,26,25,36,25,26,37,33,33,37,37,39,25,25,25,25]
    @chart = Gchart.sparkline(:title => @title, :data => @data, :legend => @legend)
  end
  
  it "should create a sparkline" do
    @chart.include?('cht=ls').should be_true
  end
  
  it 'should be able have a chart title' do
    @chart.include?("chtt=Chart+Title").should be_true
  end
  
  it "should be able to a custom color and size title" do
     Gchart.sparkline(:title => @title, :title_color => 'FF0000').include?('chts=FF0000').should be_true
     Gchart.sparkline(:title => @title, :title_size => '20').include?('chts=454545,20').should be_true
  end
  
  it "should be able to have multiple legends" do
    @chart.include?(Gchart.jstize("chdl=first+data+set+label|n+data+set+label")).should be_true
  end
  
  it "should be able to have one legend" do
    chart = Gchart.sparkline(:legend => 'legend label')
    chart.include?("chdl=legend+label").should be_true
  end
  
  it "should be able to set the background fill" do
    Gchart.sparkline(:bg => 'efefef').include?("chf=bg,s,efefef").should be_true
    Gchart.sparkline(:bg => {:color => 'efefef', :type => 'solid'}).include?("chf=bg,s,efefef").should be_true
           
    Gchart.sparkline(:bg => {:color => 'efefef', :type => 'gradient'}).include?("chf=bg,lg,0,efefef,0,ffffff,1").should be_true
    Gchart.sparkline(:bg => {:color => 'efefef,0,ffffff,1', :type => 'gradient'}).include?("chf=bg,lg,0,efefef,0,ffffff,1").should be_true
    Gchart.sparkline(:bg => {:color => 'efefef', :type => 'gradient', :angle => 90}).include?("chf=bg,lg,90,efefef,0,ffffff,1").should be_true
          
    Gchart.sparkline(:bg => {:color => 'efefef', :type => 'stripes'}).include?("chf=bg,ls,90,efefef,0.2,ffffff,0.2").should be_true
  end
  
  it "should be able to set a graph fill" do
    Gchart.sparkline(:graph_bg => 'efefef').include?("chf=c,s,efefef").should be_true
    Gchart.sparkline(:graph_bg => {:color => 'efefef', :type => 'solid'}).include?("chf=c,s,efefef").should be_true
    Gchart.sparkline(:graph_bg => {:color => 'efefef', :type => 'gradient'}).include?("chf=c,lg,0,efefef,0,ffffff,1").should be_true
    Gchart.sparkline(:graph_bg => {:color => 'efefef,0,ffffff,1', :type => 'gradient'}).include?("chf=c,lg,0,efefef,0,ffffff,1").should be_true
    Gchart.sparkline(:graph_bg => {:color => 'efefef', :type => 'gradient', :angle => 90}).include?("chf=c,lg,90,efefef,0,ffffff,1").should be_true
  end
  
  it "should be able to set both a graph and a background fill" do
    Gchart.sparkline(:bg => 'efefef', :graph_bg => '76A4FB').include?("bg,s,efefef").should be_true
    Gchart.sparkline(:bg => 'efefef', :graph_bg => '76A4FB').include?("c,s,76A4FB").should be_true
    Gchart.sparkline(:bg => 'efefef', :graph_bg => '76A4FB').include?(Gchart.jstize("chf=c,s,76A4FB|bg,s,efefef")).should be_true
  end
  
  it "should be able to have different line colors" do
    Gchart.sparkline(:line_colors => 'efefef|00ffff').include?(Gchart.jstize('chco=efefef|00ffff')).should be_true
    Gchart.sparkline(:line_color => 'efefef|00ffff').include?(Gchart.jstize('chco=efefef|00ffff')).should be_true
  end
  
end

describe "a 3d pie chart" do
  
  before(:each) do
    @title = 'Chart Title'
    @legend = ['first data set label', 'n data set label']
    @jstized_legend = Gchart.jstize(@legend.join('|'))
    @data = [12,8,40,15,5]
    @chart = Gchart.pie(:title => @title, :legend => @legend, :data => @data)
  end
  
  it "should create a pie" do
    @chart.include?('cht=p').should be_true
  end
  
  it "should be able to be in 3d" do
    Gchart.pie_3d(:title => @title, :legend => @legend, :data => @data).include?('cht=p3').should be_true
  end
  
  it "should be able to set labels by using the legend or labesl accessor" do
    Gchart.pie_3d(:title => @title, :legend => @legend, :data => @data).include?("chl=#{@jstized_legend}").should be_true
    Gchart.pie_3d(:title => @title, :labels => @legend, :data => @data).include?("chl=#{@jstized_legend}").should be_true
    Gchart.pie_3d(:title => @title, :labels => @legend, :data => @data).should == Gchart.pie_3d(:title => @title, :legend => @legend, :data => @data)
  end
  
end

describe "a google-o-meter" do

  before(:each) do
    @data = [70]
    @legend = ['arrow points here']
    @jstized_legend = Gchart.jstize(@legend.join('|'))
    @chart = Gchart.meter(:data => @data)
  end
  
  it "should create a meter" do
    @chart.include?('cht=gom').should be_true
  end
  
  it "should be able to set a solid background fill" do
    Gchart.meter(:bg => 'efefef').include?("chf=bg,s,efefef").should be_true
    Gchart.meter(:bg => {:color => 'efefef', :type => 'solid'}).include?("chf=bg,s,efefef").should be_true
  end
  
end

describe 'exporting a chart' do
  
  it "should be available in the url format by default" do
    Gchart.line(:data => [0, 26], :format => 'url').should == Gchart.line(:data => [0, 26])
  end
  
  it "should be available as an image tag" do
    Gchart.line(:data => [0, 26], :format => 'image_tag').should match(/<img src=(.*) width="300" height="200" alt="Google Chart" \/>/)
  end
  
  it "should be available as an image tag using img_tag alias" do
    Gchart.line(:data => [0, 26], :format => 'img_tag').should match(/<img src=(.*) width="300" height="200" alt="Google Chart" \/>/)
  end
  
  it "should be available as an image tag using custom dimensions" do
    Gchart.line(:data => [0, 26], :format => 'image_tag', :size => '400x400').should match(/<img src=(.*) width="400" height="400" alt="Google Chart" \/>/)
  end
 
  it "should be available as an image tag using custom alt text" do
    Gchart.line(:data => [0, 26], :format => 'image_tag', :alt => 'Sexy chart').should match(/<img src=(.*) width="300" height="200" alt="Sexy chart" \/>/)
  end
  
  it "should be available as an image tag using custom title text" do
    Gchart.line(:data => [0, 26], :format => 'image_tag', :title => 'Sexy chart').should match(/<img src=(.*) width="300" height="200" alt="Google Chart" title="Sexy chart" \/>/)
  end
  
  it "should be available as an image tag using custom css id selector" do
    Gchart.line(:data => [0, 26], :format => 'image_tag', :id => 'chart').should match(/<img id="chart" src=(.*) width="300" height="200" alt="Google Chart" \/>/)
  end
  
  it "should be available as an image tag using custom css class selector" do
    Gchart.line(:data => [0, 26], :format => 'image_tag', :class => 'chart').should match(/<img class="chart" src=(.*) width="300" height="200" alt="Google Chart" \/>/)
  end

  it "should use ampersands to separate key/value pairs in URLs by default" do
    Gchart.line(:data => [0, 26]).should satisfy {|chart| chart.include? "&" }
    Gchart.line(:data => [0, 26]).should_not satisfy {|chart| chart.include? "&amp;" }
  end
  
  it "should escape ampersands in URLs when used as an image tag" do
    Gchart.line(:data => [0, 26], :format => 'image_tag', :class => 'chart').should satisfy {|chart| chart.include? "&amp;" }
  end
   
  it "should be available as a file" do
    File.delete('chart.png') if File.exist?('chart.png')
    Gchart.line(:data => [0, 26], :format => 'file')
    File.exist?('chart.png').should be_true
    File.delete('chart.png') if File.exist?('chart.png')
  end
  
  it "should be available as a file using a custom file name" do
    File.delete('custom_file_name.png') if File.exist?('custom_file_name.png')
    Gchart.line(:data => [0, 26], :format => 'file', :filename => 'custom_file_name.png')
    File.exist?('custom_file_name.png').should be_true
    File.delete('custom_file_name.png') if File.exist?('custom_file_name.png')
  end
  
  it "should work even with multiple attrs" do
    File.delete('foo.png') if File.exist?('foo.png')
    Gchart.line(:size => '400x200',
                :data => [1,2,3,4,5],
                :axis_labels => [[1,2,3,4, 5], %w[foo bar]],
                :axis_with_labels => 'x,r',
                :format => "file",
                :filename => "foo.png"
                )
    File.exist?('foo.png').should be_true
    File.delete('foo.png') if File.exist?('foo.png')
  end
  
end