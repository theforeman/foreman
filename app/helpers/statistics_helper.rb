module StatisticsHelper

  def pie_chart name, title, data
    function = <<-EOF
  $(function () {
    new Highcharts.Chart({
      chart: {
        renderTo: '#{name}',
        backgroundColor: "#EDF6FC"
      },
      credits: {
      enabled: false,
      },
      title: {
         text: '#{title}'
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
                  return '<b>'+ this.point.name +'</b>: '+ this.y;
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
end
