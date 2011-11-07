$(function(){
  $(".statistics_pie").each(function(index, element){
    var el = $(element);
    var name = el.attr('chart-name');
    var title = el.attr('chart-title');
    var data = $.parseJSON(el.attr('chart-data'));

    stat_pie(name, title, data);
  });

  $(".statistics_bar").each(function(index, element){
    var el = $(element);
    var name = el.attr('chart-name');
    var title = el.attr('chart-title');
    var subtitle = el.attr('chart-subtitle');
    var labels = $.parseJSON(el.attr('chart-labels'));
    var data = $.parseJSON(el.attr('chart-data'));

    stat_bar(name, title, subtitle, labels, data);
  });

  $("#runtime_graph").each(function(index, element){
    var el = $(element);
    var name = el.attr('chart-name');
    var title = el.attr('chart-title');
    var subtitle = el.attr('chart-subtitle');
    var data_runtime = $.parseJSON(el.attr('chart-data-runtime'));
    var data_config = $.parseJSON(el.attr('chart-data-config'));

    runtime_chart(name, title, subtitle, data_runtime, data_config);
  });

  $("#resource_graph").each(function(index, element){
    var el = $(element);
    var name = el.attr('chart-name');
    var title = el.attr('chart-title');
    var subtitle = el.attr('chart-subtitle');
    var data_failed = $.parseJSON(el.attr('chart-data-failed'));
    var data_failed_restarts = $.parseJSON(el.attr('chart-data-failed_restart'));
    var data_skipped = $.parseJSON(el.attr('chart-data-skipped'));
    var data_applied = $.parseJSON(el.attr('chart-data-applied'));
    var data_restarted = $.parseJSON(el.attr('chart-data-restarted'));

    report_status_chart(name, title, subtitle, data_failed, data_failed_restarts, data_skipped, data_applied, data_restarted);
  })

});

function stat_pie(name, title, data) {
    new Highcharts.Chart({
      chart: {
        renderTo: name,
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
        enabled: false
      },
      title: {
         text: title,
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
                  return  this.point.name + ': '+ Math.round(this.y*100)/100;
               }
            }
         }
      },
       series: [{
         type: 'pie',
         name: '',
         data: data
      }]
    });
  }

function stat_bar(name, title, subtitle, labels, data) {
 new Highcharts.Chart({
    chart: {
      renderTo: name,
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
      enabled: false
    },
    title: {
       text: title,
       style: {color: '#000000'}
    },
    xAxis: {
       categories: labels ,
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
          text: subtitle,
          style: {color: '#000000'}
       }
    },
    legend: {
       enabled: false
    },
    tooltip: {
       formatter: function() {
          return '<b>'+ this.x +'</b><br/>'+
              subtitle+': '+ Highcharts.numberFormat(this.y, 1);
       }
    },
         series: [{
       name: 'Clients_Count',
       data:  data ,
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
}

function report_status_chart(name, title, subtitle, data_failed, data_failed_restarts, data_skipped, data_applied, data_restarted) {
    Highcharts.setOptions({
      global: {
        useUTC: false
      }
    });
   chart = new Highcharts.Chart({
      chart: {
         renderTo: name,
         defaultSeriesType: 'line',
         zoomType: 'x',
         margin: [ 50, 30, 90, 70],
         borderColor: '#909090',
         borderWidth: 1,
         backgroundColor: {
         linearGradient: [0, 0, 0, 300],
         stops: [
            [0, '#ffffff'],
            [1, '#EDEDED']
         ]}
      },
      title: {
         text: title,
         style: {color: '#000000'},
         x: -20 //center
      },
      subtitle: {
         text: subtitle,
         x: -20
      },
      credits: {
      enabled: false
      },
      xAxis: {
         type: 'datetime',
         labels: {
            rotation: -45,
            align: 'right',
            style: {
                font: 'normal 13px Verdana, sans-serif'
            }
         }
      },
      yAxis: {
         title: {
            text: 'Number of Events'
         },
         min: 0
      },
      tooltip: {
         formatter: function() {
                   return '<b>'+ this.series.name + ': ' + this.y + '</b><br/>'+
              Highcharts.dateFormat('%e. %b %H:%M', this.x)  ;
         }
      },
      legend: {
         layout: 'horizontal',
         align: 'bottom',
         verticalAlign: 'bottom',
         x: 10,
         y: -10,
         borderWidth: 0
      },
      colors: [
       '#AA4643',
       '#AA4643',
       '#80699B',
       '#89A54E',
       '#4572A7',
       '#80699B',
       '#3D96AE',
       '#DB843D',
       '#92A8CD',
       '#A47D7C',
       '#B5CA92'
      ],
      series: [{
         name: 'Failed',
         data: data_failed
      }, {
         name: 'Failed restarts',
         data: data_failed_restarts
      }, {
         name: 'Skipped',
         data: data_skipped
      }, {
         name: 'Applied',
         data: data_applied
      }, {
         name: 'Restarted',
         data: data_restarted
      }]
   });


  }
function runtime_chart (name, title, subtitle, data_runtime, data_config) {
   chart = new Highcharts.Chart({
      chart: {
         renderTo: name,
         defaultSeriesType: 'area',
         zoomType: 'x',
         margin: [ 50, 30, 90, 70],
         borderColor: '#909090',
         borderWidth: 1,
         backgroundColor: {
         linearGradient: [0, 0, 0, 300],
         stops: [
            [0, '#ffffff'],
            [1, '#EDEDED']
         ]}
      },
      title: {
         text: title,
         style: {color: '#000000'},
         x: -20 //center
      },
      subtitle: {
         text: subtitle,
         x: -20
      },
      credits: {
      enabled: false
      },
      xAxis: {
         type: 'datetime',
         labels: {
            rotation: -45,
            align: 'right',
            style: {
                font: 'normal 13px Verdana, sans-serif'
            }
         }
      },
      yAxis: {
         title: {
            text: 'Time in Seconds'
         },
         min: 0
      },
      tooltip: {
         formatter: function() {
                   return '<b>'+ this.series.name + ': ' + this.y + '</b><br/>'+
              Highcharts.dateFormat('%e. %b %H:%M', this.x)  ;
         }
      },
      legend: {
         layout: 'horizontal',
         align: 'bottom',
         verticalAlign: 'bottom',
         x: 10,
         y: -10,
         borderWidth: 0
      },
      plotOptions: {
         area: {
            lineWidth: 1,
            stacking: 'normal',
            marker: {
               enabled: false,
               symbol: 'circle',
               radius: 2,
               states: {
                  hover: {
                     enabled: true
                  }
               }
            }
         }
      },
      series: [{
         name: 'Runtime',
         data: data_runtime
      }, {
         name: 'Config Retrieval',
         data: data_config
      }]
   });
  }