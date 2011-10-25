module DashboardHelper

  def count_reports()
    interval = Setting[:puppet_interval] / 10
    counter = []
    labels = []
    start =Time.now.utc - Setting[:puppet_interval].minutes
    (1..(Setting[:puppet_interval] / interval)).each do
      now = start + interval.minutes
      counter << [ Report.count(:all, :conditions => {:reported_at => start..(now-1.second)})]
      labels  << [ "'#{time_ago_in_words(start.getlocal)}'" ]
      start = now
    end
    {:labels => labels, :counter =>counter}
  end


  def render_overview report
    function = <<-EOF
  $(function () {
    new Highcharts.Chart({
      chart: {
        renderTo: 'overview',
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
         text: 'Puppet Clients Activity Overview',
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
                  return '<b>'+ this.point.name +'</b>: '+ this.y;
               }
            }
         }
      },
       series: [{
         type: 'pie',
         name: '',
         data: [
            ['Active',   #{report[:active_hosts]}],
            ['Error',    #{report[:bad_hosts]}],
            ['OK',       #{report[:ok_hosts]}],
            ['Out of sync',   #{report[:out_of_sync_hosts]}],
            ['No report', #{report[:reports_missing]}]
         ]
      }]
    });
  });
EOF
    content_tag(:div, nil, :id => 'overview' ) +
    javascript_tag(function)
  end


  def render_run_distribution data
    function = <<-EOF
 $(function() {
   chart = new Highcharts.Chart({
      chart: {
        renderTo: 'run_distribution',
        defaultSeriesType: 'column',
        margin: [ 50, 50, 100, 80],
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
         text: 'Run Distribution in the last #{Setting[:puppet_interval]} minutes',
         style: {color: '#000000'}
      },
      xAxis: {
         categories: [ #{data[:labels].join(' ,')} ] ,
         labels: {
            rotation: -45,
            align: 'right',
            style: {
                font: 'normal 13px Verdana, sans-serif'
            }
         }
      },
      yAxis: {
         min: 0,
         title: {
            text: 'Number Of Clients'
         }
      },
      legend: {
         enabled: false
      },
      tooltip: {
         formatter: function() {
            return '<b>'+ this.x +'</b><br/>'+
                'Number of Clients: '+ Highcharts.numberFormat(this.y, 1);
         }
      },
           series: [{
         name: 'Clients_Count',
         data:  [ #{data[:counter].join(' ,')} ] ,
         dataLabels: {
            enabled: false,
            rotation: -90,
            align: 'right',
            x: -3,
            y: 10,
            formatter: function() {
               return this.y;
            },
            style: {
               font: 'normal 13px Verdana, sans-serif'
            }
         }
      }]
   });
   });
    EOF
    content_tag(:div, nil, :id => 'run_distribution' ) +
    javascript_tag(function)
  end
end
