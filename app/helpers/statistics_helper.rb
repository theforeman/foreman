module StatisticsHelper

  def pie_chart name, title, data
    function = <<-EOF
  $(function () {
    new Highcharts.Chart({
      chart: {
        renderTo: '#{name}',
        borderColor: '#909090',
        borderWidth: 1,
        backgroundColor: {
         linearGradient: [0, 0, 0, 200],
         stops: [
            [0, '#ffffff'],
            [1, '#EDEDED']
         ]}
      },
      credits: {
      enabled: false,
      },
      title: {
         text: '#{title}',
         style: {color: '#000000'}
      },
      tooltip: {
         formatter: function() {
            return '<b>'+ this.point.name +'</b>: '+ this.y;
         }
      },
      plotOptions: {
         pie: {
            allowPointSelect: true,
            cursor: 'pointer',
            dataLabels: {
               enabled: true,
               formatter: function() {
                  return  this.point.name + ': '+ this.y;
               }
            }
         }
      },
       series: [{
         type: 'pie',
         name: '',
         data: [ #{data.map{ |kv| "['#{kv[0]}', #{kv[1]}]"}.join(',')} ]
      }]
    });
  });
EOF
    content_tag(:div, nil,:id=>name,:class=>'statistics_pie') +
    javascript_tag(function)
  end

  def charts
    [
      pie_chart("os_dist" ,"OS Distribution", @os_count),
      pie_chart("arch_dist" ,"Architecture Distribution", @arch_count),
      pie_chart("env_dist" ,"Environments Distribution", @env_count),
      pie_chart("cpu_num" ,"Number of CPUs", @cpu_count),
      pie_chart("hardware" ,"Hardware", @model_count),
      pie_chart("class_dist" ,"Class Distribution", @klass_count),
      pie_chart("mem_usage" ,"Average memory usage", [["free memory (GB)",@mem_free],["used memory (GB)",@mem_size-@mem_free]]),
      pie_chart("swap_usage" ,"Average swap usage", [["free swap (GB)",@swap_free],["used swap (GB)",@swap_size-@swap_free]]),
      pie_chart("mem_totals" ,"Total memory usage", [["free memory (GB)", @mem_totfree],["used memory (GB)",@mem_totsize-@mem_totfree]]),
    ]
  end
end
